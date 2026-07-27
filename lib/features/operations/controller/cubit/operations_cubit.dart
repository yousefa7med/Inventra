import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Inventra/core/models/transactions_entry.dart';
import 'package:Inventra/core/models/balance_change_type.dart';
import 'package:Inventra/features/operations/controller/cubit/operations_cubit_interface.dart';
import 'package:Inventra/features/operations/controller/cubit/operations_state.dart';
import 'package:Inventra/features/operations/data/repositories/operations_repository.dart';

class OperationsCubit extends Cubit<OperationsState>
    implements OperationsCubitInterface {
  final OperationsRepository _repository;

  OperationsCubit(this._repository) : super(OperationsInitial());

  List<TransactionsEntry> _operations = [];
  DateTimeRange<DateTime>? _selectedDateRange;
  int? _selectedType;

  @override
  List<TransactionsEntry> get operations => _operations;

  @override
  DateTimeRange<DateTime>? get selectedDateRange => _selectedDateRange;

  @override
  int? get selectedType => _selectedType;

  @override
  void loadOperations({
    BalanceChangeType? type,
    DateTimeRange<DateTime>? dateRange,
  }) async {
    if (type == null) {
      type = _selectedType == null
          ? null
          : BalanceChangeType.values[_selectedType!];
    } else {
      _selectedType = type.index;
    }

    if (dateRange == null) {
      dateRange = _selectedDateRange;
    } else {
      _selectedDateRange = dateRange;
    }

    emit(OperationsLoading());
    try {
      _operations = _repository.getOperations(type: type, dateRange: dateRange);
      emit(OperationsLoaded(transactions: operations));
    } catch (e) {
      emit(OperationsError(e.toString()));
    }
  }

  @override
  void clearFilters() async {
    _selectedType = null;
    _selectedDateRange = null;
    emit(OperationsLoading());
    try {
      _operations = _repository.getOperations();
      emit(OperationsLoaded(transactions: operations));
    } catch (e) {
      emit(OperationsError(e.toString()));
    }
  }
  @override
  void clearDateFilter() {
    _selectedDateRange = null;
    emit(OperationsLoading());
    try {
      _operations = _repository.getOperations(
        type: _selectedType == null
            ? null
            : BalanceChangeType.values[_selectedType!],
      );
      emit(OperationsLoaded(transactions: operations));
    } catch (e) {
      emit(OperationsError(e.toString()));
    }
  }

  @override
  void clearTypeFilter() {
    _selectedType = null;
    emit(OperationsLoading());
    try {
      _operations = _repository.getOperations(dateRange: _selectedDateRange);
      emit(OperationsLoaded(transactions: operations));
    } catch (e) {
      emit(OperationsError(e.toString()));
    }
  }
}
