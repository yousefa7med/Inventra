import 'package:Inventra/core/models/transactions_entry.dart';

sealed class TransactionsState {}

class TransactionsInitial extends TransactionsState {}

class TransactionsLoading extends TransactionsState {}

class TransactionsLoaded extends TransactionsState {
  final List<TransactionsEntry> transactions;

  TransactionsLoaded({required this.transactions});
}

class TransactionsError extends TransactionsState {
  final String message;

  TransactionsError(this.message);
}


