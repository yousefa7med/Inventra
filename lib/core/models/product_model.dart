import 'package:objectbox/objectbox.dart';

@Entity()
class ProductModel {
  @Id()
  int id = 0;
  final String name;
  final String? imgPath;
  final int quantity;
  final double buyingPrice;
  final double saleingPrice;
  final double wholesalePrice;
  final String? barcode;

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
