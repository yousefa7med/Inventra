import 'package:Inventra/core/config/configrations.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardPrimaryAction extends StatelessWidget {
  const DashboardPrimaryAction({super.key});

  @override
  Widget build(BuildContext context) {
    return AppButton(
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
          Icon(Icons.point_of_sale, size: 20.r, color: AppColors.white),
          SizedBox(width: 8.w),
          Text(
            'فاتورة بيع',
            style: AppTextStyle.medium16.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
}
}