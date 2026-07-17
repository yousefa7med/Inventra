import 'package:Inventra/core/helper/cache_helper.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/features/inventory/data/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ObjectBoxServices _objectBoxServices;

  ProductRepositoryImpl(this._objectBoxServices);

  @override
  List<ProductModel> getAllProducts() {
    return _objectBoxServices.productsBox.getAll();
  }

  @override
  void insertProduct(ProductModel product) {
    _objectBoxServices.productsBox.put(product);
  }

  @override
  void deleteProduct(int id) {
    _objectBoxServices.productsBox.remove(id);
  }

  @override
  bool isBarcodeUnique(String barcode, {int? excludeId}) {
    final products = getAllProducts();
    return !products.any(
      (p) => p.barcode == barcode && (excludeId == null || p.id != excludeId),
    );
  }
}
