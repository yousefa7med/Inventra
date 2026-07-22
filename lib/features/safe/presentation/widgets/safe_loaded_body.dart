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

class SafeLoadedBody extends StatefulWidget {
  const SafeLoadedBody({super.key, required this.state});

  final SafeLoaded state;

  @override
  State<SafeLoadedBody> createState() => _SafeLoadedBodyState();
}

class _SafeLoadedBodyState extends State<SafeLoadedBody> {
  final _scrollController = ScrollController();
  final GlobalKey _searchKey = GlobalKey();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                BalanceCard(
                  balance: widget.state.balance,
                  isNegative: widget.state.isNegativeBalance,
                  onEditTap: () => _showAdjustBalanceDialog(context),
                ),
                const Gap(16),
                SafeSearchAndFilter(key: _searchKey),
                const Gap(12),
                _buildExpensesHeader(),
                const Gap(8),
              ],
            ),
          ),
        ),
        if (widget.state.filteredExpenses.isEmpty)
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
              itemCount: widget.state.filteredExpenses.length,
              separatorBuilder: (context, index) => const Gap(8),
              itemBuilder: (context, index) {
                return ExpenseCard(
                  expense: widget.state.filteredExpenses[index],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildExpensesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('المصروفات'),
        Text(
          '(${widget.state.filteredExpenses.length} من ${widget.state.expenses.length})',
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
