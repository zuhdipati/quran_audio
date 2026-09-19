-- Schema for the imaan-hadith D1 database. Apply once to an empty database,
-- then the files from tool/build_hadith_d1.py; README.md has the commands.

CREATE TABLE collections (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  narrator TEXT NOT NULL,
  total INTEGER NOT NULL,
  -- hadith.id of hadith number 1; numbers run 1..total without gaps, so
  -- hadith n of a collection is row first_row + n - 1
  first_row INTEGER NOT NULL
);

-- Read-only once imported. Rows are ordered by collection then number, so a
-- page is a primary-key range rather than an OFFSET scan.
CREATE TABLE hadith (
  id INTEGER PRIMARY KEY,
  collection TEXT NOT NULL,
  number INTEGER NOT NULL,
  title TEXT,
  arabic TEXT NOT NULL,
  translation TEXT NOT NULL,
  -- arabic without harakat and with letter variants folded: the FTS
  -- tokenizer splits words at every combining mark, so the voweled text
  -- cannot be indexed as is
  arabic_plain TEXT NOT NULL
);

-- External content: the text lives once, in hadith. columnsize=0 drops the
-- per-row size table, which would cost one extra write per hadith and only
-- serves bm25 ranking; results are listed in collection order instead.
CREATE VIRTUAL TABLE hadith_fts USING fts5(
  title,
  translation,
  arabic_plain,
  content = 'hadith',
  content_rowid = 'id',
  columnsize = 0,
  tokenize = 'unicode61 remove_diacritics 2'
);

-- D1 bills writes per row, and every index page is a row: the largest pages
-- FTS5 allows keep the import well inside the free daily write quota
INSERT INTO hadith_fts(hadith_fts, rank) VALUES ('pgsz', 65536);
