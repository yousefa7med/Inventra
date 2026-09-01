import 'package:Inventra/core/models/product_model.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class InvoiceItemModel {
  @Id()
  int id = 0;

  final ToOne<ProductModel> product = ToOne<ProductModel>();

  final int quantity;
  final double unitPrice;
  final double? unitCost;
  final double lineTotal;
  final String name;

  InvoiceItemModel({
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.unitCost,
    required this.name,
  });

  InvoiceItemModel copyWith({
    int? quantity,
    double? unitPrice,
    double? unitCost,
    double? lineTotal,
    ProductModel? product,
    String? name,
  }) {
    return InvoiceItemModel(
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        lineTotal: lineTotal ?? this.lineTotal,
        unitCost: unitCost ?? this.unitCost,
        name: name ?? this.name,
      )
      ..id = id
      ..product.target = product ?? this.product.target;
  }
}
