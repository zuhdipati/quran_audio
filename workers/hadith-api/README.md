# Hadith API

A Cloudflare Worker over a D1 (SQLite) database that serves every hadith
collection to the app at `https://hadith.zuhdipati.cloud/v1`, with page-based
browsing and full-text search.

## Endpoints

| Request | Returns |
|---|---|
| `GET /v1/collections` | `{data: [{id, name, narrator, total}]}` |
| `GET /v1/collections/:id/hadiths?page=1&limit=20` | `{data: [{number, title, arabic, translation}], page, limit, total, totalPages}` |
| `GET /v1/collections/:id/hadiths/:number` | `{data: {number, title, arabic, translation}}` |
| `GET /v1/search?q=…&collection=…&page=1&limit=20` | `{data: [{collection, collectionName, number, title, arabic, translation, snippet}], page, limit, total, totalPages, capped}` |

- `page` is 1-based and `limit` is 1–50, with a default of 20.
- Search matches the Indonesian translation, the title and the Arabic.
  - Harakat don't matter.
  - Words of three letters or more also match as prefixes.
  - `snippet` wraps matches in `<mark>…</mark>`.
  - Results are in collection order.
- `collection` limits a search to one collection. There, a bare number opens that hadith.
- The search count stops at 1,000. When it does, `capped` is `true`.
- Errors come back as `{error: "<code>"}` with a 4xx or 5xx status.

## Cost

Everything fits the Workers free plan:
- 100k requests a day.
- D1 reads: 5M rows a day.
  - A browse page reads about 21 rows.
  - A search reads its match count (at most 1,000) plus about 80 rows.
- D1 size: about 240 MB, under the 500 MB free limit.

Responses are also kept in the edge cache: browsing for a day, search for an hour.

## Deploy

```sh
npm install
npm test
npx wrangler deploy
```

## Re-importing the data

The data is read-only once imported. To rebuild it, start from an empty database.

The import writes each hadith twice, once as a row and once into the search
index, so a full import is about 131k row writes. That is more than the
free plan's 100k per day. Split it across two days: the collection files on
one day, and `99-search-index.sql` on the next.

You need the chunked JSON in `build/hadith/hadith` first. Either download
`hadith/` from the R2 bucket `imaan` into that folder, or rebuild it from the
source dump with `tool/build_hadith_json.py`.

```sh
python3 tool/build_hadith_json.py hadits-database build/hadith   # or copy from R2
python3 tool/build_hadith_d1.py build/hadith/hadith build/hadith/d1

cd workers/hadith-api
npx wrangler d1 create imaan-hadith --location apac   # put the id in wrangler.jsonc
npx wrangler d1 execute imaan-hadith --remote --file=schema.sql
for f in ../../build/hadith/d1/*.sql; do
  npx wrangler d1 execute imaan-hadith --remote --yes --file="$f"
done
npx wrangler deploy   # fresh isolates drop the cached catalogue
```

`wrangler d1 export` does not support databases with virtual tables. The only
backup is the JSON in the R2 bucket `imaan` under `hadith/`. The app never reads
it, but do not delete it.
