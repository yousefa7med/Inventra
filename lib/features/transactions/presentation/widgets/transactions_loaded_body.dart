import 'package:Inventra/core/models/transaction_type.dart';
import 'package:Inventra/core/models/transactions_entry.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/features/transactions/data/models/list_item_model.dart';
import 'package:Inventra/features/transactions/presentation/widgets/date_header.dart';
import 'package:flutter/material.dart';
import 'package:Inventra/features/transactions/presentation/widgets/transaction_card.dart';

class TransactionsLoadedBody extends StatelessWidget {
  const TransactionsLoadedBody({super.key, required this.listItems});
  final List<ListItemModel> listItems;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: listItems.length,
      itemBuilder: (context, index) {
        if (listItems[index] is TransactionItem) {
          return _buildTransactionCard(
            (listItems[index] as TransactionItem).transaction,
          );
        } else if (listItems[index] is HeaderItem) {
          return DateHeader(headerItem: (listItems[index] as HeaderItem));
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTransactionCard(TransactionsEntry transaction) {
    switch (transaction.type) {
      case TransactionType.buyingInvoice:
        return TransactionCard(
          transaction: transaction,
          color: AppColors.secondary,
          title: 'فاتورة شراء',
          subTitle: 'المورد: ',
          icon: Icons.inventory_2_outlined,
        );
      case TransactionType.sellingInvoice:
        return TransactionCard(
          transaction: transaction,
          title: 'فاتورة بيع',
          subTitle: 'العميل: ',
          color: AppColors.success,
          icon: Icons.shopping_cart_checkout_rounded,
        );

      case TransactionType.expense:
        return TransactionCard(
          transaction: transaction,
          color: AppColors.error,
          title: 'مصروفات',
          subTitle: 'ملحوظة: ',
          icon: Icons.receipt_long_rounded,
        );

      case TransactionType.returnReceipt:
        return TransactionCard(
          transaction: transaction,
          color: AppColors.warning,
          title: 'مرتجع',
          subTitle: 'العميل: ',
          icon: Icons.swap_horiz_rounded,
        );

      case TransactionType.manualAdjustment:
        return TransactionCard(
          transaction: transaction,
          color: AppColors.lightBlue,
          title: 'تعديل يدوي',
          subTitle: 'رصيد: ',
          icon: Icons.tune_rounded,
        );
    }
  }
}
