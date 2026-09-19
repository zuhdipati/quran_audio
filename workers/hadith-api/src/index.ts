import {
  pageInfo,
  readPaging,
  toMatchExpression,
  type Paging,
} from './query';

export interface Env {
  DB: D1Database;
}

interface Collection {
  id: string;
  name: string;
  narrator: string;
  total: number;
  first_row: number;
}

/**
 * Search stops counting here. A common word matches most of the corpus,
 * and counting every hit spends read quota on a total nobody pages
 * through; the response says `capped` instead.
 */
const SEARCH_COUNT_CAP = 1000;

/** Collections only change with a re-import; search can go stale sooner. */
const BROWSE_MAX_AGE = 86_400;
const SEARCH_MAX_AGE = 3_600;

const HADITH_COLUMNS = 'number, title, arabic, translation';

const COUNT_SQL = `
  SELECT count(*) AS n FROM (
    SELECT rowid FROM hadith_fts
    WHERE hadith_fts MATCH ?1 AND rowid BETWEEN ?2 AND ?3
    LIMIT ?4)`;

// Paging happens inside the CTE so only the rows on the page are joined
// back to their text; snippet() has to run there too, next to the MATCH.
const SEARCH_SQL = `
  WITH hits AS (
    SELECT rowid AS id,
      snippet(hadith_fts, 1, '<mark>', '</mark>', '…', 24) AS snippet
    FROM hadith_fts
    WHERE hadith_fts MATCH ?1 AND rowid BETWEEN ?2 AND ?3
    ORDER BY rowid LIMIT ?4 OFFSET ?5)
  SELECT h.collection, c.name AS collectionName, h.number, h.title,
    h.arabic, h.translation, hits.snippet
  FROM hits
  JOIN hadith h ON h.id = hits.id
  JOIN collections c ON c.id = h.collection
  ORDER BY h.id`;

export default {
  async fetch(request, env, ctx): Promise<Response> {
    if (request.method !== 'GET') return error(405, 'method_not_allowed');

    const cache = caches.default;
    const cached = await cache.match(request);
    if (cached) return cached;

    let response: Response;
    try {
      response = await route(new URL(request.url), env.DB);
    } catch (e) {
      console.error(e);
      return error(500, 'internal_error');
    }
    if (response.ok) ctx.waitUntil(cache.put(request, response.clone()));
    return response;
  },
} satisfies ExportedHandler<Env>;

async function route(url: URL, db: D1Database): Promise<Response> {
  const path = url.pathname.replace(/\/+$/, '');
  const params = url.searchParams;

  if (path === '/v1/collections') {
    const data = (await catalogue(db)).map(
      ({ id, name, narrator, total }) => ({ id, name, narrator, total }),
    );
    return json({ data }, BROWSE_MAX_AGE);
  }

  if (path === '/v1/search') return search(db, params);

  const match = path.match(/^\/v1\/collections\/([\w-]+)\/hadiths(?:\/(\d+))?$/);
  if (match) {
    const collection = (await catalogue(db)).find((c) => c.id === match[1]);
    if (!collection) return error(404, 'collection_not_found');
    if (match[2] === undefined) {
      return listHadiths(db, collection, readPaging(params));
    }
    const hadith = await hadithByNumber(db, collection, Number(match[2]));
    return hadith
      ? json({ data: hadith }, BROWSE_MAX_AGE)
      : error(404, 'hadith_not_found');
  }

  return error(404, 'not_found');
}

let cachedCatalogue: Collection[] | undefined;

/**
 * Every request needs the 13-row catalogue, so an isolate reads it once. It
 * only changes with a re-import, and the redeploy that follows one starts
 * fresh isolates. The rows are kept rather than the pending promise: a
 * promise started by one request must not be awaited by another.
 */
