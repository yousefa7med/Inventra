import 'package:Inventra/core/constants/app_strings.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/features/selling_invoice/controller/cubit/sell_invoice_cubit.dart';
import 'package:Inventra/core/widgets/quantity_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class SellingProductCardWithCounter extends StatefulWidget {
  final ProductModel product;

  const SellingProductCardWithCounter({super.key, required this.product});

  @override
  State<SellingProductCardWithCounter> createState() =>
      _SellingProductCardWithCounterState();
}

class _SellingProductCardWithCounterState
    extends State<SellingProductCardWithCounter> {
  late final TextEditingController counterController;

  @override
  void initState() {
    counterController = TextEditingController(text: 1.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SellInvoiceCubit>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.product.name,
                  style: AppTextStyle.bold16,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(10),
                Text(
                  widget.product.quantity.toString(),
                  style: AppTextStyle.semiBold12.copyWith(
                    color: widget.product.quantity > 10
                        ? AppColors.primary
                        : AppColors.warning,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'شراء: ${widget.product.buyingPrice.toStringAsFixed(2)} ${AppStrings.egp}',
                    style: AppTextStyle.regular12.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'بيع: ${widget.product.saleingPrice.toStringAsFixed(2)} ${AppStrings.egp}',
                    style: AppTextStyle.bold12.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'جملة: ${widget.product.wholesalePrice.toStringAsFixed(2)} ${AppStrings.egp}',
              style: AppTextStyle.regular12.copyWith(color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(width: 8),
            const Gap(8),
            Row(
              children: [
                Expanded(
                  child: QuantityCounter(
                    quantity: 1,
                    maxQuantity: widget.product.quantity,
                    controller: counterController,
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.product.quantity > 0
                        ? () {
                            cubit.addProductItemLine(
                              widget.product,
                              int.tryParse(counterController.text) ?? 1,
                            );
                            AppNavigation.pop(context: context);
                          }
                        : null,
                    child: Text(
                      AppStrings.addToInvoice,
                      style: AppTextStyle.regular12,
                    ),
                  ),
                ),
              ],
            ),
            if (widget.product.quantity == 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  AppStrings.outOfStock,
                  style: AppTextStyle.bold12.copyWith(color: AppColors.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
