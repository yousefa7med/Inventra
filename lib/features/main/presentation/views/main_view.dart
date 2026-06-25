import 'package:Inventra/core/helper/functions.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/features/dashboard/presentation/views/dashboard_view.dart';
import 'package:Inventra/features/expenses/presentation/views/expenses_view.dart';
import 'package:Inventra/features/operations/presentation/views/operations_view.dart';
import 'package:Inventra/features/inventory/presentation/views/inventory_view.dart';
import 'package:Inventra/features/settings/presentation/views/settings_view.dart';
import 'package:flutter/material.dart';

import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});
  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      tabs: _tabs(context),
      navBarBuilder: (navBarConfig) => Style8BottomNavBar(
        navBarConfig: navBarConfig,
        height: 58,
        navBarDecoration: const NavBarDecoration(
          // color: isDark(context) ? AppColors.darkSurface : Colors.white,
          color: Colors.white,
        ),
      ),

      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
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
    screen: const InventoryView(),
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
