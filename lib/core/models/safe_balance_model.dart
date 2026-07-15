import 'package:objectbox/objectbox.dart';

@Entity()
class SafeBalanceModel {
  @Id()
  int id = 0;

  double currentBalance;

  DateTime lastUpdated;

  SafeBalanceModel({required this.currentBalance, required this.lastUpdated});
}
