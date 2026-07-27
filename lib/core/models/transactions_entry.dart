import 'package:objectbox/objectbox.dart';

@Entity()
class TransactionsEntry {
  @Id()
  int id = 0;

  @Index()
  final int type;

  final double amount;

  final int referenceId;

  @Index()
  final DateTime timestamp;

  final String? userName;

  TransactionsEntry({
    required this.type,
    required this.amount,
    required this.referenceId,
    required this.timestamp,
    this.userName,
  });
}
