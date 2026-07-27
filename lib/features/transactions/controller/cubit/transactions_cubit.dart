import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Inventra/core/models/transactions_entry.dart';
import 'package:Inventra/core/models/transaction_type.dart';
import 'package:Inventra/features/transactions/controller/cubit/transactions_cubit_interface.dart';
import 'package:Inventra/features/transactions/controller/cubit/transactions_state.dart';
import 'package:Inventra/features/transactions/data/repositories/transactions_repository.dart';

class TransactionsCubit extends Cubit<TransactionsState>
    implements TransactionsCubitInterface {
  final TransactionsRepository _repository;

  TransactionsCubit(this._repository) : super(TransactionsInitial());

  List<TransactionsEntry> _transactions = [];
  DateTimeRange<DateTime>? _selectedDateRange;
  int? _selectedType;

  @override
  List<TransactionsEntry> get transactions => _transactions;

  @override
  DateTimeRange<DateTime>? get selectedDateRange => _selectedDateRange;

  @override
  int? get selectedType => _selectedType;

  @override
  void loadTransactions({
    TransactionType? type,
    DateTimeRange<DateTime>? dateRange,
  }) async {
    if (type == null) {
      type = _selectedType == null
          ? null
          : TransactionType.values[_selectedType!];
    } else {
      _selectedType = type.index;
    }

    if (dateRange == null) {
      dateRange = _selectedDateRange;
    } else {
      _selectedDateRange = dateRange;
    }

    emit(TransactionsLoading());
    try {
      _transactions = _repository.getTransactions(
        type: type,
        dateRange: dateRange,
      );
      emit(TransactionsLoaded(transactions: _transactions));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  @override
  void clearFilters() async {
    _selectedType = null;
    _selectedDateRange = null;
    emit(TransactionsLoading());
    try {
      _transactions = _repository.getTransactions();
      emit(TransactionsLoaded(transactions: _transactions));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  @override
  void clearDateFilter() {
    _selectedDateRange = null;
    emit(TransactionsLoading());
    try {
      _transactions = _repository.getTransactions(
        type: _selectedType == null
            ? null
            : TransactionType.values[_selectedType!],
      );
      emit(TransactionsLoaded(transactions: _transactions));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  @override
  void clearTypeFilter() {
    _selectedType = null;
    emit(TransactionsLoading());
    try {
      _transactions = _repository.getTransactions(
        dateRange: _selectedDateRange,
      );
      emit(TransactionsLoaded(transactions: _transactions));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }
}
