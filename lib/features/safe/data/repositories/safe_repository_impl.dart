import 'package:Inventra/core/helper/arabic_normalizer.dart';
import 'package:Inventra/core/helper/cache_helper.dart';
import 'package:Inventra/core/models/expense_model.dart';
import 'package:Inventra/core/models/manual_adjustment_model.dart';
import 'package:Inventra/core/models/safe_balance_model.dart';
import 'package:Inventra/core/models/transaction_type.dart';
import 'package:Inventra/core/models/transactions_entry.dart';
import 'package:Inventra/core/services/Transaction_change_notifier.dart';
import 'package:Inventra/features/safe/data/repositories/safe_repository.dart';
import 'package:Inventra/objectbox.g.dart';

class SafeRepositoryImpl implements SafeRepository {
  final ObjectBoxServices _objectBox;
  final TransactionChangeNotifier _transactionChangeNotifier;

  SafeRepositoryImpl(this._objectBox, this._transactionChangeNotifier, );

  @override
  SafeBalanceModel getBalance() {
    final balance = _objectBox.safeBalanceBox.get(1);
    if (balance != null) return balance;
    return SafeBalanceModel(currentBalance: 0, lastUpdated: DateTime.now());
  }

  @override
  void adjustBalance({required double newAmount, String? newNote}) {
    final balance = getBalance();
    final newBalance = balance.copyWith(
      currentBalance: newAmount,
      lastUpdated: DateTime.now(),
      note: newNote,
    );
    _objectBox.safeBalanceBox.put(newBalance);

    _objectBox.store.runInTransaction(TxMode.write, () {
      final adjustmentId = _objectBox.manualAdjustmentBox.put(
        ManualAdjustmentModel(
          prevBalanceValue: balance.currentBalance,
          newBalanceValue: newBalance.currentBalance,
          date: newBalance.lastUpdated,
          note: newBalance.note,
        ),
      );
      _objectBox.transactionsEntryBox.put(
        TransactionsEntry(
          typeIndex: TransactionType.manualAdjustment.index,
          signedValue: newBalance.currentBalance,
          referenceId: adjustmentId,
          createdAt: newBalance.lastUpdated,
          description: newBalance.note,
        ),
      );
         _transactionChangeNotifier.notify(TransactionType.manualAdjustment);

    });
  }

  @override
  void addExpense(ExpenseModel expense) {
    final balance = getBalance();
    final newbalance = balance.copyWith(
      currentBalance: balance.currentBalance + expense.value,
      lastUpdated: DateTime.now(),
    );
    _objectBox.store.runInTransaction(TxMode.write, () {
      final expenseId = _objectBox.expensesBox.put(expense);

      _objectBox.safeBalanceBox.put(newbalance);
      _objectBox.transactionsEntryBox.put(
        TransactionsEntry(
          typeIndex: TransactionType.expense.index,
          signedValue: expense.value,
          referenceId: expenseId,
          createdAt: expense.date,
          description: expense.note.trim(),
        ),
      );
   _transactionChangeNotifier.notify(TransactionType.expense);

    });
  }

  @override
  List<ExpenseModel> loadExpenses(String searchQuery) {
    final searchText = searchQuery.trim().normalizeArabic();
    Condition<ExpenseModel>? condition;
    if (searchText.isNotEmpty) {
      condition = ExpenseModel_.note.contains(searchText);
    }

    final query = _objectBox.expensesBox
        .query(condition)
        .order(ExpenseModel_.date, flags: Order.descending)
        .build();
    final expenses = query.find();
    query.close();

    return expenses;
  }
}
