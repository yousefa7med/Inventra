import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/features/dashboard/controller/cubit/dashboard_cubit.dart';
import 'package:Inventra/features/dashboard/controller/cubit/dashboard_state.dart';
import 'package:Inventra/features/dashboard/data/enums/dashboard_metric.dart';
import 'package:Inventra/features/dashboard/data/enums/dashboard_period.dart';
import 'package:Inventra/features/dashboard/data/models/chart_point.dart';
import 'package:Inventra/features/dashboard/presentation/widgets/dashboard_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChartSection extends StatelessWidget {
  const ChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<DashboardCubit, DashboardState, _ChartSectionData>(
      selector: (state) {
        if (state is DashboardLoaded) {
          final metric = state.selectedMetric;

          return _ChartSectionData(
            metric: state.selectedMetric,
            points: state.snapshot.charts[metric] ?? [],
            period: state.selectedPeriod,
          );
        }
        return const _ChartSectionData(
          metric: DashboardMetric.netProfit,
          points: [],
          period: DashboardPeriod.today,
        );
      },
      builder: (context, sectionData) {
        if (sectionData.points.isEmpty) {
          return _DashboardNoDataState(
            periodLabel: sectionData.period.label,
            metricLabel: sectionData.metric.label,
          );
        } else {
          return DashboardChart(
            points: sectionData.points,
            color: sectionData.metric.metricColor,
            selectedPeriod: sectionData.period,
            isNetProfit: sectionData.metric == DashboardMetric.netProfit,
          );
        }
      },
    );
  }
}

class _DashboardNoDataState extends StatelessWidget {
  const _DashboardNoDataState({
    required this.periodLabel,
    required this.metricLabel,
  });

  final String periodLabel;
  final String metricLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_outlined,
                size: 40.r,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد $metricLabel',
              style: AppTextStyle.bold18.copyWith(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'خلال $periodLabel',
              style: AppTextStyle.regular16.copyWith(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartSectionData {
  final DashboardMetric metric;
  final List<ChartPoint> points;
  final DashboardPeriod period;

  const _ChartSectionData({
    required this.metric,
    required this.points,
    required this.period,
  });
}
