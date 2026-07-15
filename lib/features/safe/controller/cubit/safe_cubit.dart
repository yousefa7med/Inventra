import 'dart:async';

import 'package:Inventra/core/helper/arabic_normalizer.dart';
import 'package:Inventra/core/models/balance_audit_entry_model.dart';
import 'package:Inventra/core/models/balance_change_type.dart';
import 'package:Inventra/core/models/expense_model.dart';
import 'package:Inventra/core/models/safe_balance_model.dart';
import 'package:Inventra/core/utils/result.dart';
import 'package:Inventra/features/safe/controller/cubit/safe_cubit_interface.dart';
import 'package:Inventra/features/safe/data/repositories/safe_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'safe_state.dart';

class SafeCubit extends Cubit<SafeState> implements SafeCubitInterface {
  final SafeRepository _repository;

  DateTime? _filterFrom;
  DateTime? _filterTo;
  String? _searchText;

  SafeCubit(this._repository) : super(SafeInitial()) {
    _repository.watchExpenses().listen((expenses) {
      _applyFiltersAndEmit(expenses);
    });
    _repository.watchAuditEntries().listen((_) {
      _emitCurrentBalance();
    });
  }

  @override
  @override
  double get currentBalance {
    if (state is SafeLoaded) {
      return (state as SafeLoaded).balance;
    }
    return 0;
  }

  @override
  @override
  List<ExpenseModel> get filteredExpenses {
    if (state is SafeLoaded) {
      return (state as SafeLoaded).filteredExpenses;
    }
    return [];
  }

  @override
  DateTime? get filterFromDate => _filterFrom;

  @override
  DateTime? get filterToDate => _filterTo;

  @override
  String? get searchText => _searchText;

  @override
  Future<Result<void>> load() async {
    print("load");
    emit(SafeLoading());
    try {
      final balance = _repository.getBalance();
      final expenses = _repository.getAllExpenses();
      _applyFiltersAndEmit(expenses, balance: balance);
      return const Success(null);
    } catch (e) {
      emit(SafeError('فشل تحميل البيانات: $e'));
      return Failure('فشل تحميل البيانات: $e', code: FailureCode.databaseError);
    }
  }

  @override
  Future<Result<void>> addExpense({
    required double value,
    required String note,
  }) async {
    if (value <= 0) {
      return const Failure(
        'قيمة المصروف يجب أن تكون موجبة',
        code: FailureCode.validationError,
      );
    }
    if (note.trim().isEmpty) {
      return const Failure(
        'ملاحظة المصروف مطلوبة',
        code: FailureCode.validationError,
      );
    }

    try {
      final expense = ExpenseModel(
        date: DateTime.now(),
        value: value,
        note: note.trim(),
      );

      _repository.addExpense(expense);

      final balance = _repository.getBalance();
      final newBalance = balance.currentBalance - value;
      balance.currentBalance = newBalance;
      balance.lastUpdated = DateTime.now();
      _repository.updateBalance(newBalance);

      final auditEntry = BalanceAuditEntryModel(
        type: BalanceChangeType.expense.index,
        amount: -value,
        referenceId: expense.id,
        timestamp: DateTime.now(),
        note: note.trim(),
      );
      _repository.addAuditEntry(auditEntry);

      final expenses = _repository.getAllExpenses();
      _applyFiltersAndEmit(expenses, balance: balance);

      return const Success(null);
    } catch (e) {
      emit(SafeError('فشل إضافة المصروف: $e'));
      return Failure('فشل إضافة المصروف: $e', code: FailureCode.databaseError);
    }
  }

  @override
  void setDateFilter({DateTime? from, DateTime? to}) {
    _filterFrom = from;
    _filterTo = to;
    if (state is SafeLoaded) {
      final loaded = state as SafeLoaded;
      final filtered = _applyFilters(loaded.expenses);
      emit(
        SafeLoaded(
          balance: loaded.balance,
          expenses: loaded.expenses,
          filteredExpenses: filtered,
          filterFrom: _filterFrom,
          filterTo: _filterTo,
          searchText: _searchText,
          isNegativeBalance: loaded.balance < 0,
        ),
      );
    }
  }

  @override
  void setSearchFilter(String? text) {
    _searchText = text?.trim();
    if (_searchText?.isEmpty ?? true) {
      _searchText = null;
    }
    if (state is SafeLoaded) {
      final loaded = state as SafeLoaded;
      final filtered = _applyFilters(loaded.expenses);
      emit(
        SafeLoaded(
          balance: loaded.balance,
          expenses: loaded.expenses,
          filteredExpenses: filtered,
          filterFrom: _filterFrom,
          filterTo: _filterTo,
          searchText: _searchText,
          isNegativeBalance: loaded.balance < 0,
        ),
      );
    }
  }

  @override
  void clearFilters() {
    _filterFrom = null;
    _filterTo = null;
    _searchText = null;
    if (state is SafeLoaded) {
      final loaded = state as SafeLoaded;
      emit(
        SafeLoaded(
          balance: loaded.balance,
          expenses: loaded.expenses,
          filteredExpenses: loaded.expenses,
          filterFrom: null,
          filterTo: null,
          searchText: null,
          isNegativeBalance: loaded.balance < 0,
        ),
      );
    }
  }

