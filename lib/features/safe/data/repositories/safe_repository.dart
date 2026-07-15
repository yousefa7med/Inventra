import 'package:Inventra/core/models/balance_audit_entry_model.dart';
import 'package:Inventra/core/models/balance_change_type.dart';
import 'package:Inventra/core/models/expense_model.dart';
import 'package:Inventra/core/models/safe_balance_model.dart';

abstract class SafeRepository {
  SafeBalanceModel getBalance();
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

  List<BalanceAuditEntryModel> getAuditEntries({BalanceChangeType? type});
  void addAuditEntry(BalanceAuditEntryModel entry);
  Stream<List<BalanceAuditEntryModel>> watchAuditEntries();
}
