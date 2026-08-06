import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/utils/formatters.dart';
import 'package:Inventra/features/transactions/data/models/list_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class DateHeader extends StatelessWidget {
  final HeaderItem headerItem;

  const DateHeader({super.key, required this.headerItem});

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) return 'اليوم';
    if (targetDate == yesterday) return 'أمس';
    return DateFormat('EEEE، d MMMM', 'ar').format(date);
  }

  Color _getTotalColor(double total) {
    if (total > 0) return AppColors.success;
    if (total < 0) return AppColors.error;
    return AppColors.greyMedium500;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 4.r,
            height: 20.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Gap(10.w),
          Expanded(
            child: Text(
              _getDateLabel(headerItem.date),
              style: AppTextStyle.bold14.copyWith(color: AppColors.primary),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '${headerItem.count} عملية',
              style: AppTextStyle.medium11.copyWith(color: AppColors.primary),
            ),
          ),
          Gap(12.w),
          Text(
            formatCurrency(headerItem.total),
            style: AppTextStyle.bold14.copyWith(
              color: _getTotalColor(headerItem.total),
            ),
          ),
        ],
      ),
    );
  }
}
