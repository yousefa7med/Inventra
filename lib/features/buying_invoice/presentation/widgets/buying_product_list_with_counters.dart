import 'package:Inventra/core/constants/app_strings.dart';
import 'package:Inventra/core/widgets/empty_state_widget.dart';
import 'package:Inventra/features/buying_invoice/controller/cubit/buy_invoice_cubit.dart';
import 'package:Inventra/features/buying_invoice/controller/cubit/buy_invoice_state.dart';
import 'package:Inventra/features/buying_invoice/presentation/widgets/buying_product_card_with_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BuyingProductListWithCounters extends StatelessWidget {
  const BuyingProductListWithCounters({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuyInvoiceCubit, BuyInvoiceState>(
      builder: (context, state) {
        final cubit = context.read<BuyInvoiceCubit>();

        if (cubit.products.isEmpty && state is! BuyInvoiceLoading) {
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
              return BuyingProductCardWithCounter(
                product: cubit.products[index],
              );
            },
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        );
      },
    );
  }
}
