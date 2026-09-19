import { describe, expect, it } from 'vitest';
import {
  normalizeArabic,
  pageInfo,
  readPaging,
  toMatchExpression,
} from '../src/query';

describe('normalizeArabic', () => {
  it('strips harakat and tatweel', () => {
    expect(normalizeArabic('حَدَّثَنَا')).toBe('حدثنا');
    expect(normalizeArabic('اللّـٰه')).toBe('الله');
  });

  it('folds alef variants, alef maksura and ta marbuta', () => {
    expect(normalizeArabic('أإآٱ')).toBe('اااا');
    expect(normalizeArabic('على الصلاة')).toBe('علي الصلاه');
  });

  it('leaves latin text alone', () => {
    expect(normalizeArabic('Sabar itu cahaya')).toBe('Sabar itu cahaya');
  });
});

describe('toMatchExpression', () => {
  it('quotes each term and prefix-matches longer ones', () => {
    expect(toMatchExpression('niat amal')).toBe('"niat"* "amal"*');
    expect(toMatchExpression('ya')).toBe('"ya"');
  });

  it('neutralises FTS5 syntax typed by the user', () => {
    expect(toMatchExpression('sabar" OR NEAR(x')).toBe(
      '"sabar"* "OR" "NEAR"* "x"',
    );
    expect(toMatchExpression('translation:sabar*')).toBe(
      '"translation"* "sabar"*',
    );
  });

  it('matches voweled Arabic against the plain index', () => {
    expect(toMatchExpression('إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ')).toBe(
      '"انما"* "الاعمال"* "بالنيات"*',
    );
  });

  it('gives up on input with nothing to search', () => {
    expect(toMatchExpression('')).toBeNull();
    expect(toMatchExpression(' "*()- ')).toBeNull();
  });

  it('caps the number of terms', () => {
    const expression = toMatchExpression('a b c d e f g h i j');
    expect(expression?.split(' ')).toHaveLength(8);
  });
});

describe('readPaging', () => {
  const read = (query: string) => readPaging(new URLSearchParams(query));

  it('defaults to the first page of 20', () => {
    expect(read('')).toEqual({ page: 1, limit: 20 });
  });

  it('clamps out-of-range values', () => {
    expect(read('page=0&limit=500')).toEqual({ page: 1, limit: 50 });
    expect(read('page=-3&limit=0')).toEqual({ page: 1, limit: 1 });
  });

  it('ignores anything that is not an integer', () => {
    expect(read('page=two&limit=2.5')).toEqual({ page: 1, limit: 20 });
  });
});

describe('pageInfo', () => {
  it('counts partial last pages', () => {
    expect(pageInfo({ page: 3, limit: 20 }, 7008)).toEqual({
      page: 3,
      limit: 20,
      total: 7008,
      totalPages: 351,
    });
    expect(pageInfo({ page: 1, limit: 20 }, 0).totalPages).toBe(0);
  });
});
