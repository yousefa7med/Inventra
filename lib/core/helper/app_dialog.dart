import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:flutter/material.dart';

void appDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String msg,
  required void Function() action,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(16),
      ),
      title: Text(title, style: AppTextStyle.bold18),
      content: Text(content, style: AppTextStyle.regular14, maxLines: 2),
      actions: [
        TextButton(
          onPressed: () {
            AppNavigation.pop(context: ctx);
          },
          child: const Text(
            "إلغاء",
            style: TextStyle(color: AppColors.primary),
          ),
        ),
        TextButton(
          onPressed: () async {
            AppNavigation.pop(context: ctx);

            action();
          },
          style: TextButton.styleFrom(foregroundColor: AppColors.error),

          child: Text(msg, style: AppTextStyle.regular14),
        ),
      ],
    ),
  );
}
