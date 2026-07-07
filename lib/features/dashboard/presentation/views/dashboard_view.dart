import 'package:Inventra/core/config/configrations.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:Inventra/features/dashboard/presentation/widgets/dashboard_grid_card.dart';
import 'package:Inventra/features/dashboard/presentation/widgets/dashboard_list_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "لوحة التحكم", showDrawerButton: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const Gap(10),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.6,
                ),
                children: const [
                  DashBoardGridCard(
                    title: 'المكسب',
                    number: 50.622,
                    color: AppColors.primary,
                  ),
                  DashBoardGridCard(
                    title: 'المبيعات',
                    number: 50.622,
                    color: AppColors.grey,
                  ),
                  DashBoardGridCard(
                    title: 'المصاريف',
                    number: 50.622,
                    color: AppColors.red,
                  ),
                  DashBoardGridCard(
                    title: 'يوسف احمد',
                    number: 50.622,
                    color: AppColors.success,
                  ),
                ],
              ),
              const Gap(16),
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),

                children: [
                  DashboardListCard(
                    title: "اضافة فاتورة",
                    onPressed: () {
                      AppNavigation.pushName(
                        context: context,
                        route: AppRoutes.addInvoiceView,
                        rootNavigator: true,
                      );
                    },
                    icon: Icons.shop,
                    iconColor: AppColors.white,
                    iconBackgronud: AppColors.secondary,
                  ),
                  DashboardListCard(
                    title: "اضافة منتج",
                    onPressed: () {
                      AppNavigation.pushName(
                        rootNavigator: true,
                        context: context,
                        route: AppRoutes.addproductView,
                      );
                    },
                    icon: Icons.shop,
                    iconColor: AppColors.darkRed,
                    iconBackgronud: AppColors.lightRed,
                  ),
                  DashboardListCard(
                    title: "اضافة عميل",
                    onPressed: () {
                      AppNavigation.pushName(
                        rootNavigator: true,

                        context: context,
                        route: AppRoutes.addcustomerView,
                      );
                    },
                    icon: Icons.shop,
                    iconColor: AppColors.white,
                    iconBackgronud: AppColors.secondary,
                  ),
                  DashboardListCard(
                    title: "اضافة مورد",
                    onPressed: () {
                      AppNavigation.pushName(
                        rootNavigator: true,

                        context: context,
                        route: AppRoutes.addsupplierView,
                      );
                    },
                    icon: Icons.shop,
                    iconColor: AppColors.darkRed,
                    iconBackgronud: AppColors.lightRed,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
