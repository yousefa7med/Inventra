part of 'safe_cubit.dart';

sealed class SafeState {}

class SafeInitial extends SafeState {}

class SafeLoading extends SafeState {}

class SafeLoaded extends SafeState {
  final double balance;
  final List<ExpenseModel> expenses;
  final List<ExpenseModel> filteredExpenses;
  final DateTime? filterFrom;
  final DateTime? filterTo;
  final String? searchText;
  final bool isNegativeBalance;

  SafeLoaded({
    required this.balance,
    required this.expenses,
    required this.filteredExpenses,
    this.filterFrom,
    this.filterTo,
    this.searchText,
    required this.isNegativeBalance,
  });
}

class SafeError extends SafeState {
  final String message;
  SafeError(this.message);
}


class SafeBalanceAdjusting extends SafeState {
  final SafeLoaded previousState;
  SafeBalanceAdjusting(this.previousState);
}
