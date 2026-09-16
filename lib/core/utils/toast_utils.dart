import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/utils/haptics.dart';

class ToastUtils {
  ToastUtils._();

  static void showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  static void showError(String message) {
    Haptics.error();
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}
