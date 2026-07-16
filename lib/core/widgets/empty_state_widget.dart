import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.message,
    this.actionText,
    this.onAction,
    this.icon = Icons.inbox_outlined,
  });

  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60.r, color: AppColors.greyMedium400),
          Gap(12.h),
          Text(
            message,
            style: AppTextStyle.medium16.copyWith(color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
          if (actionText != null && onAction != null) ...[
            Gap(16.h),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionText!, style: AppTextStyle.medium16),
            ),
          ],
        ],
      ),
    );
  }
}