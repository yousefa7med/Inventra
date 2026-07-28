import 'package:Inventra/core/models/expense_model.dart';
import 'package:Inventra/features/safe/controller/cubit/safe_cubit_interface.dart';
import 'package:Inventra/features/safe/data/repositories/safe_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'safe_state.dart';

class SafeCubit extends Cubit<SafeState> implements SafeCubitInterface {
  final SafeRepository _repository;
  DateTimeRange<DateTime>? _selectedDateRange;
  double _currentBalance = 0;

  List<ExpenseModel> _expenses = [];

  String? _searchText;

  SafeCubit(this._repository) : super(SafeInitial());

  @override
  double get currentBalance => _currentBalance;

  @override
  DateTimeRange<DateTime>? get selectedDateRange => _selectedDateRange;
  @override
  List<ExpenseModel> get expenses => _expenses;

  @override
  String? get searchText => _searchText;

  void init() {
    emit(SafeLoading());

    try {
      _currentBalance = _repository.getBalance().currentBalance;
      _expenses = _repository.loadExpenses();
      emit(SafeLoaded());
    } catch (e) {
      emit(SafeError("فشل في تحميل بايانات الخزنة"));
    }
  }

  @override
  void addExpense({required double value, required String note}) {
  

    try {
      emit(SafeLoading());
      final expense = ExpenseModel(
        date: DateTime.now(),
        value: -value,
        note: note.trim(),
      );
      _expenses.add(expense);
      _repository.addExpense(expense);
      _currentBalance -= value;
      emit(SafeLoaded());
    } catch (e) {
      emit(SafeError('فشل إضافة المصروف: $e'));
    }
  }

  @override
  void adjustBalance({required double newBalance, String? note}) {
    try {
      emit(SafeLoading());
      _repository.adjustBalance(newAmount: newBalance, newNote: note);
      _currentBalance = newBalance;
      emit(SafeLoaded());
    } catch (e) {
      emit(SafeError('فشل تعديل الرصيد: $e'));
    }
  }

  @override
  void getExpenses({DateTimeRange<DateTime>? dateRange, String? searchText}) {
    if (dateRange == null) {
      dateRange = _selectedDateRange;
    } else {
      _selectedDateRange = dateRange;
    }
    if (searchText == null) {
      searchText = _searchText;
    } else {
      _searchText = searchText;
    }
    try {
      emit(SafeLoading());
      _expenses = _repository.loadExpenses(
        dateRange: dateRange,
        searchText: searchText,
      );
      emit(SafeLoaded());
    } catch (e) {
      emit(SafeError("فشل في تحميل المصاريف"));
    }
  }

  @override
  void clearDateFilter() {
    _selectedDateRange = null;
    try {
      emit(SafeLoading());
      _expenses = _repository.loadExpenses(searchText: _searchText);
      emit(SafeLoaded());
    } catch (e) {
      emit(SafeError("فشل في تحميل المصاريف"));
    }
  }

  @override
  void clearSearchFilter() {
    _searchText = null;
    try {
      emit(SafeLoading());
      _expenses = _repository.loadExpenses(dateRange: _selectedDateRange);
      emit(SafeLoaded());
    } catch (e) {
      emit(SafeError("فشل في تحميل المصاريف"));
    }
  }
}
