import 'package:Inventra/core/constants/app_strings.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/features/buying_invoice/controller/cubit/buy_invoice_cubit.dart';
import 'package:Inventra/features/buying_invoice/controller/cubit/buy_invoice_state.dart';
import 'package:Inventra/features/buying_invoice/presentation/widgets/buying_invoice_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class BuyingInvoiceProductList extends StatelessWidget {
  const BuyingInvoiceProductList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuyInvoiceCubit, BuyInvoiceState>(
      buildWhen: (prev, curr) =>
          curr is BuyInvoiceAddProductItem ||
          curr is BuyInvoiceRemoveProduct ||
          curr is BuyInvoiceUpdateProductQuantity,
      builder: (context, state) {
        final cubit = context.read<BuyInvoiceCubit>();

        if (cubit.items.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  AppStrings.noProductsAdded,
                  style: AppTextStyle.regular12.copyWith(color: AppColors.grey),
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.separated(
            itemCount: cubit.items.length,
            separatorBuilder: (_, _) => const Gap(8),
            itemBuilder: (context, index) {
              return BuyingInvoiceItemTile(
                item: cubit.items[index],
                index: index,
              );
            },
          ),
        );
      },
    );
  }
}
