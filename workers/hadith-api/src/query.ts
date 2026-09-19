/**
 * Harakat, Quranic annotation marks and tatweel. SQLite's unicode61
 * tokenizer treats combining marks as separators, so voweled Arabic would
 * index as loose letters.
 */
const ARABIC_MARKS = /[ؐ-ًؚ-ٰٟۖ-ۭـ]/g;
const ALEF_VARIANTS = /[آأإٱ]/g;

/**
 * Must match normalize_arabic in tool/build_hadith_d1.py, which folds the
 * indexed text the same way; if the two drift apart, Arabic queries stop
 * matching.
 */
export function normalizeArabic(text: string): string {
  return text
    .replace(ARABIC_MARKS, '')
    .replace(ALEF_VARIANTS, 'ا')
    .replace(/ى/g, 'ي')
    .replace(/ة/g, 'ه');
}

const MAX_TERMS = 8;

/**
 * An FTS5 MATCH expression for what the user typed, or null when nothing
 * searchable is left. Terms are cut at anything that is not a letter or a
 * digit, as the tokenizer cuts them, and each term is quoted so FTS5
 * operators typed by the user are searched for literally. Terms of three
 * characters or more also match as prefixes, which catches Indonesian
 * suffixes such as -nya, -kan and -lah.
 */
export function toMatchExpression(query: string): string | null {
  const terms = normalizeArabic(query)
    .split(/[^\p{L}\p{N}]+/u)
    .filter((term) => term.length > 0)
    .slice(0, MAX_TERMS);
  if (terms.length === 0) return null;
  return terms
    .map((term) => (term.length >= 3 ? `"${term}"*` : `"${term}"`))
    .join(' ');
}

export const DEFAULT_LIMIT = 20;
export const MAX_LIMIT = 50;

/** Keeps row arithmetic far from anything a real collection reaches. */
const MAX_PAGE = 100_000;

export interface Paging {
  page: number;
  limit: number;
}

/** `page` is 1-based; anything missing or malformed falls back quietly. */
export function readPaging(params: URLSearchParams): Paging {
  return {
    page: readInt(params.get('page'), 1, 1, MAX_PAGE),
    limit: readInt(params.get('limit'), DEFAULT_LIMIT, 1, MAX_LIMIT),
  };
}

function readInt(
  raw: string | null,
  fallback: number,
  min: number,
  max: number,
): number {
  const value = raw === null || raw.trim() === '' ? NaN : Number(raw);
  if (!Number.isInteger(value)) return fallback;
  return Math.min(Math.max(value, min), max);
}

export function pageInfo(paging: Paging, total: number) {
  return {
    page: paging.page,
    limit: paging.limit,
    total,
    totalPages: Math.ceil(total / paging.limit),
  };
}
