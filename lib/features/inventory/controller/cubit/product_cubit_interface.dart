import 'package:Inventra/core/models/product_model.dart';

abstract class ProductCubitInterface {
  List<ProductModel> get products;
  List<ProductModel> get filteredProducts;

  Future<void> loadProducts();
  void searchProducts(String query);
  Future<void> addProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(ProductModel product);
  bool isBarcodeUnique(String barcode, {int? excludeId});
}