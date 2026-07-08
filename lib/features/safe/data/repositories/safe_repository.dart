import 'package:Inventra/core/models/balance_audit_entry.dart';
import 'package:Inventra/core/models/balance_change_type.dart';
import 'package:Inventra/core/models/expense.dart';
import 'package:Inventra/core/models/safe_balance.dart';

abstract class SafeRepository {
  SafeBalance getBalance();
  void updateBalance(double newAmount);
  // void initializeBalance(double initialAmount);

  List<ExpenseModel> getAllExpenses();
  List<ExpenseModel> getExpensesFiltered({
    DateTime? fromDate,
    DateTime? toDate,
    String? searchText,
  });
  void addExpense(ExpenseModel expense);
  Stream<List<ExpenseModel>> watchExpenses();

  List<BalanceAuditEntry> getAuditEntries({BalanceChangeType? type});
  void addAuditEntry(BalanceAuditEntry entry);
  Stream<List<BalanceAuditEntry>> watchAuditEntries();
}
