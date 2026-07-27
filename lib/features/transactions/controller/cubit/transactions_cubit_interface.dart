import 'package:Inventra/core/models/transactions_entry.dart';
import 'package:flutter/material.dart';
import 'package:Inventra/core/models/transaction_type.dart';

abstract class TransactionsCubitInterface {
  // State getters
  List<TransactionsEntry> get transactions;
  int? get selectedType;
  DateTimeRange? get selectedDateRange;

  // Filter actions
  void loadTransactions({TransactionType? type, DateTimeRange? dateRange});

  void clearFilters();
  void clearTypeFilter();
  void clearDateFilter();

  // Navigation
}
