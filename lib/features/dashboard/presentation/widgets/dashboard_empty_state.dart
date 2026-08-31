import 'package:Inventra/core/config/configrations.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardEmptyState extends StatelessWidget {
  const DashboardEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 60.r,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'لا توجد بيانات بعد',
              style: AppTextStyle.bold22.copyWith(
                color: AppColors.darkBlue,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'ابدأ بإنشاء أول فاتورة بيع\nلترى لوحة التحكم تعمل',
              style: AppTextStyle.regular16.copyWith(
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            AppButton(
              onPressed: () {
                AppNavigation.pushName(
                  context: context,
                  route: AppRoutes.sellingInvoiceView,
                  rootNavigator: true,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 20.r, color: AppColors.white),
                  SizedBox(width: 8.w),
                  Text(
                    'إنشاء فاتورة بيع',
                    style: AppTextStyle.medium16.copyWith(color: AppColors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}