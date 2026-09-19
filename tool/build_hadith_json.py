#!/usr/bin/env python3
"""Convert the hadits-database SQL dumps into chunked JSON, the input for
tool/build_hadith_d1.py.

Source: https://github.com/irsyadulibad/hadits-database (MIT; translations
originate from carihadis.com).

Usage:
    git clone --depth 1 https://github.com/irsyadulibad/hadits-database.git
    python3 tool/build_hadith_json.py hadits-database build/hadith

Writes:
    <out>/hadith/<slug>/<nnn>.json   chunked hadiths
    <out>/hadith/index.json          manifest: names, order and totals

Arbain An-Nawawi is not in the dump; it comes from tool/data/arbain_nawawi.json
and is written as a single chunk ahead of the rest.

Then turn it into SQL for the hadith API's D1 database:
    python3 tool/build_hadith_d1.py <out>/hadith <out>/d1
"""

import html
import json
import os
import re
import sys

# chunks are sized per collection to land near this, keeping every file
# small enough to open and inspect
TARGET_CHUNK_BYTES = 320 * 1024
MIN_CHUNK, MAX_CHUNK = 10, 200

# display metadata the SQL dump does not carry
COLLECTIONS = [
    ("shahih-bukhari", "Shahih Bukhari", "Imam Bukhari"),
    ("shahih-muslim", "Shahih Muslim", "Imam Muslim"),
    ("sunan-abu-daud", "Sunan Abu Daud", "Imam Abu Daud"),
    ("sunan-tirmidzi", "Sunan Tirmidzi", "Imam Tirmidzi"),
    ("sunan-nasai", "Sunan Nasa'i", "Imam Nasa'i"),
    ("sunan-ibnu-majah", "Sunan Ibnu Majah", "Imam Ibnu Majah"),
    ("musnad-ahmad", "Musnad Ahmad", "Imam Ahmad bin Hanbal"),
    ("musnad_darimi", "Sunan Darimi", "Imam Darimi"),
    ("muwatho_malik", "Muwatha' Malik", "Imam Malik"),
    ("musnad-syafii", "Musnad Syafi'i", "Imam Syafi'i"),
    ("riyadhus-shalihin", "Riyadhus Shalihin", "Imam An-Nawawi"),
    ("riyadhus-shalihin-arab", "Riyadhus Shalihin (Arab)", "Imam An-Nawawi"),
]

# curated separately, with titles; the app opens it first because it is the
# smallest collection and a single fetch
ARBAIN_SOURCE = os.path.join(os.path.dirname(__file__), "data", "arbain_nawawi.json")
ARBAIN = ("arbain-nawawi", "Hadits Arbain An-Nawawi", "Imam An-Nawawi")

_ESCAPES = {"n": "\n", "r": "\r", "t": "\t", "0": "", "b": "", "Z": ""}


def parse_values(sql: str):
    """Yield each VALUES tuple from a phpMyAdmin dump as a list of fields.

    Hand-rolled because the dumps contain unescaped newlines inside strings,
    which trips line-oriented parsing.
    """
    i, n = 0, len(sql)
    while i < n:
        start = sql.find("VALUES", i)
        if start == -1:
            return
        i = start + len("VALUES")
        while i < n:
            while i < n and sql[i] in " \t\r\n,":
                i += 1
            if i >= n or sql[i] != "(":
                break  # end of this INSERT statement
            i += 1
            fields, buf, in_str = [], [], False
            while i < n:
                ch = sql[i]
                if in_str:
                    if ch == "\\" and i + 1 < n:
                        nxt = sql[i + 1]
                        buf.append(_ESCAPES.get(nxt, nxt))
                        i += 2
                        continue
                    if ch == "'":
                        in_str = False
                        i += 1
                        continue
                    buf.append(ch)
                    i += 1
                    continue
                if ch == "'":
                    in_str = True
                    i += 1
                    continue
                if ch == ",":
                    fields.append("".join(buf).strip())
                    buf = []
                    i += 1
                    continue
                if ch == ")":
                    fields.append("".join(buf).strip())
                    i += 1
                    break
                buf.append(ch)
                i += 1
            yield fields


