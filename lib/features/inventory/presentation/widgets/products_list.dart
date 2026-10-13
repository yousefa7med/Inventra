import 'package:Inventra/core/config/configrations.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/widgets/empty_state_widget.dart';
import 'package:Inventra/features/inventory/controller/cubit/product_cubit.dart';
import 'package:Inventra/features/inventory/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ProductsList extends StatelessWidget {
  const ProductsList( {super.key, required this.products});
  final List<ProductModel> products;
  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyStateWidget(
          icon: Icons.inventory_2_outlined,
          message: context.read<ProductCubit>().searchQuery.isNotEmpty
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
}
