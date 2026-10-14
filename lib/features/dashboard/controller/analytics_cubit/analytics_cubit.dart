import 'package:Inventra/features/dashboard/controller/analytics_cubit/analytics_cubit_interface.dart';
import 'package:Inventra/features/dashboard/data/enums/dashboard_metric.dart';
import 'package:Inventra/features/dashboard/data/enums/dashboard_period.dart';
import 'package:Inventra/features/dashboard/data/models/dashboard_model.dart';
import 'package:Inventra/features/dashboard/data/repositories/analytics_repository/analytics_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState>
    implements AnalyticsCubitInterface {
  final AnalyticsRepository _repository;

  AnalyticsCubit(this._repository) : super(AnalyticsInitial());
  DashboardMetric _selectedMetric = DashboardMetric.netProfit;
  DashboardPeriod _selectedPeriod = DashboardPeriod.today;

  @override
  DashboardMetric get selectedMetric => _selectedMetric;

  @override
  DashboardPeriod get selectedPeriod => _selectedPeriod;

  @override
  void loadDashboard() {
    _repository.clearCachedDashboardSnapshot();
    emit(AnalyticsLoading());
    try {
      final snapshot = _repository.getDashboardData(period: _selectedPeriod);
      emit(
        AnalyticsLoaded(
          snapshot: snapshot,
          selectedMetric: _selectedMetric,
          selectedPeriod: _selectedPeriod,
        ),
      );
    } catch (e) {
      emit(AnalyticsError('فشل في تحميل بيانات لوحة التحكم: $e'));
    }
  }

  @override
  void changePeriod(DashboardPeriod period) {
    _selectedPeriod = period;
    loadDashboard();
  }

  @override
  void changeChartMetric(DashboardMetric metric) {
    if (_selectedMetric == metric) return;

    _selectedMetric = metric;

    if (state is AnalyticsLoaded) {
      emit((state as AnalyticsLoaded).copyWith(selectedMetric: metric));
    }
  }
}