async function catalogue(db: D1Database): Promise<Collection[]> {
  if (!cachedCatalogue) {
    const { results } = await db
      .prepare(
        'SELECT id, name, narrator, total, first_row FROM collections ' +
          'ORDER BY first_row',
      )
      .all<Collection>();
    cachedCatalogue = results;
  }
  return cachedCatalogue;
}

/** Hadith are numbered 1..total without gaps, so a number is a row id. */
const rowOf = (collection: Collection, number: number) =>
  collection.first_row + number - 1;

async function listHadiths(
  db: D1Database,
  collection: Collection,
  paging: Paging,
): Promise<Response> {
  const from = (paging.page - 1) * paging.limit + 1;
  const to = Math.min(paging.page * paging.limit, collection.total);

  let data: unknown[] = [];
  if (from <= collection.total) {
    ({ results: data } = await db
      .prepare(
        `SELECT ${HADITH_COLUMNS} FROM hadith ` +
          'WHERE id BETWEEN ?1 AND ?2 ORDER BY id',
      )
      .bind(rowOf(collection, from), rowOf(collection, to))
      .all());
  }

  return json(
    { data, ...pageInfo(paging, collection.total) },
    BROWSE_MAX_AGE,
  );
}

function hadithByNumber(
  db: D1Database,
  collection: Collection,
  number: number,
): Promise<Record<string, unknown> | null> {
  if (!Number.isInteger(number) || number < 1 || number > collection.total) {
    return Promise.resolve(null);
  }
  return db
    .prepare(`SELECT ${HADITH_COLUMNS} FROM hadith WHERE id = ?1`)
    .bind(rowOf(collection, number))
    .first();
}

async function search(
  db: D1Database,
  params: URLSearchParams,
): Promise<Response> {
  const paging = readPaging(params);
  const query = (params.get('q') ?? '').trim().slice(0, 200);
  const collections = await catalogue(db);

  const scope = params.get('collection');
  const collection = scope
    ? collections.find((c) => c.id === scope)
    : undefined;
  if (scope && !collection) return error(404, 'collection_not_found');

  // a bare number inside one collection is a jump to that hadith, not a
  // search for the digits in the text
  if (collection && /^\d+$/.test(query)) {
    const hadith = await hadithByNumber(db, collection, Number(query));
    const data =
      hadith && paging.page === 1
        ? [
            {
              collection: collection.id,
              collectionName: collection.name,
              ...hadith,
              snippet: null,
            },
          ]
        : [];
    return json(
      { data, ...pageInfo(paging, hadith ? 1 : 0), capped: false },
      SEARCH_MAX_AGE,
    );
  }

  const expression = toMatchExpression(query);
  if (!expression) {
    return json(
      { data: [], ...pageInfo(paging, 0), capped: false },
      SEARCH_MAX_AGE,
    );
  }

  const last = collections[collections.length - 1];
  const [lo, hi] = collection
    ? [collection.first_row, rowOf(collection, collection.total)]
    : [1, rowOf(last, last.total)];
  const offset = (paging.page - 1) * paging.limit;

  const [counted, hits] = await db.batch([
    db.prepare(COUNT_SQL).bind(expression, lo, hi, SEARCH_COUNT_CAP + 1),
    db.prepare(SEARCH_SQL).bind(expression, lo, hi, paging.limit, offset),
  ]);
  const matches = (counted.results[0] as { n: number }).n;
  const total = Math.min(matches, SEARCH_COUNT_CAP);

  return json(
    {
      // pages past the cap would be reachable by URL but not by count
      data: offset < total ? hits.results : [],
      ...pageInfo(paging, total),
      capped: matches > SEARCH_COUNT_CAP,
    },
    SEARCH_MAX_AGE,
  );
}

function json(body: unknown, maxAge: number, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      'content-type': 'application/json; charset=utf-8',
      'cache-control': maxAge > 0 ? `public, max-age=${maxAge}` : 'no-store',
    },
  });
}

function error(status: number, code: string): Response {
  return json({ error: code }, 0, status);
}
