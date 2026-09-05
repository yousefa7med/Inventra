import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:Inventra/core/widgets/error_state_widget.dart';
import 'package:Inventra/features/dashboard/controller/cubit/dashboard_cubit.dart';
import 'package:Inventra/features/dashboard/controller/cubit/dashboard_state.dart';
import 'package:Inventra/features/dashboard/data/models/dashboard_metric.dart';
import 'package:Inventra/features/dashboard/presentation/widgets/dashboard_chart.dart';
import 'package:Inventra/features/dashboard/presentation/widgets/dashboard_hero_kpi.dart';
import 'package:Inventra/features/dashboard/presentation/widgets/dashboard_loading_skeleton.dart';
import 'package:Inventra/features/dashboard/presentation/widgets/dashboard_metric_kpi.dart';
import 'package:Inventra/features/dashboard/presentation/widgets/dashboard_no_data_state.dart';
import 'package:Inventra/features/dashboard/presentation/widgets/dashboard_period_selector.dart';
import 'package:Inventra/features/dashboard/presentation/widgets/dashboard_primary_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      buildWhen: (previous, current) {
        return current is DashboardLoaded ||
            current is DashboardLoading ||
            current is DashboardError;
      },
      builder: (context, state) {
        return Scaffold(
          appBar: const CustomAppBar(
            title: 'لوحة التحكم',
            showDrawerButton: true,
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, DashboardState state) {
    if (state is DashboardLoading) {
      return const DashboardLoadingSkeleton();
    }

    if (state is DashboardError) {
      return ErrorStateWidget(
        message: state.message,
        onPressed: () => context.read<DashboardCubit>().refresh(),
      );
    }

    if (state is DashboardLoaded) {
      final selectedMetric = state.selectedMetric;
      final selectedPeriod = state.selectedPeriod;
      final snapshot = state.snapshot;

      return RefreshIndicator(
        onRefresh: () async => context.read<DashboardCubit>().refresh(),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeroKpiCard(
                title: 'الرصيد الحالي',
                value: 50,
                color: AppColors.primary,
              ),
              Gap(12.h),

              GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 12,
                  childAspectRatio: 3 / 2,
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  DashboardMetricKpi(
                    metric: DashboardMetric.netProfit,
                    value: snapshot.kpis.netProfit,
                    isSelected: selectedMetric == DashboardMetric.netProfit,
                  ),
                  DashboardMetricKpi(
                    metric: DashboardMetric.sales,
                    value: snapshot.kpis.sales,
                    isSelected: selectedMetric == DashboardMetric.sales,
                  ),
                  DashboardMetricKpi(
                    metric: DashboardMetric.purchases,
                    value: snapshot.kpis.purchases,
                    isSelected: selectedMetric == DashboardMetric.purchases,
                  ),
                  DashboardMetricKpi(
                    metric: DashboardMetric.expenses,
                    value: snapshot.kpis.expenses,
                    isSelected: selectedMetric == DashboardMetric.expenses,
                  ),
                ],
              ),
              Gap(12.h),
              DashboardPeriodSelector(
                selectedPeriod: state.selectedPeriod,
                onPeriodChanged: (period) =>
                    context.read<DashboardCubit>().changePeriod(period),
              ),
              Gap(16.h),

              if (snapshot.charts[selectedMetric]!.isEmpty)
                DashboardNoDataState(
                  periodLabel: selectedPeriod.label,
                  metricLabel: selectedMetric.label,
                )
              else
                DashboardChart(
                  points: snapshot.charts[selectedMetric]!,
                  color: selectedMetric.metricColor,
                  selectedPeriod: selectedPeriod,
                  isNetProfit: selectedMetric == DashboardMetric.netProfit,
                ),
              Gap(24.h),

              // Primary Action
              const DashboardPrimaryAction(),
              Gap(32.h),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
