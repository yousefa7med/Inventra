import 'package:Inventra/core/helper/functions.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_global_keys.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/features/dashboard/presentation/views/dashboard_view.dart';
import 'package:Inventra/features/expenses/presentation/views/expenses_view.dart';
import 'package:Inventra/features/inventory/controller/cubit/product_cubit.dart';
import 'package:Inventra/features/operations/presentation/views/operations_view.dart';
import 'package:Inventra/features/inventory/presentation/views/inventory_view.dart';
import 'package:Inventra/features/settings/presentation/views/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: AppGlobalKeys.mainScaffold,
      drawer: const CustomDrawer(),
      body: PersistentTabView(
        tabs: _tabs(context),
        navBarBuilder: (navBarConfig) => Style8BottomNavBar(
          navBarConfig: navBarConfig,
          height: 58,
          navBarDecoration: const NavBarDecoration(
            // color: isDark(context) ? AppColors.darkSurface : Colors.white,
            color: Colors.white,
          ),
        ),
        stateManagement: false,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
      ),
    );
  }
}

List<PersistentTabConfig> _tabs(BuildContext context) => [
  PersistentTabConfig(
    screen: const DashboardView(),
    item: ItemConfig(
      icon: const Icon(Icons.dashboard_outlined),
      title: "لوحة التحكم",
      activeForegroundColor: AppColors.primary,
      inactiveForegroundColor: isDark(context) ? Colors.white70 : Colors.grey,
      textStyle: const TextStyle(fontFamily: "Cairo"),
    ),
  ),
  PersistentTabConfig(
    screen: const OperationsView(),
    item: ItemConfig(
      icon: const Icon(Icons.history_sharp),
      title: "عمليات",
      activeForegroundColor: AppColors.primary,
      inactiveForegroundColor: isDark(context) ? Colors.white70 : Colors.grey,
      textStyle: const TextStyle(fontFamily: "Cairo"),
    ),
  ),
  PersistentTabConfig(
    screen: BlocProvider(
      create: (context) => ProductCubit()..loadProducts(),
      child: const InventoryView(),
    ),
    item: ItemConfig(
      icon: const Icon(Icons.inventory_2_outlined),
      title: "المخزن",
      activeForegroundColor: AppColors.primary,
      inactiveForegroundColor: isDark(context) ? Colors.white70 : Colors.grey,
      textStyle: const TextStyle(fontFamily: "Cairo"),
    ),
  ),
  PersistentTabConfig(
    screen: const ExpensesView(),
    item: ItemConfig(
      icon: const Icon(Icons.paid_outlined),
      title: "مصاريف",
      activeForegroundColor: AppColors.primary,
      inactiveForegroundColor: isDark(context) ? Colors.white70 : Colors.grey,
      textStyle: const TextStyle(fontFamily: "Cairo"),
    ),
  ),
  // PersistentTabConfig(
  //   screen: const SafeView(),
  //   item: ItemConfig(
  //     icon: const Icon(Icons.account_balance_outlined),
  //     title: "الخزنة",
  //     activeForegroundColor: AppColors.primary,
  //     inactiveForegroundColor: isDark(context) ? Colors.white70 : Colors.grey,
  //     textStyle: TextStyle(fontFamily: "Cairo"),
  //   ),
  // ),
  PersistentTabConfig(
    screen: const SettingsView(),
    item: ItemConfig(
      icon: const Icon(Icons.settings_outlined),
      title: "الاعدادات",
      activeForegroundColor: AppColors.primary,
      inactiveForegroundColor: isDark(context) ? Colors.white70 : Colors.grey,
      textStyle: const TextStyle(fontFamily: "Cairo"),
    ),
  ),
];

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.sizeOf(context).width * 0.75, // Standard premium width
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=500',
                ),
                fit: BoxFit.cover,
                opacity: 0.15, // Subtle background pattern/texture
              ),
            ),
            currentAccountPicture: CircleAvatar(
              radius: 36.r,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 33.r,
                backgroundImage: const NetworkImage(
                  'https://i.pravatar.cc/150?img=33',
                ), // Dummy user avatar
              ),
            ),
            accountName: Text(
              'يوسف أحمد',
              style: AppTextStyle.medium16.copyWith(color: Colors.white),
            ),
            accountEmail: Text(
              'youssef.ahmed@inventra.com',
              style: AppTextStyle.regular14.copyWith(color: Colors.white70),
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard_outlined,
                  title: 'لوحة التحكم',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'المخزن والمنتجات',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'الفواتير والمبيعات',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.people_alt_outlined,
                  title: 'العملاء والزبائن',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.local_shipping_outlined,
                  title: 'الموردين والشركات',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(color: AppColors.grey, thickness: 0.5),
                ),

                _buildDrawerItem(
                  icon: Icons.analytics_outlined,
                  title: 'التقارير والإحصائيات',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'الإعدادات العامة',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22.r),
      title: Text(title, style: AppTextStyle.regular14),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Colors.grey,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      onTap: onTap,
    );
  }
}
