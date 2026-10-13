import 'package:Inventra/core/models/product_model.dart';

abstract class InventoryCubitInterface {

  void loadProducts();
  void searchProducts(String query);
  bool insertProduct(ProductModel product);
  void deleteProduct(ProductModel product);
}
