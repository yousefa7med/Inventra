import 'dart:async';
import 'package:Inventra/core/models/expense_model.dart';
import 'package:Inventra/core/models/safe_balance_model.dart';
import 'package:Inventra/core/models/transactions_entry.dart';
import 'package:Inventra/core/services/transaction_change_notifier.dart';
import 'package:Inventra/features/dashboard/data/repositories/dashboard_repository/dashboard_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_cubit_interface.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState>
    implements DashboardCubitInterface {
  final DashboardRepository _repository;
  final TransactionChangeNotifier _transactionChangeNotifier;
  late final StreamSubscription<TransactionsEntry> _transactionSubscription;
  DashboardCubit(this._repository, this._transactionChangeNotifier)
    : super(DashboardInitial()) {
    _transactionSubscription = _transactionChangeNotifier.stream.listen((
      entry,
    ) {
      _safeBalance = _safeBalance.copyWith(
        currentBalance: _safeBalance.currentBalance + entry.signedValue,
        lastUpdated: entry.createdAt,
      );
      emit(DashboardLoaded(safeBalance: _safeBalance));
    });
  }

  late SafeBalanceModel _safeBalance;

  @override
  double get balance => _safeBalance.currentBalance;

  @override
  void loadSafeBalance() {
    emit(DashboardLoading());
    try {
      _safeBalance = _repository.getBalance();
      emit(DashboardLoaded(safeBalance: _safeBalance));
    } catch (e) {
      DashboardError(e.toString());
    }
  }

  @override
  bool addExpense({required double value, required String note}) {
    try {
      final expense = ExpenseModel(
        date: DateTime.now(),
        value: -value,
        note: note.trim(),
      );

      _repository.addExpense(expense);
      _safeBalance = _safeBalance.copyWith(
        currentBalance: _safeBalance.currentBalance + expense.value,
        lastUpdated: expense.date,
      );

      emit(DashboardLoaded(safeBalance: _safeBalance));
      return true;
    } catch (e) {
      emit(DashboardError('فشل إضافة المصروف: $e'));
      return false;
    }
  }

  @override
  Future<void> close() {
    _transactionSubscription.cancel();
    return super.close();
  }
}
