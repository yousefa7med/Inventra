
import 'package:Inventra/core/helper/cache_helper.dart';
import 'package:Inventra/core/models/transaction_type.dart';
import 'package:Inventra/core/models/transactions_entry.dart';
import 'package:Inventra/features/dashboard/data/models/chart_point.dart';
import 'package:Inventra/features/dashboard/data/models/dashboard_metric.dart';
import 'package:Inventra/features/dashboard/data/models/dashboard_model.dart';
import 'package:Inventra/features/dashboard/data/models/kpi_model.dart';
import 'package:Inventra/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:Inventra/objectbox.g.dart';
import 'package:flutter/material.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final ObjectBoxServices _objectBox;
  @override
  late DashboardModel cachedDashboardSnapshot;

  DashboardRepositoryImpl(this._objectBox) {
    cachedDashboardSnapshot = DashboardModel.initial();
  }
  @override
  void clearCachedDashboardSnapshot() {
    cachedDashboardSnapshot = DashboardModel.initial();
  }

  @override
  DashboardPeriodSnapshot getDashboardData({required DashboardPeriod period}) {
    final snapshot = cachedDashboardSnapshot.snapshots[period];

    if (snapshot != null) {
      return snapshot;
    }

    final newSnapshot = getDashboardSnapshot(period: period);
    cachedDashboardSnapshot = cachedDashboardSnapshot.insertSnapshot(
      snapshot: newSnapshot,
      period: period,
    );

    return newSnapshot;
  }

  @override
  DashboardPeriodSnapshot getDashboardSnapshot({
    required DashboardPeriod period,
  }) {
    final dateRange = getTimeRange(period);
    final entries = getEntries(period);

    final charts = <DashboardMetric, List<ChartPoint>>{
      for (final metric in DashboardMetric.values) metric: <ChartPoint>[],
    };
    final hasMetricData = <DashboardMetric, bool>{
      for (final metric in DashboardMetric.values) metric: false,
    };

    final bucketCount = _getBucketCount(period, dateRange.start.month);

    DateTime currentDateTime = _getNextBucket(dateRange.start, period);

    double salesKpi = 0;
    double purchasesKpi = 0;
    double expensesKpi = 0;
    double netProfitKpi = 0;

    double bucketSales = 0;
    double bucketPurchases = 0;
    double bucketExpenses = 0;
    double bucketNetProfit = 0;

    int bucketCountTransactions = 0;

    for (final entry in entries) {
      while (entry.createdAt.isAfter(currentDateTime)) {
        _addChartPoints(
          charts: charts,
          timestamp: currentDateTime,
          sales: bucketSales,
          purchases: bucketPurchases,
          expenses: bucketExpenses,
          netProfit: bucketNetProfit,
          count: bucketCountTransactions,
        );

        bucketSales = 0;
        bucketPurchases = 0;
        bucketExpenses = 0;
        bucketNetProfit = 0;
        bucketCountTransactions = 0;

        currentDateTime = _getNextBucket(currentDateTime, period);
      }
      double entryProfit = 0;

      switch (entry.type) {
        case TransactionType.sellingInvoice:
          salesKpi += entry.signedValue;
          bucketSales += entry.signedValue;
          entryProfit += entry.profit!;
          hasMetricData[DashboardMetric.sales] = true;
          hasMetricData[DashboardMetric.netProfit] = true;
        case TransactionType.buyingInvoice:
          purchasesKpi += entry.signedValue.abs();
          bucketPurchases += entry.signedValue.abs();
          hasMetricData[DashboardMetric.purchases] = true;

        case TransactionType.expense:
          expensesKpi += entry.signedValue.abs();
          bucketExpenses += entry.signedValue.abs();
          entryProfit += entry.signedValue;
          hasMetricData[DashboardMetric.expenses] = true;
          hasMetricData[DashboardMetric.netProfit] = true;
        default:
          break;
      }
      bucketNetProfit += entryProfit;

      netProfitKpi += entryProfit;
      bucketCountTransactions++;
    }

    _addChartPoints(
      charts: charts,
      timestamp: currentDateTime,
      sales: bucketSales,
      purchases: bucketPurchases,
      expenses: bucketExpenses,
      netProfit: bucketNetProfit,
      count: bucketCountTransactions,
    );

    currentDateTime = _getNextBucket(currentDateTime, period);

    for (var metric in DashboardMetric.values) {
      final points = charts[metric]!;

      if (!hasMetricData[metric]!) {
        points.clear();
        continue;
      }

      var time = currentDateTime;
      while (points.length < bucketCount) {
        points.add(ChartPoint(timestamp: time, value: 0, count: 0));
        time = _getNextBucket(time, period);
      }
    }

    return DashboardPeriodSnapshot(
      kpis: KpiModel(
        netProfit: netProfitKpi,
        sales: salesKpi,
        purchases: purchasesKpi,
        expenses: expensesKpi,
      ),
      charts: charts,
    );
  }

  @override
  List<TransactionsEntry> getEntries(DashboardPeriod period) {
    final dateRange = getTimeRange(period);

    final Condition<TransactionsEntry> timeCondition = TransactionsEntry_
        .createdAt
        .betweenDate(dateRange.start, dateRange.end);

    final query = _objectBox.transactionsEntryBox
        .query(timeCondition)
        .order(TransactionsEntry_.createdAt)
        .build();
    final entries = query.find();

    query.close();
    return entries;
  }

  @override
  DateTimeRange getTimeRange(DashboardPeriod period) {
    late final DateTime start;
    late final DateTime end;
    final now = DateTime.now();
    switch (period) {
      case DashboardPeriod.today:
        start = DateTime(now.year, now.month, now.day, 0, 0, 0);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
      case DashboardPeriod.week:
        int daysToSubtract = (now.weekday + 1) % 7;

        start = DateTime(
          now.year,
          now.month,
          now.day - daysToSubtract,
          0,
          0,
          0,
        );
        end = DateTime(
          now.year,
          now.month,
          (now.day - daysToSubtract) + 6,
          23,
          59,
          59,
          999,
        );
      case DashboardPeriod.month:
        start = DateTime(now.year, now.month, 1, 0, 0, 0);
        end = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
      case DashboardPeriod.year:
        start = DateTime(now.year, 1, 1, 0, 0, 0);
        end = DateTime(now.year, 12, 31, 23, 59, 59, 999);
    }
    return DateTimeRange(start: start, end: end);
  }

  DateTime _getNextBucket(DateTime current, DashboardPeriod period) {
    switch (period) {
      case DashboardPeriod.today:
        return current.add(const Duration(hours: 3));

      case DashboardPeriod.week:
        return current.add(const Duration(days: 1));
      case DashboardPeriod.month:
        return current.add(const Duration(days: 1));

      case DashboardPeriod.year:
        return DateTime(current.year, current.month + 1, 1);
    }
  }

  int _daysInMonth(int month) {
    final now = DateTime.now();
    final date = DateTime(now.year, month);
    return DateTime(date.year, date.month + 1, 0).day;
  }

  int _getBucketCount(DashboardPeriod period, int month) {
    switch (period) {
      case DashboardPeriod.today:
        return 8;

      case DashboardPeriod.week:
        return 7;

      case DashboardPeriod.month:
        return _daysInMonth(month);
      case DashboardPeriod.year:
        return 12;
    }
  }

  void _addChartPoints({
    required Map<DashboardMetric, List<ChartPoint>> charts,
    required DateTime timestamp,
    required double sales,
    required double purchases,
    required double expenses,
    required double netProfit,
    required int count,
  }) {
    charts[DashboardMetric.sales]!.add(
      ChartPoint(timestamp: timestamp, value: sales, count: count),
    );

    charts[DashboardMetric.purchases]!.add(
      ChartPoint(timestamp: timestamp, value: purchases, count: count),
    );

    charts[DashboardMetric.expenses]!.add(
      ChartPoint(timestamp: timestamp, value: expenses, count: count),
    );

    charts[DashboardMetric.netProfit]!.add(
      ChartPoint(timestamp: timestamp, value: netProfit, count: count),
    );
  }
}
