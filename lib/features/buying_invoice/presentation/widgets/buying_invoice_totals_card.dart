import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/features/buying_invoice/controller/cubit/buy_invoice_cubit.dart';
import 'package:Inventra/features/buying_invoice/controller/cubit/buy_invoice_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BuyingInvoiceTotalsCard extends StatelessWidget {
  const BuyingInvoiceTotalsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuyInvoiceCubit, BuyInvoiceState>(
      buildWhen: (previous, current) =>
          current is BuyInvoiceUpdateProductQuantity ||
          current is BuyInvoiceAddProduct ||
          current is BuyInvoiceRemoveProduct,
      builder: (context, state) {
        final cubit = context.read<BuyInvoiceCubit>();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الإجمالي', style: AppTextStyle.bold16),
                Text(
                  cubit.total.toStringAsFixed(2),
                  style: AppTextStyle.bold16.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
