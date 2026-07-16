import 'package:Inventra/core/helper/arabic_normalizer.dart';
import 'package:Inventra/core/helper/cache_helper.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/features/inventory/data/repositories/product_repository.dart';
import 'package:Inventra/objectbox.g.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ObjectBoxServices _objectBoxServices;

  ProductRepositoryImpl(this._objectBoxServices);

  @override
  List<ProductModel> getAllProducts() {
    return _objectBoxServices.productsBox.getAll();
  }

  @override
  void addProduct(ProductModel product) {
    _objectBoxServices.productsBox.put(product);
  }

  @override
  void updateProduct(ProductModel product) {
    _objectBoxServices.productsBox.put(product);
  }

  @override
  void deleteProduct(int id) {
    _objectBoxServices.productsBox.remove(id);
  }

  @override
  List<ProductModel> searchProducts(String query) {
    if (query.isEmpty) return getAllProducts();

    final searchText = query.toLowerCase().normalizeArabic();

    final queryBuilder = _objectBoxServices.productsBox
        .query(
          ProductModel_.name.contains(searchText, caseSensitive: false),
        )
        .build();
    final result = queryBuilder.find();
    queryBuilder.close();
    return result;
  }

  @override
  bool isBarcodeUnique(String barcode, {int? excludeId}) {
    final products = getAllProducts();
    return !products.any(
      (p) => p.barcode == barcode && (excludeId == null || p.id != excludeId),
    );
  }
}