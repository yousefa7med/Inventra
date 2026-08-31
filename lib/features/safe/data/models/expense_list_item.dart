import 'package:Inventra/core/models/expense_model.dart';

abstract class ExpenseListItem {}

class ExpenseHeaderItem extends ExpenseListItem {
  final DateTime date;

  ExpenseHeaderItem({required this.date});
}

class ExpenseItem extends ExpenseListItem {
  final ExpenseModel expense;

  ExpenseItem({required this.expense});
}
