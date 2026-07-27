import 'package:flutter/material.dart';
import 'package:Inventra/core/models/transactions_entry.dart';
import 'package:Inventra/core/models/balance_change_type.dart';

abstract class OperationsRepository {
  List<TransactionsEntry> getOperations({
    BalanceChangeType? type,
    DateTimeRange? dateRange,
  });
}
