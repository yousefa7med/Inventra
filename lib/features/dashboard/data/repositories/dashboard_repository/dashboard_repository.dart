import 'package:Inventra/core/models/safe_balance_model.dart';

abstract class DashboardRepository {
  SafeBalanceModel getBalance();
}
