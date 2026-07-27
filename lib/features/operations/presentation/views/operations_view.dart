import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:Inventra/core/widgets/empty_state_widget.dart';
import 'package:Inventra/core/widgets/error_state_widget.dart';
import 'package:Inventra/features/operations/presentation/widgets/operations_loaded_body.dart';
import 'package:Inventra/features/operations/presentation/widgets/transactions_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Inventra/features/operations/controller/cubit/operations_cubit.dart';
import 'package:Inventra/features/operations/controller/cubit/operations_state.dart';

class OperationsView extends StatelessWidget {
  const OperationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'سجل العمليات', showDrawerButton: true),
      body: Column(
        children: [
          const TransactionsFilter(),

          Expanded(
            child: BlocBuilder<OperationsCubit, OperationsState>(
              buildWhen: (previous, current) =>
                  current is OperationsLoading ||
                  current is OperationsLoaded ||
                  current is OperationsError,
              builder: (context, state) {
                if (state is OperationsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is OperationsError) {
                  return ErrorStateWidget(
                    message: state.message,
                    onPressed: () =>
                        context.read<OperationsCubit>().loadOperations(),
                  );
                } else if (state is OperationsLoaded) {
                  return OperationsLoadedBody(transactions: state.transactions);
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
