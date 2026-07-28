import 'package:Inventra/core/models/expense_model.dart';
import 'package:Inventra/features/safe/controller/cubit/safe_cubit_interface.dart';
import 'package:Inventra/features/safe/data/repositories/safe_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'safe_state.dart';

class SafeCubit extends Cubit<SafeState> implements SafeCubitInterface {
  final SafeRepository _repository;
  DateTimeRange<DateTime>? _selectedDateRange;
  double? _currentBalance;

  List<ExpenseModel> _expenses = [];

  String? _searchText;

  SafeCubit(this._repository) : super(SafeInitial());

  @override
  double get currentBalance => _currentBalance ?? 0;

  @override
  DateTimeRange<DateTime>? get selectedDateRange => _selectedDateRange;
  @override
  List<ExpenseModel> get expenses => _expenses;

  @override
  String? get searchText => _searchText;

  @override
  void addExpense({required double value, required String note}) {
    // if (value <= 0) {
    //   // return const Failure(
    //   //   'قيمة المصروف يجب أن تكون موجبة',
    //   //   code: FailureCode.validationError,
    //   // );
    // }
    // if (note.trim().isEmpty) {
    //   return const Failure(
    //     'ملاحظة المصروف مطلوبة',
    //     code: FailureCode.validationError,
    //   );
    // }

    try {
      emit(ExpensesLoading());
      final expense = ExpenseModel(
        date: DateTime.now(),
        value: -value,
        note: note.trim(),
      );
      _expenses.add(expense);
      _repository.addExpense(expense);
      emit(ExpensesLoaded());
    } catch (e) {
      emit(ExpensesError('فشل إضافة المصروف: $e'));
    }
  }

  @override
  void adjustBalance({required double newBalance, String? note}) {
    // if (newBalance > 999999999.99 || newBalance < -999999999.99) {
    //   return const Failure('رصيد غير صالح', code: FailureCode.validationError);
    // }

    try {
      emit(SafeLoading());
      _repository.adjustBalance(newAmount: newBalance, newNote: note);

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
      emit(ExpensesLoading());
      _expenses = _repository.loadExpenses(
        dateRange: dateRange,
        searchText: searchText,
      );
      emit(ExpensesLoaded());
    } catch (e) {
      emit(ExpensesError("فشل في تحميل المصاريف"));
    }
  }
}
