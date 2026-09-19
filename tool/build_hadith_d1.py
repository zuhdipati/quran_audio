#!/usr/bin/env python3
"""Turn the chunked hadith JSON into SQL for the D1 database behind
workers/hadith-api.

Usage:
    python3 tool/build_hadith_json.py hadits-database build/hadith
    python3 tool/build_hadith_d1.py build/hadith/hadith build/hadith/d1

Writes, to be applied in name order after workers/hadith-api/schema.sql:
    <out>/00-collections.sql        the catalogue
    <out>/NN-<slug>.sql             one per collection, in manifest order
    <out>/99-search-index.sql       fills the full-text index from the rows

workers/hadith-api/README.md has the wrangler commands.

Row ids follow the manifest order, so that
id = collections.first_row + number - 1 and the API can read any page as a
primary-key range.
"""

import json
import os
import re
import sys

# D1 rejects statements over 100 KB; leave room for the statement around
# the values
STATEMENT_BUDGET = 90_000

# rows per full-text insert: each statement indexes this many hadith, and
# must finish inside D1's per-query time limit
FTS_BATCH = 5_000

# Must match normalizeArabic in workers/hadith-api/src/query.ts, or indexed
# text and queries fold differently and stop matching.
ARABIC_MARKS = re.compile("[ؐ-ًؚ-ٰٟۖ-ۭـ]")
ALEF_VARIANTS = re.compile("[آأإٱ]")


def normalize_arabic(text):
    text = ARABIC_MARKS.sub("", text)
    text = ALEF_VARIANTS.sub("ا", text)
    return text.replace("ى", "ي").replace("ة", "ه")


def sql(value):
    if value is None:
        return "NULL"
    if isinstance(value, int):
        return str(value)
    return "'" + value.replace("'", "''") + "'"


def size(statement):
    return len(statement.encode("utf-8"))


def pieces(text, limit):
    """Split text into parts whose quoted SQL literals stay under limit bytes."""
    parts, current, used = [], [], 0
    for ch in text:
        n = len(ch.encode("utf-8")) * (2 if ch == "'" else 1)
        if used + n > limit and current:
            parts.append("".join(current))
            current, used = [], 0
        current.append(ch)
        used += n
    parts.append("".join(current))
    return parts


INSERT = (
    "INSERT INTO hadith (id, collection, number, title, arabic, translation, "
    "arabic_plain) VALUES\n"
)
TEXT_FIELDS = ("arabic", "translation", "arabic_plain")


def oversized_row(row_id, collection, h, plain):
    """A hadith too long for one statement: insert the start of each text
    field, then append the rest one piece per UPDATE."""
    fields = {
        "arabic": pieces(h["arabic"], STATEMENT_BUDGET // 4),
        "translation": pieces(h["translation"], STATEMENT_BUDGET // 4),
        "arabic_plain": pieces(plain, STATEMENT_BUDGET // 4),
    }
    first = (
        row_id,
        collection,
        h["number"],
        h.get("title") or None,
        *(fields[f][0] for f in TEXT_FIELDS),
    )
    statements = [INSERT + "(" + ", ".join(sql(v) for v in first) + ");"]
    for field in TEXT_FIELDS:
        for part in fields[field][1:]:
            statements.append(
                f"UPDATE hadith SET {field} = {field} || {sql(part)} "
                f"WHERE id = {row_id};"
            )
    return statements


def collection_statements(collection, hadiths, first_row):
    statements, values, used = [], [], size(INSERT)

    def flush():
        nonlocal values, used
        if values:
            statements.append(INSERT + ",\n".join(values) + ";")
        values, used = [], size(INSERT)

    for h in hadiths:
        row_id = first_row + h["number"] - 1
        plain = normalize_arabic(h["arabic"])
        row = (
            "("
            + ", ".join(
                sql(v)
                for v in (
                    row_id,
                    collection,
                    h["number"],
                    h.get("title") or None,
                    h["arabic"],
                    h["translation"],
                    plain,
                )
            )
            + ")"
        )
        if size(INSERT + row) > STATEMENT_BUDGET:
            flush()
            statements.extend(oversized_row(row_id, collection, h, plain))
            continue
        if used + size(row) + 2 > STATEMENT_BUDGET:
            flush()
        values.append(row)
        used += size(row) + 2
    flush()
    return statements


def load_hadiths(src, collection):
    folder = os.path.join(src, collection)
    hadiths = []
    for name in sorted(os.listdir(folder)):
        with open(os.path.join(folder, name), encoding="utf-8") as f:
            data = json.load(f)
        hadiths.extend(data["hadiths"] if isinstance(data, dict) else data)
    hadiths.sort(key=lambda h: h["number"])
    numbers = [h["number"] for h in hadiths]
    if numbers != list(range(1, len(hadiths) + 1)):
        # the id arithmetic in the API depends on this
        sys.exit(f"{collection}: hadith numbers are not 1..{len(hadiths)}")
    return hadiths


def write(path, statements):
    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(statements) + "\n")


def build(src, out):
    with open(os.path.join(src, "index.json"), encoding="utf-8") as f:
        manifest = json.load(f)
    os.makedirs(out, exist_ok=True)

    catalogue, first_row = [], 1
    for position, entry in enumerate(manifest, start=1):
        hadiths = load_hadiths(src, entry["id"])
        if len(hadiths) != entry["total"]:
            sys.exit(f"{entry['id']}: manifest says {entry['total']}, found {len(hadiths)}")
        statements = collection_statements(entry["id"], hadiths, first_row)
        write(os.path.join(out, f"{position:02d}-{entry['id']}.sql"), statements)
        catalogue.append((entry, first_row))
        print(f"{entry['id']:24s} rows {first_row}..{first_row + len(hadiths) - 1}"
              f"  statements {len(statements)}")
        first_row += len(hadiths)

    write(
        os.path.join(out, "00-collections.sql"),
        [
            "INSERT INTO collections (id, name, narrator, total, first_row) VALUES\n"
            + ",\n".join(
                "(" + ", ".join(sql(v) for v in (
                    e["id"], e["name"], e["narrator"], e["total"], row,
                )) + ")"
                for e, row in catalogue
            )
            + ";"
        ],
    )

    last_row = first_row - 1
    write(
        os.path.join(out, "99-search-index.sql"),
        [
            "INSERT INTO hadith_fts (rowid, title, translation, arabic_plain) "
            f"SELECT id, title, translation, arabic_plain FROM hadith "
            f"WHERE id BETWEEN {start} AND {min(start + FTS_BATCH - 1, last_row)};"
            for start in range(1, last_row + 1, FTS_BATCH)
        ],
    )
    print(f"{last_row} hadith in {len(catalogue)} collections -> {out}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    build(sys.argv[1], sys.argv[2])
