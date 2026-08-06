import 'package:Inventra/core/models/buying_invoice_model.dart';
import 'package:Inventra/core/models/selling_invoice_model.dart';
import 'package:Inventra/objectbox.g.dart';
import 'package:flutter/material.dart';
import 'package:Inventra/core/helper/cache_helper.dart';
import 'package:Inventra/core/models/transactions_entry.dart';
import 'package:Inventra/core/models/transaction_type.dart';
import 'package:Inventra/features/transactions/data/repositories/transactions_repository.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  final ObjectBoxServices _objectBox;

  TransactionsRepositoryImpl({required this._objectBox});

  @override
  List<TransactionsEntry> getTransactions({
    TransactionType? type,
    DateTimeRange? dateRange,
  }) {
    Condition<TransactionsEntry>? condition;

    if (type != null) {
      condition = TransactionsEntry_.type.equals(type.index);
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

      final dateCondition = TransactionsEntry_.timestamp.betweenDate(
        start,
        end,
      );

      condition = (condition == null)
          ? dateCondition
          : condition.and(dateCondition);
    }

    final query = _objectBox.transactionsEntryBox
        .query(condition)
        .order(TransactionsEntry_.timestamp, flags: Order.descending)
        .build();

    final results = query.find();
    query.close();

    return results;
  }

  @override
  BuyingInvoiceModel getBuyingInvoice(int id) {
    return _objectBox.buyInvoicesBox.get(id)!;
  }

  @override
  SellingInvoiceModel getSellingInvoice(int id) {
    return _objectBox.sellingInvoicesBox.get(id)!;
  }
}
