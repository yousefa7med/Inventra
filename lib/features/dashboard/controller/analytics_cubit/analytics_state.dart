

part of 'analytics_cubit.dart';



sealed class AnalyticsState {}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final DashboardPeriodSnapshot snapshot;
  final DashboardMetric selectedMetric;
  final DashboardPeriod selectedPeriod;
  final double safeBalance;

  AnalyticsLoaded({
    required this.snapshot,
    required this.selectedMetric,
    required this.selectedPeriod,
    required this.safeBalance,
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
      safeBalance: safeBalance ?? this.safeBalance,
    );
  }
}

class AnalyticsError extends AnalyticsState {
  final String message;

  AnalyticsError(this.message);
}
