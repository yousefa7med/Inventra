import 'package:Inventra/core/models/transaction_type.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class TransactionsEntry {
  @Id()
  int id = 0;

  @Index()
  final int typeIndex;
  @Index()
  final DateTime createdAt;
  final double signedValue;

  final int referenceId;
  final double? profit;
  TransactionType get type => TransactionType.values[typeIndex];

  final String? description;

  TransactionsEntry({
    required this.typeIndex,
    required this.signedValue,
    required this.referenceId,
    required this.createdAt,
    this.description,
    this.profit,
  });
}
