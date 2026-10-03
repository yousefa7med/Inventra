part of 'safe_cubit.dart';

sealed class SafeState {}

class SafeInitial extends SafeState {}

class SafeLoading extends SafeState {}

class SafeLoaded extends SafeState {
  final double safeBalance;
  final List<ListItemModel> listItems;

  SafeLoaded({required this.safeBalance, required this.listItems});

  SafeLoaded copyWith({
    double? safeBalance,
    final List<ListItemModel>? listItems,
  }) => SafeLoaded(
    safeBalance: safeBalance ?? this.safeBalance,
    listItems: listItems ?? this.listItems,
  );
}

class SafeError extends SafeState {
  final String message;
  SafeError(this.message);
}
