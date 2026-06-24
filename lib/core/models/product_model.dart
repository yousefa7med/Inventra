
import 'package:objectbox/objectbox.dart';

@Entity()
class ProductModel {
   @Id()
  int id=0;
  final String name;
  final String imgPath;
  final int quantity;
  final double buyingPrice;
  final double saleingPrice;
  final double wholesalePrice;
  final String barCode;

  ProductModel({
    required this.name,
    required this.imgPath,
    required this.quantity,
    required this.buyingPrice,
    required this.saleingPrice,
    required this.wholesalePrice,
    required this.barCode,
  });
}
