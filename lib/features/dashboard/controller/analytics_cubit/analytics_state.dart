part of 'analytics_cubit.dart';

sealed class AnalyticsState {}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsError extends AnalyticsState {
  final String message;

  AnalyticsError(this.message);
}

class AnalyticsLoaded extends AnalyticsState {
  final DashboardPeriodSnapshot snapshot;
  final DashboardMetric selectedMetric;
  final DashboardPeriod selectedPeriod;

  AnalyticsLoaded({
    required this.snapshot,
    required this.selectedMetric,
    required this.selectedPeriod,
  });

  AnalyticsLoaded copyWith({
    DashboardPeriodSnapshot? snapshot,
    DashboardMetric? selectedMetric,
    double? safeBalance,
    DashboardPeriod? selectedPeriod,
  }) {
    return AnalyticsLoaded(
      snapshot: snapshot ?? this.snapshot,
      selectedMetric: selectedMetric ?? this.selectedMetric,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
    );
  }
}
