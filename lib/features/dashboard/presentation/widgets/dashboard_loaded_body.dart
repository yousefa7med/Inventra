import 'package:Inventra/features/dashboard/presentation/widgets/safe_balance_section.dart';
import 'package:Inventra/features/dashboard/presentation/widgets/dashboard_quick_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class DashboardLoadedBody extends StatelessWidget {
  const DashboardLoadedBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SafeBalanceSection(),
          Gap(12.h),
          const DashboardQuickActions(),
          Gap(16.h),
        ],
      ),
    );
  }
}
