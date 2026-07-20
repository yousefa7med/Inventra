import 'package:Inventra/core/models/product_model.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class InvoiceItemModel {
  @Id()
  int id = 0;

  // int sellInvoiceId = 0;
  final ToOne<ProductModel> product = ToOne<ProductModel>();

  int quantity = 0;
  double unitPrice = 0.0;
  double lineTotal = 0.0;

  // Transient fields for UI display (not persisted)
  // @Transient()
  // ProductModel? product;

  // @Transient()
  // InvoiceModel? sellInvoice;

  // To-one relations (no @Backlink on ToOne side)

  InvoiceItemModel({
    // required this.sellInvoiceId,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  InvoiceItemModel copyWith({
    int? quantity,
    double? unitPrice,
    double? lineTotal,
    ProductModel? product,
  }) {
    return InvoiceItemModel(
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        lineTotal: lineTotal ?? this.lineTotal,
      )
      ..id = id
      ..product.target = product ?? this.product.target;
  }
}
