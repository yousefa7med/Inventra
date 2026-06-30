import 'dart:async';

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
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'قائمة المنتجات'),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              const Gap(16),

              SearchField(
                searchController: searchController,
                searchFunction: (query) {
                  if (timer?.isActive ?? false) {
                    timer!.cancel();
                  }
                  timer = Timer(const Duration(milliseconds: 500), () {
                    ProductCubit.get(context).filterProducts(query);
                  });
                },
                clearFunction: () {
                  searchController.clear();
                  ProductCubit.get(context).filterProducts('');
                },
              ),

              const Gap(16),

              // 5. عرض المنتجات باستخدام ListView
              BlocBuilder<ProductCubit, ProductState>(
                builder: (context, state) {
                  return Expanded(
                    child: ProductCubit.get(context).filteredProducts.isEmpty
                        ? const NoSearchResult()
                        : ListView.separated(
                            itemCount: ProductCubit.get(
                              context,
                            ).filteredProducts.length,
                            physics: const BouncingScrollPhysics(),
                            separatorBuilder: (context, index) => const Gap(12),
                            itemBuilder: (context, index) {
                              final product = ProductCubit.get(
                                context,
                              ).filteredProducts[index];
                              return ProductCard(product: product);
                            },
                          ),
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
