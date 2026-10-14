import 'package:Inventra/core/models/expense_model.dart';
import 'package:Inventra/core/models/safe_balance_model.dart';

abstract class DashboardRepository {
  SafeBalanceModel getBalance();
  void addExpense(ExpenseModel expense);
}
