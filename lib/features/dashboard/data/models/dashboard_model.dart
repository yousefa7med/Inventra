import 'package:Inventra/features/dashboard/data/models/kpi_model.dart';

import 'chart_point.dart';
import 'dashboard_metric.dart';

class DashboardModel {
  final Map<DashboardPeriod, DashboardPeriodSnapshot?> snapshots;

  const DashboardModel({required this.snapshots});

  factory DashboardModel.initial() {
    return DashboardModel(
      snapshots: {for (final period in DashboardPeriod.values) period: null},
    );
  }

  DashboardPeriodSnapshot? getSnapshot(DashboardPeriod period) {
    return snapshots[period];
  }

  DashboardModel insertSnapshot({
    required DashboardPeriod period,
    required DashboardPeriodSnapshot snapshot,
  }) {
    snapshots[period] = snapshot;
    return this;
  }

  void clear() {
    for (final period in DashboardPeriod.values) {
      snapshots[period] = null;
    }
  }
}

class DashboardPeriodSnapshot {
  final KpiModel kpis;
  final Map<DashboardMetric, List<ChartPoint>> charts;

  const DashboardPeriodSnapshot({required this.kpis, required this.charts});
}
