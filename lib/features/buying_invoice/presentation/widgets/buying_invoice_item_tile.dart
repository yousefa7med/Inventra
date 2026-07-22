import 'package:Inventra/core/constants/app_strings.dart';
import 'package:Inventra/core/models/invoice_item_model.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/widgets/quantity_counter.dart';
import 'package:Inventra/features/buying_invoice/controller/cubit/buy_invoice_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class BuyingInvoiceItemTile extends StatefulWidget {
  final InvoiceItemModel item;
  final int index;

  const BuyingInvoiceItemTile({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  State<BuyingInvoiceItemTile> createState() => _BuyingInvoiceItemTileState();
}

class _BuyingInvoiceItemTileState extends State<BuyingInvoiceItemTile> {
  late final TextEditingController controller;
  @override
  void initState() {
    controller = TextEditingController(text: widget.item.quantity.toString());
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BuyInvoiceCubit>();
    final product = widget.item.product.target;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product?.name ?? 'منتج غير معروف',
                        style: AppTextStyle.bold14,
                      ),
                      if (product != null)
                        Text(
                          '${product.buyingPrice.toStringAsFixed(2)} ${AppStrings.egp}',
                          style: AppTextStyle.regular12.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                QuantityCounter(
                  quantity: widget.item.quantity,
                  onChanged: (newQty) =>
                      cubit.updateItemQuantity(widget.index, newQty),
                  controller: controller,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.red),
                  onPressed: () => cubit.removeItem(widget.index),
                ),
              ],
            ),
            const Gap(8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${AppStrings.total}: ${widget.item.lineTotal.toStringAsFixed(2)} ${AppStrings.egp}',
                  style: AppTextStyle.bold12,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
