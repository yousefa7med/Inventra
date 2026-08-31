part of 'safe_cubit.dart';

sealed class SafeState {}

class SafeInitial extends SafeState {}

class SafeLoading extends SafeState {}

class SafeLoaded extends SafeState {
  final double safeBalance;
  final List<ExpenseListItem> expenseListItem;

  SafeLoaded({required this.safeBalance, required this.expenseListItem});

  SafeLoaded copyWith({
    double? safeBalance,
    List<ExpenseListItem>? expenseListItem,
  }) => SafeLoaded(
    safeBalance: safeBalance ?? this.safeBalance,
    expenseListItem: expenseListItem ?? this.expenseListItem,
  );
}

class SafeError extends SafeState {
  final String message;
  SafeError(this.message);
}