_BLOCK_TAG = re.compile(r"</?(p|div|br|h[1-6]|li|tr|blockquote)\b[^>]*>", re.I)
_ANY_TAG = re.compile(r"<[^>]+>")


def clean(text: str) -> str:
    """Normalise whitespace and flatten markup, without touching the wording.

    The Riyadhus Shalihin tables store their text as HTML; every other
    collection is plain, so the tag handling is a no-op there.
    """
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    text = _BLOCK_TAG.sub("\n", text)
    text = _ANY_TAG.sub("", text)
    text = html.unescape(text)
    text = text.replace("\xa0", " ")
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r" *\n *", "\n", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


def chunk_size_for(hadiths) -> int:
    """Entries per chunk, chosen so a chunk lands near TARGET_CHUNK_BYTES."""
    average = sum(
        len(h["arabic"]) + len(h["translation"]) for h in hadiths
    ) / len(hadiths)
    # rough: UTF-8 Arabic runs ~2 bytes/char, plus JSON overhead
    estimated = average * 2.1 + 60
    return max(MIN_CHUNK, min(MAX_CHUNK, int(TARGET_CHUNK_BYTES / estimated)))


def write_arbain(root: str) -> dict:
    """Write Arbain as one chunk and return its manifest entry."""
    slug, name, narrator = ARBAIN
    with open(ARBAIN_SOURCE, encoding="utf-8") as fh:
        hadiths = json.load(fh)["hadiths"]

    chunk_dir = os.path.join(root, slug)
    os.makedirs(chunk_dir, exist_ok=True)
    with open(os.path.join(chunk_dir, "001.json"), "w", encoding="utf-8") as fh:
        json.dump(hadiths, fh, ensure_ascii=False, separators=(",", ":"))

    print(f"  {name:28} {len(hadiths):6,} hadiths    1 chunks")
    return {
        "id": slug,
        "name": name,
        "narrator": narrator,
        "total": len(hadiths),
        "chunkSize": len(hadiths),
        "chunks": 1,
    }


def build(src_dir: str, out_dir: str) -> None:
    root = os.path.join(out_dir, "hadith")
    os.makedirs(root, exist_ok=True)
    index = [write_arbain(root)]

    for slug, name, narrator in COLLECTIONS:
        path = os.path.join(src_dir, f"{slug}.sql")
        if not os.path.exists(path):
            print(f"  SKIP {slug}: no {path}")
            continue

        with open(path, encoding="utf-8", errors="replace") as fh:
            sql = fh.read()

        hadiths = []
        for fields in parse_values(sql):
            if len(fields) < 4:
                continue
            arabic, translation = clean(fields[2]), clean(fields[3])
            if not arabic and not translation:
                continue
            hadiths.append(
                {
                    "number": len(hadiths) + 1,
                    "arabic": arabic,
                    "translation": translation,
                }
            )

        if not hadiths:
            print(f"  WARN {slug}: parsed 0 rows")
            continue

        chunk_dir = os.path.join(root, slug)
        os.makedirs(chunk_dir, exist_ok=True)
        size = chunk_size_for(hadiths)
        chunks = 0
        for offset in range(0, len(hadiths), size):
            chunks += 1
            with open(
                os.path.join(chunk_dir, f"{chunks:03d}.json"), "w", encoding="utf-8"
            ) as fh:
                json.dump(
                    hadiths[offset : offset + size],
                    fh,
                    ensure_ascii=False,
                    separators=(",", ":"),
                )

        index.append(
            {
                "id": slug,
                "name": name,
                "narrator": narrator,
                "total": len(hadiths),
                "chunkSize": size,
                "chunks": chunks,
            }
        )
        size = sum(
            os.path.getsize(os.path.join(chunk_dir, f))
            for f in os.listdir(chunk_dir)
        )
        print(f"  {name:28} {len(hadiths):6,} hadiths  {chunks:3} chunks  {size/1048576:6.1f} MB")

    with open(os.path.join(root, "index.json"), "w", encoding="utf-8") as fh:
        json.dump(index, fh, ensure_ascii=False, indent=2)

    print(f"\ntotal {sum(c['total'] for c in index):,} hadiths across {len(index)} collections")
    print(f"written to {root}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(__doc__)
        raise SystemExit(1)
    build(sys.argv[1], sys.argv[2])
