import 'package:Inventra/core/constants/app_strings.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/features/buying_invoice/controller/cubit/buy_invoice_cubit.dart';
import 'package:Inventra/features/buying_invoice/presentation/widgets/quantity_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class ProductCardWithCounter extends StatefulWidget {
  final ProductModel product;

  const ProductCardWithCounter({super.key, required this.product});

  @override
  State<ProductCardWithCounter> createState() => _ProductCardWithCounterState();
}

class _ProductCardWithCounterState extends State<ProductCardWithCounter> {
  late final TextEditingController counterController;

  @override
  void initState() {
    counterController = TextEditingController(text: 0.toString());
    super.initState();
  }

  @override
  void dispose() {
    counterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BuyInvoiceCubit>();

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
            const SizedBox(height: 12),
            Row(
              children: [
                QuantityCounter(
                  controller: counterController,
                  quantity: 0,
                  maxQuantity: widget.product.quantity,
                  onChanged: (newQty) {
                    if (newQty == 0) {
                      // Remove product from invoice when quantity reaches 0
                    } else {
                      cubit.addProductItem(widget.product, newQty);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}