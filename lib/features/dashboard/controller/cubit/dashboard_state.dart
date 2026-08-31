import 'package:Inventra/features/dashboard/data/models/dashboard_metric.dart';
import 'package:Inventra/features/dashboard/data/models/dashboard_model.dart';

sealed class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardModel snapshot;
  final DashboardMetric selectedMetric;
  final DashboardPeriod selectedPeriod;

  DashboardLoaded({required this.snapshot, required this.selectedMetric, required this.selectedPeriod});

  DashboardLoaded copyWith({
    DashboardModel? snapshot,
    DashboardMetric? selectedMetric,
    DashboardPeriod? selectedPeriod,
  }) {
    return DashboardLoaded(
      snapshot: snapshot ?? this.snapshot,
      selectedMetric: selectedMetric ?? this.selectedMetric, selectedPeriod: selectedPeriod??this.selectedPeriod,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError(this.message);
}
