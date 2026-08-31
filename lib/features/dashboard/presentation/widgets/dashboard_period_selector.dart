import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/features/dashboard/data/models/dashboard_metric.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardPeriodSelector extends StatelessWidget {
  final DashboardPeriod selectedPeriod;
  final ValueChanged<DashboardPeriod> onPeriodChanged;
  const DashboardPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        children: DashboardPeriod.values.map((period) {
          final isSelected = period == selectedPeriod;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: FilterChip(
              label: Text(
                period.label,
                style: AppTextStyle.medium14.copyWith(
                  color: isSelected ? AppColors.white : AppColors.primary,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onPeriodChanged(period),
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary,
              checkmarkColor: AppColors.white,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.greyMedium300,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );
        }).toList(),
      ),
    );
  }
}
