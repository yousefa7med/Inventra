import 'package:Inventra/features/transactions/data/models/list_item_model.dart';

sealed class TransactionsState {}

class TransactionsInitial extends TransactionsState {}

class TransactionsLoading extends TransactionsState {}

class TransactionsLoaded extends TransactionsState {
  final List<ListItemModel> listItems;

  TransactionsLoaded({required this.listItems});
}

class TransactionsError extends TransactionsState {
  final String message;

  TransactionsError(this.message);
}
