import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/utils/formatters.dart';
import 'package:Inventra/features/dashboard/controller/cubit/dashboard_cubit.dart';
import 'package:Inventra/features/dashboard/controller/cubit/dashboard_state.dart';
import 'package:Inventra/features/dashboard/data/enums/dashboard_metric.dart';
import 'package:Inventra/features/dashboard/data/models/kpi_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class KpisSection extends StatelessWidget {
  const KpisSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<DashboardCubit, DashboardState, _KpiSectionData>(
      selector: (state) {
        if (state is DashboardLoaded) {
          return _KpiSectionData(
            kpis: state.snapshot.kpis,
            selectedMetric: state.selectedMetric,
          );
        }
        return _KpiSectionData(
          kpis: KpiModel(netProfit: 0, sales: 0, purchases: 0, expenses: 0),
          selectedMetric: DashboardMetric.netProfit,
        );
      },
      builder: (context, sectionData) {
        return GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: 12,
            childAspectRatio: 3 / 2,
            crossAxisCount: 2,
            crossAxisSpacing: 12,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _DashboardMetricKpi(
              metric: DashboardMetric.netProfit,
              value: sectionData.kpis.netProfit,
              isSelected:
                  sectionData.selectedMetric == DashboardMetric.netProfit,
            ),
            _DashboardMetricKpi(
              metric: DashboardMetric.sales,
              value: sectionData.kpis.sales,
              isSelected: sectionData.selectedMetric == DashboardMetric.sales,
            ),
            _DashboardMetricKpi(
              metric: DashboardMetric.purchases,
              value: sectionData.kpis.purchases,
              isSelected:
                  sectionData.selectedMetric == DashboardMetric.purchases,
            ),
            _DashboardMetricKpi(
              metric: DashboardMetric.expenses,
              value: sectionData.kpis.expenses,
              isSelected:
                  sectionData.selectedMetric == DashboardMetric.expenses,
            ),
          ],
        );
      },
    );
  }
}

class _DashboardMetricKpi extends StatelessWidget {
  const _DashboardMetricKpi({
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

class _KpiSectionData {
  final KpiModel kpis;
  final DashboardMetric selectedMetric;

  const _KpiSectionData({required this.kpis, required this.selectedMetric});
}
