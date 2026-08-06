import 'dart:developer';

import 'package:Inventra/core/models/transaction_type.dart';
import 'package:Inventra/core/models/transactions_entry.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/widgets/empty_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Inventra/features/transactions/controller/cubit/transactions_cubit.dart';
import 'package:Inventra/features/transactions/presentation/widgets/transaction_card.dart';
import 'package:gap/gap.dart';

class TransactionsLoadedBody extends StatelessWidget {
  const TransactionsLoadedBody({super.key, required this.transactions});
  final List<TransactionsEntry> transactions;
  @override
  Widget build(BuildContext context) {
    log("build transactions list");
    if (transactions.isEmpty) {
      return const EmptyStateWidget(
        message: "لا يوجد عمليات سابقة",
        icon: Icons.history_sharp,
      );
    }

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<TransactionsCubit>().loadTransactions(),
      child: ListView.separated(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];

          switch (transaction.type) {
            case TransactionType.buyingInvoice:
              return TransactionCard(
                transaction: transaction,
                color: AppColors.secondary,
                title: 'فاتورة شراء',
                subTitle: 'المورد: ',
                icon: Icons.inventory_2_rounded,
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
                subTitle: 'المورد: ',
                icon: Icons.swap_horiz_rounded,
              );

            case TransactionType.manualAdjustment:
              return TransactionCard(
                transaction: transaction,
                color: AppColors.lightBlue,
                title: 'تعديل يدوي',
                subTitle: 'المورد: ',
                icon: Icons.tune_rounded,
              );
          }
        },
        separatorBuilder: (BuildContext context, int index) => const Gap(6),
      ),
    );
  }
}
