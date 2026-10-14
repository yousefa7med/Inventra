import 'package:Inventra/core/helper/cache_helper.dart';
import 'package:Inventra/core/models/expense_model.dart';
import 'package:Inventra/core/models/safe_balance_model.dart';
import 'package:Inventra/core/models/transaction_type.dart';
import 'package:Inventra/core/models/transactions_entry.dart';
import 'package:Inventra/core/services/transaction_change_notifier.dart';
import 'package:Inventra/features/dashboard/data/repositories/dashboard_repository/dashboard_repository.dart';
import 'package:Inventra/objectbox.g.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final ObjectBoxServices _objectBox;
  final TransactionChangeNotifier _transactionChangeNotifier;

  DashboardRepositoryImpl(this._objectBox, this._transactionChangeNotifier);

  @override
  SafeBalanceModel getBalance() {
    final balance = _objectBox.safeBalanceBox.get(1);

    if (balance != null) return balance;
    return SafeBalanceModel(currentBalance: 0, lastUpdated: DateTime.now());
  }

  @override
  void addExpense(ExpenseModel expense) {
    final balance = getBalance();
    final newBalance = balance.copyWith(
      currentBalance: balance.currentBalance + expense.value,
      lastUpdated: DateTime.now(),
    );

    _objectBox.store.runInTransaction(TxMode.write, () {
      _objectBox.safeBalanceBox.put(newBalance);
      final expenseId = _objectBox.expensesBox.put(expense);
      final entry = TransactionsEntry(
        typeIndex: TransactionType.expense.index,
        signedValue: expense.value,
        referenceId: expenseId,
        createdAt: expense.date,
        description: expense.note.trim(),
      );
      _objectBox.transactionsEntryBox.put(entry);
      _transactionChangeNotifier.notify(entry);
    });
  }
}
