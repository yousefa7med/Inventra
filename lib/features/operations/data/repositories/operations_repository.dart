import 'package:flutter/material.dart';
import 'package:Inventra/core/models/balance_audit_entry_model.dart';
import 'package:Inventra/core/models/balance_change_type.dart';

abstract class OperationsRepository {
  List<BalanceAuditEntryModel> getOperations({
    BalanceChangeType? type,
    DateTimeRange? dateRange,
  });
}