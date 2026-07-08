import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balance,
    required this.isNegative,
    required this.onEditTap,
  });

  final double balance;
  final bool isNegative;
  final VoidCallback onEditTap;

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} ج.م';
  }

  @override
  Widget build(BuildContext context) {
     
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: isNegative ? AppColors.lightRed : AppColors.white,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الرصيد الحالي', style: AppTextStyle.medium16),
                TextButton.icon(
                  onPressed: onEditTap,
                  icon: const Icon(Icons.edit, size: 18),
                  label: Text('تعديل', style: AppTextStyle.medium14),
                ),
              ],
            ),
            const Gap(8),
            Text(
              _formatCurrency(balance),
              style: AppTextStyle.bold26.copyWith(
                color: isNegative ? AppColors.error : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
