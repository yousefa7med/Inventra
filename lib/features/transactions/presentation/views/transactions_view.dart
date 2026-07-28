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
      body: Column(
        children: [
          const Gap(8),
          const TransactionsFilter(),

          Expanded(
            child: BlocBuilder<TransactionsCubit, TransactionsState>(
              buildWhen: (previous, current) =>
                  current is TransactionsLoading ||
                  current is TransactionsLoaded ||
                  current is TransactionsError,
              builder: (context, state) {
                if (state is TransactionsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TransactionsError) {
                  return ErrorStateWidget(
                    message: state.message,
                    onPressed: () =>
                        context.read<TransactionsCubit>().loadTransactions(),
                  );
                } else if (state is TransactionsLoaded) {
                  return TransactionsLoadedBody(
                    transactions: state.transactions,
                  );
                }
                return const EmptyStateWidget(
                  message: "لا يوجد عمليات سابقة",
                  icon: Icons.history_sharp,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
