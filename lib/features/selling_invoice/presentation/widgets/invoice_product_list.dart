import 'dart:developer';

import 'package:Inventra/core/constants/app_strings.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/features/selling_invoice/controller/cubit/sell_invoice_cubit.dart';
import 'package:Inventra/features/selling_invoice/controller/cubit/sell_invoice_state.dart';
import 'package:Inventra/features/selling_invoice/presentation/widgets/invoice_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class InvoiceProductList extends StatelessWidget {
  const InvoiceProductList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SellInvoiceCubit, SellInvoiceState>(
      buildWhen: (prev, curr) =>
          curr is SellInvoiceAddProduct ||
          curr is SellInvoiceRemoveProduct ||
          curr is SellInvoiceUpdateProductQuantity,
      builder: (context, state) {
        log("build");
        final cubit = context.read<SellInvoiceCubit>();

        if (cubit.items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppStrings.noProductsAdded,
                style: AppTextStyle.regular12.copyWith(color: AppColors.grey),
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cubit.items.length,
          separatorBuilder: (_, _) => const Gap(8),
          itemBuilder: (context, index) {
            return InvoiceItemTile(item: cubit.items[index], index: index);
          },
        );
      },
    );
  }
}
