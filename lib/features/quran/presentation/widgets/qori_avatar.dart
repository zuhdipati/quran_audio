import 'package:flutter/material.dart';
import 'package:quran_audio/core/themes/app_colors.dart';

/// Reciter photo with a monogram fallback for reciters without one.
class QoriAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double size;

  const QoriAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.size = 44,
  });

  // Wikimedia rejects requests without a descriptive user agent
  static const _headers = {
    'User-Agent':
        'QuranAudioApp/1.0 (https://github.com/zuhdipati/quran_audio)',
  };

  @override
  Widget build(BuildContext context) {
    final monogram = _Monogram(name: name, size: size);
    final url = photoUrl;

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.45)),
      ),
      child: ClipOval(
        child: url == null
            ? monogram
            : Image.network(
                url,
                headers: _headers,
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.4),
                cacheWidth: (size * 3).round(),
                errorBuilder: (_, _, _) => monogram,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : monogram,
              ),
      ),
    );
  }
}

class _Monogram extends StatelessWidget {
  final String name;
  final double size;

  const _Monogram({required this.name, required this.size});

  String get _initials {
    final words = name
        .replaceAll(RegExp(r'\(.*?\)'), '')
        .split(RegExp(r'[\s-]+'))
        .where((w) => w.isNotEmpty && w[0].toUpperCase() != w[0].toLowerCase())
        .where(
          (w) => !const {
            'al',
            'ar',
            'as',
            'ash',
            'ad',
            'adh',
            'ath',
            'az',
            'el',
            'bin',
            'ibn',
          }.contains(w.toLowerCase()),
        )
        .toList();
    if (words.isEmpty) return '؟';
    final first = words.first[0];
    final last = words.length > 1 ? words.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceHigh,
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: size * 0.34,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
