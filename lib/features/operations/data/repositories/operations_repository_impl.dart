import 'package:Inventra/objectbox.g.dart';
import 'package:flutter/material.dart';
import 'package:Inventra/core/helper/cache_helper.dart';
import 'package:Inventra/core/models/balance_audit_entry_model.dart';
import 'package:Inventra/core/models/balance_change_type.dart';
import 'package:Inventra/features/operations/data/repositories/operations_repository.dart';

class OperationsRepositoryImpl implements OperationsRepository {
  final ObjectBoxServices _objectBox;

  OperationsRepositoryImpl({required this._objectBox});

  @override
  List<BalanceAuditEntryModel> getOperations({
    BalanceChangeType? type,
    DateTimeRange? dateRange,
  }) {
    Condition<BalanceAuditEntryModel>? condition;

    if (type != null) {
      condition = BalanceAuditEntryModel_.type.equals(type.index);
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

      final dateCondition = BalanceAuditEntryModel_.timestamp.betweenDate(start, end);
      
      condition = (condition == null) ? dateCondition : condition.and(dateCondition);
    }

    final query = _objectBox.balanceAuditEntryBox
        .query(condition)
        .order(BalanceAuditEntryModel_.timestamp, flags: Order.descending) 
        .build();

    final results = query.find();
    query.close();

    return results;
  }
}