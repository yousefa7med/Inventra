import 'package:Inventra/core/models/balance_audit_entry_model.dart';
import 'package:flutter/material.dart';
import 'package:Inventra/core/models/balance_change_type.dart';

abstract class OperationsCubitInterface {
  // State getters
  List<BalanceAuditEntryModel> get operations;
  int? get selectedType;
  DateTimeRange? get selectedDateRange;

  // Filter actions
  void loadOperations({BalanceChangeType? type, DateTimeRange? dateRange});

  void clearFilters();

  // Navigation
}
