import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:Inventra/core/widgets/empty_state_widget.dart';
import 'package:Inventra/core/widgets/error_state_widget.dart';
import 'package:Inventra/features/transactions/presentation/widgets/transactions_loaded_body.dart';
import 'package:Inventra/features/transactions/presentation/widgets/transactions_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Inventra/features/transactions/controller/cubit/transactions_cubit.dart';
import 'package:Inventra/features/transactions/controller/cubit/transactions_state.dart';
import 'package:gap/gap.dart';

class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'سجل العمليات', showDrawerButton: true),
      body: RefreshIndicator(
        onRefresh: () async =>
            context.read<TransactionsCubit>().loadTransactions(),
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: Gap(8)),
            const SliverToBoxAdapter(child: TransactionsFilter()),

            BlocBuilder<TransactionsCubit, TransactionsState>(
              buildWhen: (previous, current) =>
                  current is TransactionsLoading ||
                  current is TransactionsLoaded ||
                  current is TransactionsError,
              builder: (context, state) {
                if (state is TransactionsLoading) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is TransactionsError) {
                  return SliverToBoxAdapter(
                    child: ErrorStateWidget(
                      message: state.message,
                      onPressed: () =>
                          context.read<TransactionsCubit>().loadTransactions(),
                    ),
                  );
                } else if (state is TransactionsLoaded &&
                    state.listItems.isNotEmpty) {
                  return TransactionsLoadedBody(listItems: state.listItems);
                }
                return const SliverFillRemaining(
                  child: EmptyStateWidget(
                    message: "لا يوجد عمليات سابقة",
                    icon: Icons.history_sharp,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
