import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:flutter/material.dart';

bool isDark(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}

void showSnackBar(BuildContext context, String message, {Color? color}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: color ?? AppColors.snackBarDefault,
      duration: const Duration(seconds: 2),
      content: Text(
        message,
        style: AppTextStyle.medium14.copyWith(color: AppColors.white),
        textAlign: TextAlign.center,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      margin: const EdgeInsets.only(right: 30, left: 30, bottom: 30),
      elevation: 6,
    ),
  );
}
