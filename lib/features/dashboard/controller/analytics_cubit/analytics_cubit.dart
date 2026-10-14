import 'dart:async';

import 'package:Inventra/core/models/expense_model.dart';
import 'package:Inventra/core/models/transaction_type.dart';
import 'package:Inventra/core/services/Transaction_change_notifier.dart';
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
  final TransactionChangeNotifier _transactionChangeNotifier;
  late final StreamSubscription<TransactionType> _transactionSubscription;
  AnalyticsCubit(this._repository, this._transactionChangeNotifier)
    : super(AnalyticsInitial()) {
    _transactionSubscription = _transactionChangeNotifier.stream.listen((type) {
      switch (type) {
        case TransactionType.sellingInvoice:
          loadSafeBalance();
          _repository.clearCachedDashboardSnapshot();
          loadDashboard();
        case TransactionType.expense:
          loadSafeBalance();
          _repository.clearCachedDashboardSnapshot();
          loadDashboard();

        case TransactionType.buyingInvoice:
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
    emit(AnalyticsLoading());

    loadDashboard();
  }

  @override
  Future<void> close() {
    _transactionSubscription.cancel();
    return super.close();
  }

  void loadSafeBalance() {
    safeBalance = _repository.getBalance().currentBalance;
    if (state is AnalyticsLoaded) {
      emit((state as AnalyticsLoaded).copyWith(safeBalance: safeBalance));
    }
  }

  @override
  void loadDashboard() {
    try {
      safeBalance = _repository.getBalance().currentBalance;
      final snapshot = _repository.getDashboardData(period: _selectedPeriod);
      emit(
        AnalyticsLoaded(
          snapshot: snapshot,
          selectedMetric: _selectedMetric,
          selectedPeriod: _selectedPeriod,
          safeBalance: safeBalance,
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

    final currentState = state;

    if (currentState is AnalyticsLoaded) {
      emit(currentState.copyWith(selectedMetric: metric));
    }
  }

  @override
  void refresh() {
    _repository.clearCachedDashboardSnapshot();
    emit(AnalyticsLoading());

    loadDashboard();
  }

  @override
  void addExpense({required double value, required String note}) {
    try {
      final expense = ExpenseModel(
        date: DateTime.now(),
        value: -value,
        note: note.trim(),
      );

      _repository.addExpense(expense);
      safeBalance -= value;
    } catch (e) {
      emit(AnalyticsError('فشل إضافة المصروف: $e'));
    }
  }
}
