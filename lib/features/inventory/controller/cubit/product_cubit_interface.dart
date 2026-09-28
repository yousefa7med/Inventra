import 'package:Inventra/core/models/product_model.dart';

abstract class ProductCubitInterface {
  List<ProductModel> get products;
  List<ProductModel> get filteredProducts;

  void loadProducts();
  void searchProducts(String query);
  bool insertProduct(ProductModel product);
  void deleteProduct(ProductModel product);
}
