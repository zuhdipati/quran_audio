import 'package:flutter/material.dart';
import 'package:quran_audio/core/themes/app_colors.dart';

class SearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;

  const SearchField({
    super.key,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: TextField(
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
