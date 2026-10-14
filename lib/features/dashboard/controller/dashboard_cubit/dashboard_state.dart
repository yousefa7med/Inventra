part of "dashboard_cubit.dart";

sealed class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardError extends DashboardState {
  final String message;

  DashboardError(this.message);
}

class DashboardLoaded extends DashboardState {
  final SafeBalanceModel safeBalance;

  DashboardLoaded({required this.safeBalance});
}
