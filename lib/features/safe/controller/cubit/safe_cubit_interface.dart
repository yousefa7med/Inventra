abstract class SafeCubitInterface {
  String? get searchText;
  double get currentBalance ;

  void addExpense({required double value, required String note});
  void searchForExpenses(String searchText);
  void clearSearchFilter();

  void adjustBalance({required double newBalance, String? note});
}
