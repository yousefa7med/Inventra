import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/features/dashboard/controller/cubit/dashboard_cubit.dart';
import 'package:Inventra/features/dashboard/presentation/widgets/chart_section.dart';
import 'package:Inventra/features/dashboard/presentation/widgets/safe_balance_section.dart';
import 'package:Inventra/features/dashboard/presentation/widgets/kpis_section.dart';
import 'package:Inventra/features/dashboard/presentation/widgets/dashboard_period_selector.dart';
import 'package:Inventra/features/dashboard/presentation/widgets/dashboard_primary_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class DashboardLoadedBody extends StatelessWidget {
  const DashboardLoadedBody({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => context.read<DashboardCubit>().refresh(),

      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SafeBalanceSection(),
            Gap(12.h),
            const KpisSection(),

            Gap(12.h),
            DashboardPeriodSelector(
              selectedPeriod: context.read<DashboardCubit>().selectedPeriod,
              onPeriodChanged: (period) =>
                  context.read<DashboardCubit>().changePeriod(period),
            ),
            Gap(16.h),
            const ChartSection(),
            Gap(24.h),

            // Primary Action
            const DashboardPrimaryAction(),
            Gap(32.h),
          ],
        ),
      ),
    );
  }
}
