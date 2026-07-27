import 'package:Inventra/core/models/balance_audit_entry_model.dart';

sealed class OperationsState {}

class OperationsInitial extends OperationsState {}

class OperationsLoading extends OperationsState {}

class OperationsLoaded extends OperationsState {
  final List<BalanceAuditEntryModel> transactions;

  OperationsLoaded({required this.transactions});
}

class OperationsError extends OperationsState {
  final String message;

  OperationsError(this.message);
}

class OperationDisplayModel {
  final BalanceAuditEntryModel entry;
  final double previousBalance;
  final double nextBalance;

  OperationDisplayModel({
    required this.entry,
    required this.previousBalance,
    required this.nextBalance,
  });
}
