import 'package:Inventra/core/helper/cache_helper.dart';
import 'package:Inventra/core/models/expense_model.dart';
import 'package:Inventra/core/models/manual_adjustment_model.dart';
import 'package:Inventra/core/models/safe_balance_model.dart';
import 'package:Inventra/core/models/transaction_type.dart';
import 'package:Inventra/core/models/transactions_entry.dart';
import 'package:Inventra/features/safe/data/repositories/safe_repository.dart';
import 'package:Inventra/objectbox.g.dart';
import 'package:flutter/material.dart';

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
  void adjustBalance({required double newAmount, String? newNote}) {
    final balance = getBalance();
    final newBalance = balance.copyWith(
      currentBalance: newAmount,
      lastUpdated: DateTime.now(),
      note: newNote,
    );
    _objectBox.safeBalanceBox.put(newBalance);

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
        type: TransactionType.manualAdjustment.index,
        value: newBalance.currentBalance,
        referenceId: adjustmentId,
        timestamp: newBalance.lastUpdated,
        description: newBalance.note,
      ),
    );
  }

  @override
  List<ExpenseModel> loadExpenses({
    String? searchText,
    DateTimeRange<DateTime>? dateRange,
  }) {
    Condition<ExpenseModel>? condition;
    if (searchText != null && searchText.trim().isNotEmpty) {
      condition = ExpenseModel_.note.contains(searchText);
    }
    if (dateRange != null) {
      final start = dateRange.start;
      final end = DateTime(
        dateRange.end.year,
        dateRange.end.month,
        dateRange.end.day,
        23,
        59,
        59,
        999,
      );

      final dateCondition = ExpenseModel_.date.betweenDate(start, end);

      condition = (condition == null)
          ? dateCondition
          : condition.and(dateCondition);
    }
    final query = _objectBox.expensesBox
        .query(condition)
        .order(ExpenseModel_.date, flags: Order.descending)
        .build();
    final expenses = query.find();
    query.close();

    return expenses;
  }

  @override
  void addExpense(ExpenseModel expense) {
    final expenseId = _objectBox.expensesBox.put(expense);
    final balance = getBalance();
    final newbalance = balance.copyWith(
      currentBalance: balance.currentBalance + expense.value,
      lastUpdated: DateTime.now(),
    );

    _objectBox.safeBalanceBox.put(newbalance);
    _objectBox.transactionsEntryBox.put(
      TransactionsEntry(
        type: TransactionType.expense.index,
        value: expense.value,
        referenceId: expenseId,
        timestamp: expense.date,
        description: expense.note.trim(),
      ),
    );
  }
}
