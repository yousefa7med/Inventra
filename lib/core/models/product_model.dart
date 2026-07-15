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

  // Backlink for sell invoice items
  // @Backlink('productRef')
  // final ToMany<SellInvoiceItemModel> invoiceItems = ToMany<SellInvoiceItemModel>();

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
