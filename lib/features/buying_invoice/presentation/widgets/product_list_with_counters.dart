import 'package:Inventra/core/constants/app_strings.dart';
import 'package:Inventra/core/widgets/empty_state_widget.dart';
import 'package:Inventra/features/buying_invoice/controller/cubit/buy_invoice_cubit.dart';
import 'package:Inventra/features/buying_invoice/presentation/widgets/product_card_with_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductListWithCountersSliver extends StatelessWidget {
  const ProductListWithCountersSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuyInvoiceCubit, dynamic>(
      builder: (context, state) {
        final cubit = context.read<BuyInvoiceCubit>();

        if (cubit.products.isEmpty) {
          return const SliverToBoxAdapter(
            child: EmptyStateWidget(
              icon: Icons.production_quantity_limits_outlined,
              message: AppStrings.noProductsFound,
            ),
          );
        }

        return SliverPadding(
          sliver: SliverList.builder(
            itemCount: cubit.products.length,
            itemBuilder: (context, index) {
              return ProductCardWithCounter(product: cubit.products[index]);
            },
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        );
      },
    );
  }
}