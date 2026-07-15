import 'dart:developer';

import 'package:Inventra/core/helper/functions.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_global_keys.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/widgets/app_drawer.dart';
import 'package:Inventra/features/dashboard/presentation/views/dashboard_view.dart';
import 'package:Inventra/features/inventory/controller/cubit/product_cubit.dart';
import 'package:Inventra/features/operations/presentation/views/operations_view.dart';
import 'package:Inventra/features/inventory/presentation/views/inventory_view.dart';
import 'package:Inventra/features/safe/presentation/views/safe_view.dart';
import 'package:Inventra/features/safe/controller/cubit/safe_cubit.dart';
import 'package:Inventra/features/settings/presentation/views/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: AppGlobalKeys.mainScaffold,
      drawer: const AppDrawer(),
      resizeToAvoidBottomInset: false,
      body: PersistentTabView(
        onTabChanged: (value) {
          if (value == 2) {
            GetIt.instance<ProductCubit>().loadProducts();
          }
          if (value == 3) {
            GetIt.instance<SafeCubit>().load();
          }
          log(value.toString());
        },
        stateManagement: false,
        tabs: _tabs(context),
        navBarBuilder: (navBarConfig) => Style8BottomNavBar(
          navBarConfig: navBarConfig,
          height: 58,
          navBarDecoration: const NavBarDecoration(color: AppColors.white),
        ),
        handleAndroidBackButtonPress: true,
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
      inactiveForegroundColor: isDark(context)
          ? AppColors.white70
          : AppColors.grey,
      textStyle: AppTextStyle.navBar,
    ),
  ),
  PersistentTabConfig(
    screen: const OperationsView(),
    item: ItemConfig(
      icon: const Icon(Icons.history_sharp),
      title: "عمليات",
      activeForegroundColor: AppColors.primary,
      inactiveForegroundColor: isDark(context)
          ? AppColors.white70
          : AppColors.grey,
      textStyle: AppTextStyle.navBar,
    ),
  ),
  PersistentTabConfig(
    screen: BlocProvider.value(
      value: GetIt.instance<ProductCubit>()..loadProducts(),
      child: const InventoryView(),
    ),
    item: ItemConfig(
      icon: const Icon(Icons.inventory_2_outlined),
      title: "المخزن",
      activeForegroundColor: AppColors.primary,
      inactiveForegroundColor: isDark(context)
          ? AppColors.white70
          : AppColors.grey,
      textStyle: AppTextStyle.navBar,
    ),
  ),
  PersistentTabConfig(
    screen: BlocProvider.value(
      value: GetIt.instance<SafeCubit>()..load(),
      child: const SafeView(),
    ),
    item: ItemConfig(
      icon: const Icon(Icons.account_balance_wallet_outlined),
      title: "الخزنة",
      activeForegroundColor: AppColors.primary,
      inactiveForegroundColor: isDark(context)
          ? AppColors.white70
          : AppColors.grey,
      textStyle: AppTextStyle.navBar,
    ),
  ),
  PersistentTabConfig(
    screen: const SettingsView(),
    item: ItemConfig(
      icon: const Icon(Icons.settings_outlined),
      title: "الاعدادات",
      activeForegroundColor: AppColors.primary,
      inactiveForegroundColor: isDark(context)
          ? AppColors.white70
          : AppColors.grey,
      textStyle: AppTextStyle.navBar,
    ),
  ),
];
