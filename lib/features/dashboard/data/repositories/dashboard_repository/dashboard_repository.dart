import 'package:Inventra/core/models/expense_model.dart';
import 'package:Inventra/core/models/safe_balance_model.dart';
import 'package:Inventra/core/models/transactions_entry.dart';
import 'package:Inventra/features/dashboard/data/enums/dashboard_period.dart';
import 'package:Inventra/features/dashboard/data/models/dashboard_model.dart';
import 'package:flutter/material.dart';

abstract class DashboardRepository {
  late DashboardModel cachedDashboardSnapshot;
  void clearCachedDashboardSnapshot();
  DashboardPeriodSnapshot getDashboardData({required DashboardPeriod period});
  DateTimeRange getTimeRange(DashboardPeriod period);
  DashboardPeriodSnapshot getDashboardSnapshot({
    required DashboardPeriod period,
  });
  List<TransactionsEntry> getEntries(DashboardPeriod period);
  SafeBalanceModel getBalance();
  void addExpense(ExpenseModel expense);
}
