import 'package:Inventra/core/config/configrations.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: [
            Row(
              spacing: 8.w,
              children: [
                Expanded(
                  child: QuickActionItem(
                    label: 'فاتورة بيع',
                    icon: Icons.shopping_cart_checkout_rounded,
                    color: AppColors.success,
                    onTap: () => AppNavigation.pushName(
                      context: context,
                      route: AppRoutes.sellingInvoiceView,
                      rootNavigator: true,
                    ),
                  ),
                ),
                Expanded(
                  child: QuickActionItem(
                    label: 'فاتورة شراء',
                    icon: Icons.add_shopping_cart,
                    color: AppColors.secondary,
                    onTap: () => AppNavigation.pushName(
                      context: context,
                      route: AppRoutes.buyingInvoiceView,
                      rootNavigator: true,
                    ),
                  ),
                ),
                Expanded(
                  child: QuickActionItem(
                    label: 'مصروف',
                    icon: Icons.receipt_long,
                    color: AppColors.error,
                    onTap: () => AppNavigation.pushName(
                      context: context,
                      route: AppRoutes.addExpenseView,
                      rootNavigator: true,
                    ),
                  ),
                ),
              ],
            ),
            Gap(8.h),
            Row(
              spacing: 8.w,
              children: [
                Expanded(
                  child: QuickActionItem(
                    label: 'مورد جديد',
                    icon: Icons.local_shipping_outlined,
                    color: AppColors.warning,
                    onTap: () => AppNavigation.pushName(
                      context: context,
                      route: AppRoutes.supplierFormView,
                      rootNavigator: true,
                    ),
                  ),
                ),
                Expanded(
                  child: QuickActionItem(
                    label: 'عميل جديد',
                    icon: Icons.person_add_outlined,
                    color: AppColors.primary,
                    onTap: () => AppNavigation.pushName(
                      context: context,
                      route: AppRoutes.customerFormView,
                      rootNavigator: true,
                    ),
                  ),
                ),
                Expanded(
                  child: QuickActionItem(
                    label: 'التحليلات',
                    icon: Icons.analytics_outlined,
                    color: AppColors.darkBlue,
                    onTap: () => AppNavigation.pushName(
                      context: context,
                      route: AppRoutes.dashboardAnalytics,
                      rootNavigator: true,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionItem extends StatelessWidget {
  const QuickActionItem({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26.sp),
            Gap(8.h),
            Text(
              label,
              style: AppTextStyle.medium14.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
