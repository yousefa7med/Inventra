import 'package:Inventra/core/widgets/empty_state_widget.dart';
import 'package:Inventra/features/safe/controller/cubit/safe_cubit.dart';
import 'package:Inventra/features/safe/presentation/views/adjust_balance_dialog.dart';
import 'package:Inventra/features/safe/presentation/widgets/balance_card.dart';
import 'package:Inventra/features/safe/presentation/widgets/expense_card.dart';
import 'package:Inventra/features/safe/presentation/widgets/safe_search_and_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class SafeLoadedBody extends StatelessWidget {
  const SafeLoadedBody({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                BalanceCard(
                  balance: context.read<SafeCubit>().currentBalance,
                  isNegative: false,
                  onEditTap: () => _showAdjustBalanceDialog(context),
                ),
                const Gap(16),
                const SafeSearchAndFilter(),
                // const Gap(12),
                // _buildExpensesHeader(),
                const Gap(8),
              ],
            ),
          ),
        ),
        if (context.read<SafeCubit>().expenses.isEmpty)
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
              itemCount: context.read<SafeCubit>().expenses.length,
              separatorBuilder: (context, index) => const Gap(8),
              itemBuilder: (context, index) {
                return ExpenseCard(
                  expense: context.read<SafeCubit>().expenses[index],
                );
              },
            ),
          ),
      ],
    );
  }

  // Widget _buildExpensesHeader() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       const Text('المصروفات'),
  //       Text(
  //         '(${widget.state.filteredExpenses.length} من ${widget.state.expenses.length})',
  //       ),
  //     ],
  //   );
  // }

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
