import 'dart:async';

import 'package:Inventra/core/config/configrations.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:Inventra/core/widgets/empty_state_widget.dart';
import 'package:Inventra/core/widgets/search_field.dart';
import 'package:Inventra/features/inventory/controller/cubit/product_cubit.dart';
import 'package:Inventra/features/inventory/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class InventoryView extends StatefulWidget {
  const InventoryView({super.key});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _searchProducts(String query) {
    final cubit = context.read<ProductCubit>();
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(
      const Duration(milliseconds: 300),
      () => cubit.searchProducts(query),
    );
  }

  void _clearSearch() {
    final cubit = context.read<ProductCubit>();
    _searchController.clear();
    cubit.loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductCubit>();
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
                      searchController: _searchController,
                      searchFunction: _searchProducts,
                      clearFunction: _clearSearch,
                      hintText: 'ابحث باسم المنتج أو الباركود...',
                    ),
                  ),
                  Gap(16.h),
                ],
              ),
            ),
            BlocBuilder<ProductCubit, ProductState>(
              buildWhen: (previous, current) =>
                  current is ProductLoading ||
                  current is ProductsLoadingSuccessed ||
                  current is ProductErrorState ||
                  current is ProductInserted,
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is ProductErrorState) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            state.message,
                            style: AppTextStyle.medium16.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                          Gap(16.h),
                          ElevatedButton(
                            onPressed: () =>
                                context.read<ProductCubit>().loadProducts(),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is ProductsLoadingSuccessed ||
                    state is ProductInserted) {
                  final products = cubit.filteredProducts;

                  if (products.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyStateWidget(
                        icon: Icons.inventory_2_outlined,
                        message: cubit.searchQuery.isNotEmpty
                            ? 'لا توجد نتائج للبحث'
                            : 'لا يوجد منتجات',
                        actionText: 'إضافة منتج',
                        onAction: () => AppNavigation.pushName(
                          context: context,
                          route: AppRoutes.productFormView,
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    sliver: SliverList.separated(
                      itemCount: products.length,
                      separatorBuilder: (context, index) => Gap(12.h),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCard(product: product);
                      },
                    ),
                  );
                }

                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
          ],
        ),
      ),
    );
  }
}
