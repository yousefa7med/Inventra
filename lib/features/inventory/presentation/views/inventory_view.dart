import 'dart:async';

import 'package:Inventra/core/config/configrations.dart';
import 'package:Inventra/core/helper/app_dialog.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:Inventra/features/inventory/controller/cubit/product_cubit.dart';
import 'package:Inventra/features/inventory/presentation/widgets/no_search_result.dart';
import 'package:Inventra/features/inventory/presentation/widgets/product_card.dart';
import 'package:Inventra/core/widgets/search_field.dart';
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
  Timer? timer;

  late final TextEditingController searchController;
  @override
  void initState() {
    searchController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'قائمة المنتجات',
          showDrawerButton: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              const Gap(16),

              SearchField(
                hintText: "ابحث باسم المنتج أو الباركود...",
                searchController: searchController,
                searchFunction: (query) {
                  if (timer?.isActive ?? false) {
                    timer!.cancel();
                  }
                  timer = Timer(const Duration(milliseconds: 300), () {
                    context.read<ProductCubit>().searchProducts(query);
                  });
                },
                clearFunction: () {
                  searchController.clear();
                  context.read<ProductCubit>().searchProducts('');
                },
              ),

              const Gap(16),
              // 5. عرض المنتجات باستخدام ListView
              BlocBuilder<ProductCubit, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (state is ProductError) {
                    return Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 60.r,
                              color: AppColors.error,
                            ),
                            Gap(12.h),
                            Text(
                              state.message,
                              style: AppTextStyle.medium14.copyWith(
                                color: AppColors.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Gap(16.h),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  context.read<ProductCubit>().loadProducts(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  if (state is ProductsLoaded) {
                    final products = context.read<ProductCubit>().filteredProducts;
                    return Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => context.read<ProductCubit>().loadProducts(),
                        child: products.isEmpty
                            ? const NoSearchResult()
                            : ListView.separated(
                                itemCount: products.length,
                                physics: const BouncingScrollPhysics(),
                                separatorBuilder: (context, index) =>
                                    const Gap(12),
                                itemBuilder: (context, index) {
                                  final product = products[index];
                                  return ProductCardWithEdit(
                                    product: product,
                                    onEditTap: () async {
                                      await AppNavigation.pushName(
                                        rootNavigator: true,
                                        context: context,
                                        route: AppRoutes.productFormView,
                                        argument: product,
                                      );
                                      if (!context.mounted) return;
                                      context.read<ProductCubit>().loadProducts();
                                    },
                                    onDeleteTap: () {
                                      appDialog(
                                        context: context,
                                        title: 'تأكيد الحذف',
                                        content:
                                            'هل أنت متأكد من حذف "${product.name}"؟',
                                        msg: "حذف",
                                        action: () {
                                          context.read<ProductCubit>().deleteProduct(product);
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    );
                  }
                  return const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }
}