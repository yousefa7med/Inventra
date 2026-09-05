 
import 'package:Inventra/features/dashboard/data/enums/dashboard_metric.dart';
import 'package:Inventra/features/dashboard/data/enums/dashboard_period.dart';

abstract class DashboardCubitInterface {
  DashboardMetric get selectedMetric;
  DashboardPeriod get selectedPeriod;

  void init();
  void loadDashboard();
  void changePeriod(DashboardPeriod period);
  void changeChartMetric(DashboardMetric metric);
  void refresh();
}
