part of 'safe_cubit.dart';

sealed class SafeState {}

class SafeInitial extends SafeState {}

class SafeLoading extends SafeState {}

class SafeLoaded extends SafeState {}

class SafeError extends SafeState {
  final String message;
  SafeError(this.message);
}

