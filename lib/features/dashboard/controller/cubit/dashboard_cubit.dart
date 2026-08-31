import 'package:Inventra/features/dashboard/data/models/dashboard_metric.dart';
import 'package:Inventra/features/dashboard/data/models/kpi_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_state.dart';
import 'dashboard_cubit_interface.dart';
import '../../data/repositories/dashboard_repository.dart';

class DashboardCubit extends Cubit<DashboardState>
    implements DashboardCubitInterface {
  final DashboardRepository _repository;
  DashboardCubit(this._repository) : super(DashboardInitial());

  DashboardMetric _selectedMetric = DashboardMetric.netProfit;
  DashboardPeriod _selectedPeriod = DashboardPeriod.today;
  late final KpiModel _kpis;

  @override
  DashboardMetric get selectedMetric => _selectedMetric;
  @override
  KpiModel get kpis => _kpis;

  @override
  DashboardPeriod get selectedPeriod => _selectedPeriod;

  @override
  void init() {
    loadDashboard();
  }

  @override
  void loadDashboard() {
    emit(DashboardLoading());
    try {
      final snapshot = _repository.getDashboardData(period: _selectedPeriod);
      emit(
        DashboardLoaded(
          snapshot: snapshot,
          selectedMetric: _selectedMetric,
          selectedPeriod: _selectedPeriod,
        ),
      );
    } catch (e) {
      emit(DashboardError('فشل في تحميل بيانات لوحة التحكم: $e'));
    }
  }

  @override
  void changePeriod(DashboardPeriod period) {
    _selectedPeriod = period;
    loadDashboard();
  }

  @override
  void changeChartMetric(DashboardMetric metric) {
    _selectedMetric = metric;
    loadDashboard();
  }

  @override
  void refresh() {
    loadDashboard();
  }
}
