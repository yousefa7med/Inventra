import 'package:objectbox/objectbox.dart';

@Entity()
class SafeBalanceModel {
  @Id()
  int id = 0;

  final double currentBalance;

  final DateTime lastUpdated;
  final String? note;
  SafeBalanceModel({
    required this.currentBalance,
    required this.lastUpdated,
    this.note,
  });

  SafeBalanceModel copyWith({
    double? currentBalance,
    DateTime? lastUpdated,
    String? note,
  }) => SafeBalanceModel(
    currentBalance: currentBalance ?? this.currentBalance,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    note: note ?? this.note,
  )..id = id;
}
