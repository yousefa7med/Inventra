import 'dart:developer';

import 'package:Inventra/core/widgets/empty_state_widget.dart';
import 'package:Inventra/features/safe/controller/cubit/safe_cubit.dart';
import 'package:Inventra/features/safe/data/models/expense_list_item.dart';
import 'package:Inventra/features/safe/presentation/views/adjust_balance_dialog.dart';
import 'package:Inventra/features/safe/presentation/widgets/balance_card.dart';
import 'package:Inventra/features/safe/presentation/widgets/expense_card.dart';
import 'package:Inventra/features/safe/presentation/widgets/expense_header.dart';
import 'package:Inventra/features/safe/presentation/widgets/safe_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class SafeLoadedBody extends StatelessWidget {
  const SafeLoadedBody({super.key, required this.state});
  final SafeLoaded state;
  @override
  Widget build(BuildContext context) {
    log('rebuildddddddddddd');
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
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
                const SafeSearch(),

                const Gap(8),
              ],
            ),
          ),
        ),
        if (state.expenseListItem.isEmpty)
          const SliverFillRemaining(
            child: EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              message: 'لا توجد مصروفات',
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: SliverList.separated(
              itemCount: state.expenseListItem.length,
              separatorBuilder: (context, index) => const Gap(8),
              itemBuilder: (context, index) {
                final item = state.expenseListItem[index];
                if (item is ExpenseItem) {
                  return ExpenseCard(expense: item.expense);
                } else {
                  return ExpenseHeader(headerItem: (item as ExpenseHeaderItem));
                }
              },
            ),
          ),
      ],
    );
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
