import 'package:Inventra/core/models/expense_model.dart';
import 'package:flutter/material.dart';

abstract class SafeCubitInterface {
  double get currentBalance;

  List<ExpenseModel> get expenses;

  DateTimeRange<DateTime>? get selectedDateRange;
  String? get searchText;

  void addExpense({required double value, required String note});
  void getExpenses({DateTimeRange<DateTime>? dateRange, String? searchText});
  void clearDateFilter();
  void clearSearchFilter();

  void adjustBalance({required double newBalance, String? note});
}
