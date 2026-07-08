import 'package:Inventra/core/models/expense.dart';
import 'package:Inventra/core/utils/result.dart';

abstract class SafeCubitInterface {
  double get currentBalance;

  List<ExpenseModel> get filteredExpenses;

  DateTime? get filterFromDate;
  DateTime? get filterToDate;
  String? get searchText;

  Future<Result<void>> load();
  Future<Result<void>> addExpense({
    required double value,
    required String note,
  });
  void setDateFilter({DateTime? from, DateTime? to});
  void setSearchFilter(String? text);
  void clearFilters();

  Future<Result<void>> adjustBalance({
    required double newBalance,
    String? note,
  });

  // Future<Result<void>> adjustBalanceForTransaction({
  //   required double amount,
  //   required BalanceChangeType type,
  //   required int referenceId,
  //   String? note,
  // });
}
