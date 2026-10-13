import 'package:Inventra/core/models/product_model.dart';

abstract class InventoryRepository {
  List<ProductModel> getAllProducts();
  void insertProduct(ProductModel product);

  void deleteProduct(int id);

  List<ProductModel> searchProduct(String query);
  bool isBarcodeTaken(String barcode, {int? excludeProductId});
}
