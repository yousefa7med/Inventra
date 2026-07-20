import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/features/buying_invoice/controller/cubit/buy_invoice_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InvoiceTotalsCard extends StatelessWidget {
  const InvoiceTotalsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuyInvoiceCubit, dynamic>(
      builder: (context, state) {
        final cubit = context.read<BuyInvoiceCubit>();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('المجموع الفرعي', style: AppTextStyle.regular16),
                    Text(
                      '${cubit.subtotal.toStringAsFixed(2)}',
                      style: AppTextStyle.bold16,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الإجمالي', style: AppTextStyle.bold18),
                    Text(
                      '${cubit.total.toStringAsFixed(2)}',
                      style: AppTextStyle.bold18.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}