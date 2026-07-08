import 'package:objectbox/objectbox.dart';

@Entity()
class SafeBalance {
  @Id()
  int id = 0;

  double currentAmount;

  DateTime lastUpdated;

  SafeBalance({required this.currentAmount, required this.lastUpdated,});
}