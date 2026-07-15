import 'package:Inventra/core/constants/app_strings.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/widgets/app_text_field.dart';
import 'package:Inventra/features/selling_invoice/controller/cubit/sell_invoice_cubit.dart';
import 'package:Inventra/features/selling_invoice/controller/cubit/sell_invoice_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class InvoiceTotalsCard extends StatelessWidget {
  const InvoiceTotalsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SellInvoiceCubit, SellInvoiceState>(
      buildWhen: (previous, current) =>
          current is SellInvoiceUpdateProductQuantity ||
          current is SellInvoiceAddProduct ||
          current is SellInvoiceRemoveProduct ||
          current is SellInvoiceDiscountChanged,
      builder: (context, state) {
        final cubit = context.read<SellInvoiceCubit>();
        final formatter = NumberFormat.currency(locale: 'ar_EG', symbol: '');

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppStrings.subtotal, style: AppTextStyle.bold14),
                    Text(
                      '${formatter.format(cubit.subtotal)} ${AppStrings.egp}',
                      style: AppTextStyle.bold14,
                    ),
                  ],
                ),
                const Gap(12),
                Row(
                  children: [
                    Text(AppStrings.discount, style: AppTextStyle.medium14),
                    const Gap(16),
                    Expanded(
                      child: SizedBox(
                        height: 42.h,
                        child: AppTextField(
                          hintText: '0.00',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (value) {
                            final discount = double.tryParse(value) ?? 0.0;
                            cubit.setDiscount(discount);
                          },
                          suffixText: AppStrings.egp,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.totalAfterDiscount,
                        style: AppTextStyle.bold14.copyWith(
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        '${formatter.format(cubit.totalAfterDiscount)} ${AppStrings.egp}',
                        style: AppTextStyle.bold14.copyWith(
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
