// import 'package:Inventra/core/models/expense_model.dart'
import 'package:Inventra/features/dashboard/data/enums/dashboard_period.dart';
import 'package:Inventra/features/dashboard/data/models/dashboard_model.dart';

abstract class AnalyticsRepository {
  late DashboardModel cachedDashboardSnapshot;
  void clearCachedDashboardSnapshot();
  DashboardPeriodSnapshot getDashboardData({required DashboardPeriod period});
}
