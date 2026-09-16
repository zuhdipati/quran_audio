#!/usr/bin/env python3
"""Sync the generated hadith corpus to Cloudflare R2.

Uploads the tree built by tool/build_hadith_json.py so object keys land
under "imaan/hadith/", with the content type and cache headers the app and
the CDN both want.

Setup (repo-local, nothing installed system-wide):
    python3 -m venv .venv
    .venv/bin/pip install -r tool/requirements.txt

Credentials come from an R2 API token
(Cloudflare dashboard -> R2 -> Manage API Tokens):
    export R2_ACCOUNT_ID=...
    export R2_ACCESS_KEY_ID=...
    export R2_SECRET_ACCESS_KEY=...
    export R2_BUCKET=...

Usage:
    .venv/bin/python tool/upload_hadith_r2.py build/hadith
    .venv/bin/python tool/upload_hadith_r2.py build/hadith --dry-run
"""

import argparse
import concurrent.futures
import os
import sys
import threading

try:
    import boto3
    from botocore.config import Config
except ImportError:
    sys.exit(
        "boto3 is missing. Run:\n"
        "  python3 -m venv .venv\n"
        "  .venv/bin/pip install -r tool/requirements.txt"
    )

# chunk contents never change once written, so both the edge and the device
# can hold them indefinitely
CACHE_CONTROL = "public, max-age=31536000, immutable"
CONTENT_TYPE = "application/json"


def collect(root: str):
    """(local path, object key) for every JSON file under root."""
    for dirpath, _, filenames in os.walk(root):
        for name in sorted(filenames):
            if not name.endswith(".json"):
                continue
            local = os.path.join(dirpath, name)
            key = os.path.relpath(local, root).replace(os.sep, "/")
            yield local, key


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", help="directory built by build_hadith_json.py")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--workers", type=int, default=16)
    args = parser.parse_args()

    if not os.path.isdir(args.root):
        sys.exit(f"no such directory: {args.root}")

    files = list(collect(args.root))
    if not files:
        sys.exit(f"no .json files under {args.root}")

    total_bytes = sum(os.path.getsize(p) for p, _ in files)
    print(f"{len(files)} files, {total_bytes / 1048576:.1f} MB")

    if not all(key.startswith("imaan/hadith/") for _, key in files):
        stray = next(k for _, k in files if not k.startswith("imaan/hadith/"))
        sys.exit(
            f"refusing to upload: {stray!r} is outside imaan/hadith/.\n"
            f"Pass the build root (e.g. build/hadith), not a subdirectory."
        )

    if args.dry_run:
        for _, key in files[:5]:
            print(f"  would put {key}")
        print(f"  ... and {len(files) - 5} more")
        return

    missing = [
        name
        for name in (
            "R2_ACCOUNT_ID",
            "R2_ACCESS_KEY_ID",
            "R2_SECRET_ACCESS_KEY",
            "R2_BUCKET",
        )
        if not os.environ.get(name)
    ]
    if missing:
        sys.exit("missing environment variables: " + ", ".join(missing))

    bucket = os.environ["R2_BUCKET"]
    client = boto3.client(
        "s3",
        endpoint_url=f"https://{os.environ['R2_ACCOUNT_ID']}.r2.cloudflarestorage.com",
        aws_access_key_id=os.environ["R2_ACCESS_KEY_ID"],
        aws_secret_access_key=os.environ["R2_SECRET_ACCESS_KEY"],
        region_name="auto",
        config=Config(retries={"max_attempts": 5, "mode": "standard"}),
    )

    done = 0
    failures = []
    lock = threading.Lock()

    def put(item):
        nonlocal done
        local, key = item
        try:
            with open(local, "rb") as fh:
                client.put_object(
                    Bucket=bucket,
                    Key=key,
                    Body=fh.read(),
                    ContentType=CONTENT_TYPE,
                    CacheControl=CACHE_CONTROL,
                )
        except Exception as exc:  # reported in the summary, not swallowed
            with lock:
                failures.append((key, exc))
        with lock:
            done += 1
            if done % 25 == 0 or done == len(files):
                print(f"  {done}/{len(files)}", flush=True)

    with concurrent.futures.ThreadPoolExecutor(args.workers) as pool:
        list(pool.map(put, files))

    if failures:
        print(f"\n{len(failures)} failed:")
        for key, exc in failures[:10]:
            print(f"  {key}: {exc}")
        sys.exit(1)

    print(f"\nuploaded {len(files)} objects to {bucket}")


if __name__ == "__main__":
    main()
