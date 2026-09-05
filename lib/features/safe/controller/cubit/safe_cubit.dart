
import 'package:Inventra/core/models/expense_model.dart';
import 'package:Inventra/features/safe/controller/cubit/safe_cubit_interface.dart';
import 'package:Inventra/features/safe/data/models/expense_list_item.dart';
import 'package:Inventra/features/safe/data/repositories/safe_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'safe_state.dart';

class SafeCubit extends Cubit<SafeState> implements SafeCubitInterface {
  final SafeRepository _repository;

  SafeCubit(this._repository) : super(SafeInitial());

  double _currentBalance = 0;

  String _searchText = '';

  @override
  String? get searchText => _searchText;

  void init() {
    emit(SafeLoading());
    try {
      _searchText = '';
      _currentBalance = _repository.getBalance().currentBalance;
      final expenses = _repository.loadExpenses('');
      final expenseListItem = generateExpensesListItem(expenses);
      emit(
        SafeLoaded(
          safeBalance: _currentBalance,
          expenseListItem: expenseListItem,
        ),
      );
    } catch (e) {
      emit(SafeError("فشل في تحميل بايانات الخزنة"));
    }
  }

  @override
  void addExpense({required double value, required String note}) {
    try {
      
      final expense = ExpenseModel(
        date: DateTime.now(),
        value: -value,
        note: note.trim(),
      );
      final expenseListItem = (state as SafeLoaded).expenseListItem;
      if (expenseListItem.isNotEmpty) {
        expenseListItem.insert(1, ExpenseItem(expense: expense));
      } else {
        expenseListItem.add(ExpenseHeaderItem(date: expense.date));
        expenseListItem.add(ExpenseItem(expense: expense));
      }

      _repository.addExpense(expense);
      _currentBalance -= value;
      emit(
        (state as SafeLoaded).copyWith(
          safeBalance: _currentBalance,
          expenseListItem: expenseListItem,
        ),
      );
    } catch (e) {
      emit(SafeError('فشل إضافة المصروف: $e'));
    }
  }

  @override
  void adjustBalance({required double newBalance, String? note}) {
    try {
      _repository.adjustBalance(newAmount: newBalance, newNote: note);
      _currentBalance = newBalance;
      if (state is SafeLoaded) {
        emit((state as SafeLoaded).copyWith(safeBalance: _currentBalance));
      }
    } catch (e) {
      emit(SafeError('فشل تعديل الرصيد: $e'));
    }
  }

  @override
  void searchForExpenses(String searchText) {
    _searchText = searchText;

    try {
      final expenses = _repository.loadExpenses(searchText);
      final expenseListItem = generateExpensesListItem(expenses);
      if (state is SafeLoaded) {
        emit((state as SafeLoaded).copyWith(expenseListItem: expenseListItem));
      }
    } catch (e) {
      emit(SafeError("فشل في تحميل المصاريف"));
    }
  }

  @override
  void clearSearchFilter() {
    _searchText = '';
    try {
      final expenses = _repository.loadExpenses(_searchText);
      final expenseListItem = generateExpensesListItem(expenses);
      if (state is SafeLoaded) {
        emit((state as SafeLoaded).copyWith(expenseListItem: expenseListItem));
      }
    } catch (e) {
      emit(SafeError("فشل في تحميل المصاريف"));
    }
  }

  List<ExpenseListItem> generateExpensesListItem(List<ExpenseModel> expenses) {
    Map<DateTime, List<ExpenseModel>> grouped = {};
    for (var expense in expenses) {
      final date = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );

      grouped.putIfAbsent(date, () => []);
      grouped[date]!.add(expense);
    }
    final List<ExpenseListItem> expenseListItem = [];
    for (var item in grouped.entries) {
      final date = item.key;
      final list = item.value;
      expenseListItem.add(ExpenseHeaderItem(date: date));
      for (var expense in list) {
        expenseListItem.add(ExpenseItem(expense: expense));
      }
    }
    return expenseListItem;
  }
}
