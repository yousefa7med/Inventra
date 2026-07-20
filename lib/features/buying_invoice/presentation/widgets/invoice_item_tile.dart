import 'package:Inventra/core/models/invoice_item_model.dart';
import 'package:Inventra/features/buying_invoice/controller/cubit/buy_invoice_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InvoiceItemTile extends StatelessWidget {
  final InvoiceItemModel item;
  final int itemIndex;

  const InvoiceItemTile({
    super.key,
    required this.item,
    required this.itemIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.target?.name ?? 'منتج غير معروف',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'سعر الوحدة: ${item.unitPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Text(
                    'الإجمالي: ${item.lineTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (item.quantity > 1) {
                        context.read<BuyInvoiceCubit>().updateItemQuantity(
                              itemIndex,
                              item.quantity - 1,
                            );
                      } else {
                        context.read<BuyInvoiceCubit>().removeItem(itemIndex);
                      }
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.read<BuyInvoiceCubit>().updateItemQuantity(
                            itemIndex,
                            item.quantity + 1,
                          );
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () =>
                  context.read<BuyInvoiceCubit>().removeItem(itemIndex),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}