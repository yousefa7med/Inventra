import 'package:flutter/material.dart';
import 'package:Inventra/core/models/transactions_entry.dart';
import 'package:Inventra/core/models/transaction_type.dart';

abstract class TransactionsRepository {
  List<TransactionsEntry> getTransactions({
    TransactionType? type,
    DateTimeRange? dateRange,
  });
}
