import 'dart:developer';

import 'package:Inventra/core/widgets/empty_state.dart';
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
  final _searchFocusNode = FocusNode();
  final _scrollController = ScrollController();
  final GlobalKey _searchKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChange);
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchFocusChange() {
    if (_searchFocusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final renderBox =
              _searchKey.currentContext?.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final searchPosition = renderBox.localToGlobal(
              Offset.zero,
              ancestor: context.findRenderObject(),
            );
            final targetOffset = _scrollController.offset + searchPosition.dy;
            _scrollController.animateTo(
              targetOffset - 12,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        }
      });
    }
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
                SafeSearchAndFilter(
                  searchFocusNode: _searchFocusNode,
                  key: _searchKey,
                ),
                const Gap(12),
                _buildExpensesHeader(),
                const Gap(8),
              ],
            ),
          ),
        ),
        if (widget.state.filteredExpenses.isEmpty)
          const SliverFillRemaining(
            child: EmptyState(
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
