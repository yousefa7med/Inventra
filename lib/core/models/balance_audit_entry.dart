import 'package:objectbox/objectbox.dart';

@Entity()
class BalanceAuditEntry {
  @Id()
  int id = 0;

  @Index()
  int type;

  double amount;

  int referenceId;

  @Index()
  DateTime timestamp;

  String? note;

  BalanceAuditEntry({
    required this.type,
    required this.amount,
    required this.referenceId,
    required this.timestamp,
    this.note,
  });
}