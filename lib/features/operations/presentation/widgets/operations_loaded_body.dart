import 'dart:developer';

import 'package:Inventra/core/models/transactions_entry.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/widgets/empty_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Inventra/features/operations/controller/cubit/operations_cubit.dart';
import 'package:Inventra/features/operations/presentation/widgets/transaction_card.dart';
import 'package:gap/gap.dart';

class OperationsLoadedBody extends StatelessWidget {
  const OperationsLoadedBody({super.key, required this.transactions});
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
      onRefresh: () async => context.read<OperationsCubit>().loadOperations(),
      child: ListView.separated(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];

          switch (transaction.type) {
            case 0:
              return TransactionCard(
                onTap: () {},
                invoice: transaction,
                color: AppColors.secondary,
                title: 'فاتورة شراء',
                subTitle: 'المورد: ',
                icon: Icons.inventory_2_rounded,
              );
            case 1:
              return TransactionCard(
                onTap: () {},
                title: 'فاتورة بيع',
                subTitle: 'العميل: ',
                invoice: transaction,
                color: AppColors.success,

                icon: Icons.shopping_cart_checkout_rounded,
              );
            case 2:
              return TransactionCard(
                onTap: () {},
                invoice: transaction,
                color: AppColors.error,
                title: 'مصروفات',
                subTitle: 'ملحوظة: ',
                icon: Icons.receipt_long_rounded,
              );
            case 3:
              return TransactionCard(
                onTap: () {},
                invoice: transaction,
                color: AppColors.warning,
                title: 'مرتجع',
                subTitle: 'المورد: ',
                icon: Icons.swap_horiz_rounded,
              );
            case 4:
              return TransactionCard(
                onTap: () {},
                invoice: transaction,
                color: AppColors.lightBlue,
                title: 'تعديل يدوي',
                subTitle: 'المورد: ',
                icon: Icons.tune_rounded,
              );
          }
          return null;
        },
        separatorBuilder: (BuildContext context, int index) => const Gap(6),
      ),
    );
  }
}
