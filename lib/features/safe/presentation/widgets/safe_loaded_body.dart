import 'package:Inventra/core/models/transaction_type.dart';
import 'package:Inventra/core/models/transactions_entry.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/widgets/empty_state_widget.dart';
import 'package:Inventra/features/safe/controller/cubit/safe_cubit.dart';
import 'package:Inventra/features/safe/presentation/views/adjust_balance_dialog.dart';
import 'package:Inventra/features/safe/presentation/widgets/balance_card.dart';
import 'package:Inventra/features/safe/data/models/list_item_model.dart';
import 'package:Inventra/features/safe/presentation/widgets/date_header.dart';
import 'package:Inventra/features/safe/presentation/widgets/transaction_card.dart';
import 'package:Inventra/features/safe/presentation/widgets/transactions_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class SafeLoadedBody extends StatelessWidget {
  const SafeLoadedBody({super.key, required this.state});
  final SafeLoaded state;
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                BalanceCard(
                  balance: state.safeBalance,
                  isNegative: false,
                  onEditTap: () => _showAdjustBalanceDialog(context),
                ),
                const Gap(16),
                const TransactionsFilter(),
                const Gap(8),
              ],
            ),
          ),
        ),
        if (state.listItems.isEmpty)
          const SliverFillRemaining(
            child: EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              message: 'لا توجد عمليات',
            ),
          )
        else
          SliverList.separated(
            itemCount: state.listItems.length,
            separatorBuilder: (context, index) => const Gap(8),
            itemBuilder: (context, index) {
              if (state.listItems[index] is TransactionItem) {
                return _buildTransactionCard(
                  (state.listItems[index] as TransactionItem).transaction,
                );
              } else if (state.listItems[index] is HeaderItem) {
                return DateHeader(
                  headerItem: (state.listItems[index] as HeaderItem),
                );
              }
              return const SizedBox.shrink();
            },
          ),
      ],
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

  void _showAdjustBalanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<SafeCubit>(),
        child: const AdjustBalanceDialog(),
      ),
    );
  }
}
