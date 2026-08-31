import 'package:Inventra/features/dashboard/data/models/dashboard_metric.dart';
import 'package:Inventra/features/dashboard/data/models/kpi_model.dart';

abstract class DashboardCubitInterface {
  DashboardMetric get selectedMetric;
  DashboardPeriod get selectedPeriod;
  KpiModel get kpis;

  void init();
  void loadDashboard();
  void changePeriod(DashboardPeriod period);
  void changeChartMetric(DashboardMetric metric);
  void refresh();
}
