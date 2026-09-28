import 'dart:developer';

import 'package:Inventra/core/models/transaction_type.dart';
import 'package:Inventra/core/services/Transaction_change_notifier.dart';
import 'package:Inventra/features/dashboard/data/enums/dashboard_metric.dart';
import 'package:Inventra/features/dashboard/data/enums/dashboard_period.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_state.dart';
import 'dashboard_cubit_interface.dart';
import '../../data/repositories/dashboard_repository.dart';

class DashboardCubit extends Cubit<DashboardState>
    implements DashboardCubitInterface {
  final DashboardRepository _repository;
  final TransactionChangeNotifier _transactionChangeNotifier;

  DashboardCubit(this._repository, this._transactionChangeNotifier)
    : super(DashboardInitial()) {
    _transactionChangeNotifier.stream.listen((type) {
      log("message");
      switch (type) {
        case TransactionType.sellingInvoice:
          loadSafeBalance();
          _repository.clearCachedDashboardSnapshot();
          loadDashboard();
        case TransactionType.expense:
          loadSafeBalance();
          _repository.clearCachedDashboardSnapshot();
          loadDashboard();

        default:
          loadSafeBalance();
      }
    });
  }
  double safeBalance = 0;
  DashboardMetric _selectedMetric = DashboardMetric.netProfit;
  DashboardPeriod _selectedPeriod = DashboardPeriod.today;

  @override
  DashboardMetric get selectedMetric => _selectedMetric;

  @override
  DashboardPeriod get selectedPeriod => _selectedPeriod;

  @override
  void init() {
    emit(DashboardLoading());

    loadDashboard();
  }

  void loadSafeBalance() {
    safeBalance = _repository.getBalance();
    if (state is DashboardLoaded) {
      emit((state as DashboardLoaded).copyWith(safeBalance: safeBalance));
    }
  }

  @override
  void loadDashboard() {
    try {
      safeBalance = _repository.getBalance();
      final snapshot = _repository.getDashboardData(period: _selectedPeriod);
      emit(
        DashboardLoaded(
          snapshot: snapshot,
          selectedMetric: _selectedMetric,
          selectedPeriod: _selectedPeriod,
          safeBalance: safeBalance,
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
    if (_selectedMetric == metric) return;

    _selectedMetric = metric;

    final currentState = state;

    if (currentState is DashboardLoaded) {
      emit(currentState.copyWith(selectedMetric: metric));
    }
  }

  @override
  void refresh() {
    _repository.clearCachedDashboardSnapshot();
    emit(DashboardLoading());

    loadDashboard();
  }
}
