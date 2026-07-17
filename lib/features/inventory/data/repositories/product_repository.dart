import 'package:Inventra/core/models/product_model.dart';

abstract class ProductRepository {
  List<ProductModel> getAllProducts();
  void insertProduct(ProductModel product);

  void deleteProduct(int id);
  bool isBarcodeUnique(String barcode, {int? excludeId});
}