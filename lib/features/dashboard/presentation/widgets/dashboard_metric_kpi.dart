import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/utils/formatters.dart';
import 'package:Inventra/features/dashboard/controller/cubit/dashboard_cubit.dart';
import 'package:Inventra/features/dashboard/data/models/dashboard_metric.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class DashboardMetricKpi extends StatelessWidget {
  const DashboardMetricKpi({
    super.key,
    required this.metric,
    required this.value,
    required this.isSelected,
  });

  final DashboardMetric metric;
  final double value;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<DashboardCubit>().changeChartMetric(metric);
      },
      borderRadius: BorderRadius.circular(16.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? metric.metricColor : AppColors.greyMedium200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: metric.metricColor.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: metric.metricColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Gap(8.w),
                Expanded(
                  child: Text(
                    metric.label,
                    style: AppTextStyle.medium14.copyWith(
                      color: AppColors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            FittedBox(
              child: Text(
                formatCurrency(
                value,
                  useCurrencySymbol: true,
                  reduceDecimalDigits: true,
                ),
                style: AppTextStyle.bold20.copyWith(color: metric.metricColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
