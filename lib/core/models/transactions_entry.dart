import 'package:Inventra/core/models/transaction_type.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class TransactionsEntry {
  @Id()
  int id = 0;

  @Index()
  final int typeIndex;

  final double value;
  final double? oldValue;

  final int referenceId;

  TransactionType get type => TransactionType.values[typeIndex];
  @Index()
  final DateTime timestamp;

  final String? description;

  TransactionsEntry({
    required this.typeIndex,
    required this.value,
    required this.referenceId,
    required this.timestamp,
    this.description,
    this.oldValue,
  });
}