  @override
  Future<Result<void>> adjustBalance({
    required double newBalance,
    String? note,
  }) async {
    if (newBalance > 999999999.99 || newBalance < -999999999.99) {
      return const Failure('رصيد غير صالح', code: FailureCode.validationError);
    }

    try {
      final current = _repository.getBalance();
      final delta = newBalance - current.currentBalance;

      _repository.updateBalance(newBalance);

      final auditEntry = BalanceAuditEntryModel(
        type: BalanceChangeType.manualAdjustment.index,
        amount: delta,
        referenceId: 0,
        timestamp: DateTime.now(),
        note: note?.trim(),
      );
      _repository.addAuditEntry(auditEntry);

      final expenses = _repository.getAllExpenses();
      _applyFiltersAndEmit(
        expenses,
        balance: SafeBalanceModel(
          currentBalance: newBalance,
          lastUpdated: DateTime.now(),
        ),
      );

      return const Success(null);
    } catch (e) {
      emit(SafeError('فشل تعديل الرصيد: $e'));
      return Failure('فشل تعديل الرصيد: $e', code: FailureCode.databaseError);
    }
  }

  // @override
  // Future<Result<void>> adjustBalanceForTransaction({
  //   required double amount,
  //   required BalanceChangeType type,
  //   required int referenceId,
  //   String? note,
  // }) async {
  //   if (amount == 0) {
  //     return const Failure(
  //       'المبلغ يجب ألا يكون صفراً',
  //       code: FailureCode.validationError,
  //     );
  //   }
  //   if (type != BalanceChangeType.manualAdjustment && referenceId <= 0) {
  //     return const Failure('المرجع غير صالح', code: FailureCode.notFound);
  //   }

  //   try {
  //     final current = _repository.getBalance();
  //     final newBalance = current.currentAmount + amount;

  //     _repository.updateBalance(newBalance);

  //     final auditEntry = BalanceAuditEntryModel(
  //       type: type.index,
  //       amount: amount,
  //       referenceId: referenceId,
  //       timestamp: DateTime.now(),
  //       note: note?.trim(),
  //     );
  //     _repository.addAuditEntry(auditEntry);

  //     final expenses = _repository.getAllExpenses();
  //     _applyFiltersAndEmit(
  //       expenses,
  //       balance: SafeBalanceModel(
  //         currentAmount: newBalance,
  //         lastUpdated: DateTime.now(),
  //       ),
  //     );

  //     return const Success(null);
  //   } catch (e) {
  //     return Failure('فشل تحديث الرصيد: $e', code: FailureCode.databaseError);
  //   }
  // }

  // Add this method for increasing safe balance from sell invoice
  Future<void> increaseSafeBalance(double amount) async {
    if (amount <= 0) return;
    final current = _repository.getBalance();
    final newBalance = current.currentBalance + amount;
    _repository.updateBalance(newBalance);

    final auditEntry = BalanceAuditEntryModel(
      type: BalanceChangeType.sellInvoice.index,
      amount: amount,
      referenceId: 0, // Will be set by caller
      timestamp: DateTime.now(),
      note: 'فاتورة بيع',
    );
    _repository.addAuditEntry(auditEntry);

    final expenses = _repository.getAllExpenses();
    _applyFiltersAndEmit(
      expenses,
      balance: SafeBalanceModel(
        currentBalance: newBalance,
        lastUpdated: DateTime.now(),
      ),
    );
  }

  void _applyFiltersAndEmit(
    List<ExpenseModel> expenses, {
    SafeBalanceModel? balance,
  }) {
    final filtered = _applyFilters(expenses);
    final currentBalance =
        balance?.currentBalance ??
        (state is SafeLoaded ? (state as SafeLoaded).balance : 0);
    emit(
      SafeLoaded(
        balance: currentBalance,
        expenses: expenses,
        filteredExpenses: filtered,
        filterFrom: _filterFrom,
        filterTo: _filterTo,
        searchText: _searchText,
        isNegativeBalance: currentBalance < 0,
      ),
    );
  }

  List<ExpenseModel> _applyFilters(List<ExpenseModel> expenses) {
    var result = List<ExpenseModel>.from(expenses);

    if (_filterFrom != null) {
      final from = DateTime(
        _filterFrom!.year,
        _filterFrom!.month,
        _filterFrom!.day,
      );
      result = result
          .where((e) => e.date.isAfter(from) || e.date.isAtSameMomentAs(from))
          .toList();
    }
    if (_filterTo != null) {
      final to = DateTime(
        _filterTo!.year,
        _filterTo!.month,
        _filterTo!.day,
        23,
        59,
        59,
      );
      result = result
          .where((e) => e.date.isBefore(to) || e.date.isAtSameMomentAs(to))
          .toList();
    }
    if (_searchText != null && _searchText!.isNotEmpty) {
      final normalizedSearch = _searchText!.normalizeArabic();
      result = result
          .where((e) => e.note.normalizeArabic().contains(normalizedSearch))
          .toList();
    }

    return result;
  }

  void _emitCurrentBalance() {
    if (state is SafeLoaded) {}
  }
}
