import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_audio/features/hadith/presentation/widgets/marked_text.dart';

void main() {
  const highlight = TextStyle(fontWeight: FontWeight.w700);

  List<(String, bool)> parts(String snippet) => markedSpans(
    snippet,
    highlight,
  ).map((span) => (span.text!, span.style == highlight)).toList();

  test('highlights exactly the marked words', () {
    expect(
      parts('…Sesungguhnya <mark>sabar</mark> itu pada <mark>awal</mark>'),
      [
        ('…Sesungguhnya ', false),
        ('sabar', true),
        (' itu pada ', false),
        ('awal', true),
      ],
    );
  });

  test('handles a match at the start and adjacent matches', () {
    expect(parts('<mark>Amalan</mark>-<mark>amalan</mark><mark>x</mark>'), [
      ('Amalan', true),
      ('-', false),
      ('amalan', true),
      ('x', true),
    ]);
  });

  test('plain text passes through', () {
    expect(parts('tanpa tanda'), [('tanpa tanda', false)]);
  });
}
