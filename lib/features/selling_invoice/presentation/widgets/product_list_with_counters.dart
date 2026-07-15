import 'package:Inventra/core/constants/app_strings.dart';
import 'package:Inventra/core/widgets/empty_state.dart';
import 'package:Inventra/features/selling_invoice/controller/cubit/sell_invoice_cubit.dart';
import 'package:Inventra/features/selling_invoice/controller/cubit/sell_invoice_state.dart';
import 'package:Inventra/features/selling_invoice/presentation/widgets/product_card_with_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ProductListWithCountersSliver extends StatelessWidget {
  const ProductListWithCountersSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SellInvoiceCubit, SellInvoiceState>(
      builder: (context, state) {
        final cubit = context.read<SellInvoiceCubit>();

        if (cubit.products.isEmpty && state is! SellInvoiceLoading) {
          return const SliverToBoxAdapter(
            child: EmptyState(
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
