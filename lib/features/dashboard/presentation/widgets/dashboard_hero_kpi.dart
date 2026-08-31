import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class HeroKpiCard extends StatelessWidget {
  const HeroKpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.greyMedium200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTextStyle.medium14.copyWith(color: AppColors.grey),
          ),
          Gap(8.h),
          Text(
            formatCurrency(
              value,
              useCurrencySymbol: true,
              reduceDecimalDigits: true,
            ),
            style: AppTextStyle.bold24.copyWith(color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
