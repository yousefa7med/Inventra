import 'package:Inventra/core/models/product_model.dart';

abstract class ProductCubitInterface {
  List<ProductModel> get products;
  List<ProductModel> get filteredProducts;

  void loadProducts();
  void searchProducts(String query);
  void addProduct(ProductModel product);
  void updateProduct(ProductModel product);
  void deleteProduct(ProductModel product);
  bool isBarcodeUnique(String barcode, {int? excludeId});
}
