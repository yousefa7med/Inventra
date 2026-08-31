import 'package:Inventra/core/models/expense_model.dart';
import 'package:Inventra/core/models/safe_balance_model.dart';

abstract class SafeRepository {
  SafeBalanceModel getBalance();
  void adjustBalance({required double newAmount, String? newNote});
  List<ExpenseModel> loadExpenses(String searchText);

  void addExpense(ExpenseModel expense);
}
