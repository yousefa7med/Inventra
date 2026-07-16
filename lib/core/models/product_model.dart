import 'package:objectbox/objectbox.dart';

@Entity()
class ProductModel {
  @Id()
  int id = 0;
  final String name;
  final String? imgPath;
  int quantity;
  final double buyingPrice;
  final double saleingPrice;
  final double wholesalePrice;
  final String? barcode;

  ProductModel copyWith({
    String? name,
    String? imgPath,
    int? quantity,
    double? buyingPrice,
    double? saleingPrice,
    double? wholesalePrice,
    String? barcode,
  }) {
    return ProductModel(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      buyingPrice: buyingPrice ?? this.buyingPrice,
      saleingPrice: saleingPrice ?? this.saleingPrice,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      imgPath: imgPath ?? this.imgPath,
      barcode: barcode ?? this.barcode,
    )..id = id;
  }

  ProductModel({
    required this.name,
    this.imgPath,
    required this.quantity,
    required this.buyingPrice,
    required this.saleingPrice,
    required this.wholesalePrice,
    this.barcode,
  });
}
