abstract class DashboardCubitInterface {
  double get balance;
  void loadSafeBalance();
  bool addExpense({required double value, required String note});
}
