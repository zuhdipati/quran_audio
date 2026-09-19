import 'package:flutter/material.dart';

/// A search snippet from the hadith API, where each matched word arrives
/// wrapped in `<mark>` and `</mark>`, drawn with the matches highlighted.
class MarkedText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextStyle highlightStyle;
  final int? maxLines;

  const MarkedText(
    this.text, {
    super.key,
    required this.style,
    required this.highlightStyle,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(style: style, children: markedSpans(text, highlightStyle)),
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
  }
}

/// Splits [text] at its mark tags. Tags alternate open and close, so every
/// other part is a match.
List<TextSpan> markedSpans(String text, TextStyle highlightStyle) {
  final spans = <TextSpan>[];
  var marked = false;
  for (final part in text.split(RegExp('</?mark>'))) {
    if (part.isNotEmpty) {
      spans.add(TextSpan(text: part, style: marked ? highlightStyle : null));
    }
    marked = !marked;
  }
  return spans;
}
