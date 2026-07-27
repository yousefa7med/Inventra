import 'package:Inventra/core/models/transactions_entry.dart';

sealed class OperationsState {}

class OperationsInitial extends OperationsState {}

class OperationsLoading extends OperationsState {}

class OperationsLoaded extends OperationsState {
  final List<TransactionsEntry> transactions;

  OperationsLoaded({required this.transactions});
}

class OperationsError extends OperationsState {
  final String message;

  OperationsError(this.message);
}

class OperationDisplayModel {
  final TransactionsEntry entry;
  final double previousBalance;
  final double nextBalance;

  OperationDisplayModel({
    required this.entry,
    required this.previousBalance,
    required this.nextBalance,
  });
}
