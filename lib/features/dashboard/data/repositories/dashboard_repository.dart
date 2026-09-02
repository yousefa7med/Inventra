import 'package:Inventra/core/models/transactions_entry.dart';
import 'package:Inventra/features/dashboard/data/models/dashboard_metric.dart';
import 'package:Inventra/features/dashboard/data/models/dashboard_model.dart';
import 'package:flutter/material.dart';

abstract class DashboardRepository {
  late DashboardModel dashboardEntity;

  DashboardModel getDashboardData({required DashboardPeriod period});
  DateTimeRange getTimeRange(DashboardPeriod period);
  DashboardPeriodSnapshot getDashboardSnapshot({
    required DashboardPeriod period,
  });
  List<TransactionsEntry> getEntries(DashboardPeriod period);
}
