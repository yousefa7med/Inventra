import 'package:Inventra/features/dashboard/data/models/dashboard_metric.dart';

abstract class DashboardCubitInterface {
  DashboardMetric get selectedMetric;
  DashboardPeriod get selectedPeriod;

  void init();
  void loadDashboard();
  void changePeriod(DashboardPeriod period);
  void changeChartMetric(DashboardMetric metric);
  void refresh();
}
