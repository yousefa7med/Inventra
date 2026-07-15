import 'package:Inventra/core/helper/cache_helper.dart';
import 'package:Inventra/core/models/balance_audit_entry_model.dart';
import 'package:Inventra/core/models/balance_change_type.dart';
import 'package:Inventra/core/models/expense_model.dart';
import 'package:Inventra/core/models/safe_balance_model.dart';
import 'package:Inventra/features/safe/data/repositories/safe_repository.dart';
import 'package:Inventra/objectbox.g.dart';

class SafeRepositoryImpl implements SafeRepository {
  final ObjectBoxServices _objectBox;

  SafeRepositoryImpl(this._objectBox);

  @override
  SafeBalanceModel getBalance() {
    final balance = _objectBox.safeBalanceBox.get(1);
    if (balance != null) return balance;
    return SafeBalanceModel(currentBalance: 0, lastUpdated: DateTime.now());
  }

  @override
  void updateBalance(double newAmount) {
    final balance = getBalance();
    balance.currentBalance = newAmount;
    balance.lastUpdated = DateTime.now();
    _objectBox.safeBalanceBox.put(balance);
  }

  // @override
  // void iniializeBalance(double initialAmount) {
  //   final existing = _objectBox.safeBalanceBox.get(1);
  //   if (existing == null) {
  //     _objectBox.safeBalanceBox.put(
  //       SafeBalanceModel(currentAmount: initialAmount, lastUpdated: DateTime.now()),
  //     );
  //   }
  // }

  @override
  List<ExpenseModel> getAllExpenses() {
    final expenses = _objectBox.expensesBox.getAll();
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  @override
  List<ExpenseModel> getExpensesFiltered({
    DateTime? fromDate,
    DateTime? toDate,
    String? searchText,
  }) {
    final expenses = getAllExpenses();

    var filtered = expenses;

    if (fromDate != null) {
      final from = DateTime(fromDate.year, fromDate.month, fromDate.day);
      filtered = filtered
          .where((e) => e.date.isAfter(from) || e.date.isAtSameMomentAs(from))
          .toList();
    }
    if (toDate != null) {
      final to = DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59);
      filtered = filtered
          .where((e) => e.date.isBefore(to) || e.date.isAtSameMomentAs(to))
          .toList();
    }
    if (searchText != null && searchText.isNotEmpty) {
      final lowerSearch = searchText.toLowerCase();
      filtered = filtered
          .where((e) => e.note.toLowerCase().contains(lowerSearch))
          .toList();
    }

    return filtered;
  }

  @override
  void addExpense(ExpenseModel expense) {
    _objectBox.expensesBox.put(expense);
  }

  @override
  Stream<List<ExpenseModel>> watchExpenses() {
    return _objectBox.expensesBox
        .query()
        .order(ExpenseModel_.date, flags: Order.descending)
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  @override
  List<BalanceAuditEntryModel> getAuditEntries({BalanceChangeType? type}) {
    var entries = _objectBox.balanceAuditEntryBox.getAll();
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (type != null) {
      entries = entries.where((e) => e.type == type.index).toList();
    }

    return entries;
  }

  @override
  void addAuditEntry(BalanceAuditEntryModel entry) {
    _objectBox.balanceAuditEntryBox.put(entry);
  }

  @override
  Stream<List<BalanceAuditEntryModel>> watchAuditEntries() {
    return _objectBox.balanceAuditEntryBox
        .query()
        .order(BalanceAuditEntryModel_.timestamp, flags: Order.descending)
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }
}
