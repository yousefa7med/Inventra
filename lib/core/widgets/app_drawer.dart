import 'package:Inventra/core/config/configrations.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/utilities/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
      child: Drawer(
        width: MediaQuery.sizeOf(context).width * 0.75,
        child: Column(
          children: [
            const _DrawerHeader(),
            const _DrawerDivider(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerItem(
                    icon: Icons.people_outline,
                    title: 'جميع العملاء',
                    onTap: () {
                      AppNavigation.pushName(
                        context: context,
                        route: AppRoutes.allCustomers,
                      );
                   
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.local_shipping_outlined,
                    title: 'جميع الموردين',
                    onTap: () {
                      AppNavigation.pushName(
                        context: context,
                        route: AppRoutes.allSuppliers,
                      );
                  
                    },
                  ),
_DrawerItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'فواتير المشتريات',
                    onTap: () {
                      AppNavigation.pushName(
                        context: context,
                        route: AppRoutes.buyingInvoiceView,
                      );
                      
                    },
                  ),
                  const _DrawerDivider(),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    title: 'الاعدادات',
                    onTap: () {
                      AppNavigation.pushName(
                        context: context,
                        route: AppRoutes.settings,
                      );
              
                    },
                  ),
                  const _DrawerDivider(),
                  const _FutureFeaturesPlaceholder(),
                ],
              ),
            ),
            const _DrawerFooter(),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 125.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 32.r,
            backgroundColor: AppColors.white,
            child: SvgPicture.asset(
              Assets.imagesSvgLogo,
              width: 40.r,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.modulate,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Inventra',
                  style: AppTextStyle.bold20.copyWith(color: AppColors.white),
                ),
                SizedBox(height: 4.h),
                Text(
                  'نظام إدارة المخزون',
                  style: AppTextStyle.regular14.copyWith(
                    color: AppColors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerDivider extends StatelessWidget {
  const _DrawerDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1.h,
      thickness: 1.h,
      color: AppColors.greyMedium200,
      indent: 16.w,
      endIndent: 16.w,
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 24.sp, color: AppColors.grey),
      title: Text(title, style: AppTextStyle.medium16),
      trailing: Icon(
        Icons.chevron_left,
        size: 24.sp,
        color: AppColors.greyMedium400,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      hoverColor: AppColors.greyLight100,
      splashColor: AppColors.primary.withValues(alpha: 0.1),
    );
  }
}

class _FutureFeaturesPlaceholder extends StatelessWidget {
  const _FutureFeaturesPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'قريباً',
            style: AppTextStyle.medium14.copyWith(
              color: AppColors.greyMedium500,
            ),
          ),
          SizedBox(height: 12.h),
          const _FutureItem(
            icon: Icons.local_shipping_outlined,
            title: 'فواتير المرتجعات',
            subtitle: 'قريباً',
          ),
          SizedBox(height: 8.h),
          const _FutureItem(
            icon: Icons.analytics_outlined,
            title: 'التقارير المتقدمة',
            subtitle: 'قريباً',
          ),
          SizedBox(height: 8.h),
          const _FutureItem(
            icon: Icons.people_outline,
            title: 'إدارة المستخدمين',
            subtitle: 'قريباً',
          ),
        ],
      ),
    );
  }
}

class _FutureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FutureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: AppColors.greyMedium400),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyle.regular14.copyWith(
                  color: AppColors.greyMedium500,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyle.regular12.copyWith(
                  color: AppColors.greyMedium400,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            'جديد',
            style: AppTextStyle.medium12.copyWith(color: AppColors.warning),
          ),
        ),
      ],
    );
  }
}

class _DrawerFooter extends StatelessWidget {
  const _DrawerFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.greyLight100,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20.sp,
                color: AppColors.greyMedium500,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'إصدار التطبيق 1.0.0',
                  style: AppTextStyle.regular14.copyWith(
                    color: AppColors.greyMedium500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                Icons.copyright,
                size: 20.sp,
                color: AppColors.greyMedium500,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'جميع الحقوق محفوظة © 2024',
                  style: AppTextStyle.regular14.copyWith(
                    color: AppColors.greyMedium500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
