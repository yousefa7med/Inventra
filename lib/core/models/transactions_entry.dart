import 'package:objectbox/objectbox.dart';

@Entity()
class TransactionsEntry {
  @Id()
  int id = 0;

  @Index()
  final int type;

  final double value;
  final double? oldValue;

  final int referenceId;

  @Index()
  final DateTime timestamp;

  final String? description;

  TransactionsEntry({
    required this.type,
    required this.value,
    required this.referenceId,
    required this.timestamp,
    this.description,
    this.oldValue,
  });
}
