import 'package:objectbox/objectbox.dart';

@Entity()
class ManualAdjustmentModel {
  @Id()
  int id = 0;
  final double prevBalanceValue;
  final double newBalanceValue;
  final DateTime date;
  final String? note;

  ManualAdjustmentModel({
    required this.prevBalanceValue,
    required this.newBalanceValue,
    required this.date,
     this.note,
  });

  ManualAdjustmentModel copyWith({
    double? prevBalanceValue,
    double? newBalanceValue,
    DateTime? date,
    String? note,
  }) => ManualAdjustmentModel(
    prevBalanceValue: prevBalanceValue ?? this.prevBalanceValue,
    newBalanceValue: newBalanceValue ?? this.newBalanceValue,
    date: date ?? this.date,
    note: note ?? this.note,
  )..id = id;
}
