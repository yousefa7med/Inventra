import 'package:Inventra/core/config/configrations.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:Inventra/core/widgets/error_state_widget.dart';
import 'package:Inventra/core/widgets/search_field.dart';
import 'package:Inventra/features/inventory/controller/cubit/inventory_cubit.dart';
import 'package:Inventra/features/inventory/presentation/widgets/products_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class InventoryView extends StatelessWidget {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            const SliverAppBar(
              pinned: true,
              floating: true,
              snap: true,
              title: CustomAppBar(
                title: 'قائمة المنتجات',
                showDrawerButton: true,
              ),
              automaticallyImplyLeading: false,
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Gap(16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: SearchField(
                      searchFunction: context
                          .read<InventoryCubit>()
                          .searchProducts,
                      hintText: 'ابحث باسم المنتج أو الباركود...',
                      showScanButton: true,
                    ),
                  ),
                  Gap(16.h),
                ],
              ),
            ),
            BlocBuilder<InventoryCubit, InventoryState>(
              buildWhen: (previous, current) =>
                  current is InventoryLoading ||
                  current is InventoryLoadingSuccessed ||
                  current is InventoryErrorState ||
                  current is ProductInsertedSuccessed,
              builder: (context, state) {
                switch (state) {
                  case InventoryLoading():
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  case InventoryLoadingSuccessed():
                    return ProductsList(products: state.products);
                  case ProductInsertedSuccessed():
                    return ProductsList(products: state.products);

                  case InventoryErrorState():
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: ErrorStateWidget(
                        message: state.message,
                        onPressed: () =>
                            context.read<InventoryCubit>().loadProducts(),
                      ),
                    );
                  default:
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            AppNavigation.pushName(
              rootNavigator: true,
              context: context,
              route: AppRoutes.productFormView,
            );
          },
          icon: const Icon(Icons.add),
          label: Text(
            'منتج',
            style: AppTextStyle.medium16.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
