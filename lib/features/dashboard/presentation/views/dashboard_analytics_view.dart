import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:Inventra/features/dashboard/controller/analytics_cubit/analytics_cubit.dart';
import 'package:Inventra/features/dashboard/presentation/widgets/chart_section.dart';
import 'package:Inventra/features/dashboard/presentation/widgets/dashboard_period_selector.dart';
import 'package:Inventra/features/dashboard/presentation/widgets/kpis_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class DashboardAnalyticsView extends StatelessWidget {
  const DashboardAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'التقارير'),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const KpisSection(),
            Gap(16.h),
            DashboardPeriodSelector(
              selectedPeriod: context.read<AnalyticsCubit>().selectedPeriod,
              onPeriodChanged: (period) =>
                  context.read<AnalyticsCubit>().changePeriod(period),
            ),
            Gap(16.h),
            const ChartSection(),
          ],
        ),
      ),
    );
  }
}
