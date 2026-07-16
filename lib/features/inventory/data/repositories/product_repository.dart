import 'package:Inventra/core/models/product_model.dart';

abstract class ProductRepository {
  List<ProductModel> getAllProducts();
  void addProduct(ProductModel product);
  void updateProduct(ProductModel product);
  void deleteProduct(int id);
  List<ProductModel> searchProducts(String query);
  bool isBarcodeUnique(String barcode, {int? excludeId});
}