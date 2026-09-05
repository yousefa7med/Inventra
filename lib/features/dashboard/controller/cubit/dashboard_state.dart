 import 'package:Inventra/features/dashboard/data/enums/dashboard_metric.dart';
import 'package:Inventra/features/dashboard/data/enums/dashboard_period.dart';
import 'package:Inventra/features/dashboard/data/models/dashboard_model.dart';

sealed class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardPeriodSnapshot snapshot;
  final DashboardMetric selectedMetric;
  final DashboardPeriod selectedPeriod;
  final double safeBalance;

  DashboardLoaded({
    required this.snapshot,
    required this.selectedMetric,
    required this.selectedPeriod,
    required this.safeBalance,
  });

  DashboardLoaded copyWith({
    DashboardPeriodSnapshot? snapshot,
    DashboardMetric? selectedMetric,
    double? safeBalance,
    DashboardPeriod? selectedPeriod,
  }) {
    return DashboardLoaded(
      snapshot: snapshot ?? this.snapshot,
      selectedMetric: selectedMetric ?? this.selectedMetric,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      safeBalance: safeBalance ?? this.safeBalance,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError(this.message);
}
