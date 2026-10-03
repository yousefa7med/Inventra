import 'package:Inventra/core/models/transactions_entry.dart';

abstract class ListItemModel {}

class HeaderItem implements ListItemModel {
  final DateTime date;
  final int count;
  final double total;
  HeaderItem({required this.date, required this.count, required this.total});
}

class TransactionItem implements ListItemModel {
  final TransactionsEntry transaction;
  TransactionItem({required this.transaction});
}
