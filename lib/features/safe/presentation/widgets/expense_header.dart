import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/features/safe/data/models/expense_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class ExpenseHeader extends StatelessWidget {
  final ExpenseHeaderItem headerItem;

  const ExpenseHeader({super.key, required this.headerItem});

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) return 'اليوم';
    if (targetDate == yesterday) return 'أمس';
    return DateFormat('EEEE، d MMMM', 'ar').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
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
      ],
    );
  }
}
