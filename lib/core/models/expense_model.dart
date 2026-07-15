import 'package:objectbox/objectbox.dart';

@Entity()
class ExpenseModel {
  @Id()
   int id = 0;

  @Index()
 final  DateTime date;

 final  double value;

  final String note;

  ExpenseModel({required this.date, required this.value, required this.note});
}
