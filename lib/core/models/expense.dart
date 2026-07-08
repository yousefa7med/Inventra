import 'package:objectbox/objectbox.dart';

@Entity()
class ExpenseModel {
  @Id()
  int id = 0;

  @Index()
  DateTime date;

  double value;

  String note;

  ExpenseModel({required this.date, required this.value, required this.note});
}
