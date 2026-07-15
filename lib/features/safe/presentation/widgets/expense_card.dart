import 'package:Inventra/core/models/expense_model.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class ExpenseCard extends StatelessWidget {
  const ExpenseCard({super.key, required this.expense});

  final ExpenseModel expense;

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} ج.م';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: AppColors.lightRed,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.receipt_outlined,
                color: AppColors.error,
                size: 20.r,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.note,
                    style: AppTextStyle.medium14,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(4),
                  Text(
                    DateFormat('dd/MM/yyyy - hh:mm a').format(expense.date),
                    style: AppTextStyle.regular14.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '-${_formatCurrency(expense.value)}',
              style: AppTextStyle.semiBold16.copyWith(color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }
}
