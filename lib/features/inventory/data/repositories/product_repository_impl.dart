import 'package:Inventra/core/exceptions/product_barcode_taken_exception.dart';
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
  void insertProduct(ProductModel product) {
    final barcode = product.barcode?.trim();
    if (barcode != null && barcode.isNotEmpty) {
      if (isBarcodeTaken(
        barcode,
        excludeProductId: product.id == 0 ? null : product.id,
      )) {
        throw const ProductBarcodeTakenException();
      }
    }
    _objectBoxServices.productsBox.put(product);
  }

  @override
  void deleteProduct(int id) {
    _objectBoxServices.productsBox.remove(id);
  }

  @override
  List<ProductModel> searchProduct(String searchQuery) {
    final searchText = searchQuery.trim().normalizeArabic();
    if (searchText.isEmpty) {
      return getAllProducts();
    }

    if (RegExp(r'^\d+$').hasMatch(searchText)) {
      final query = _objectBoxServices.productsBox
          .query(ProductModel_.barcode.contains(searchText))
          .build();
      final products = query.find();
      query.close();

      return products;
    }
    final query = _objectBoxServices.productsBox
        .query(ProductModel_.name.contains(searchText, caseSensitive: false))
        .order(ProductModel_.name)
        .build();
    final products = query.find();
    query.close();
    return products;
  }

  @override
  bool isBarcodeTaken(String barcode, {int? excludeProductId}) {
    final query = _objectBoxServices.productsBox
        .query(ProductModel_.barcode.equals(barcode))
        .build();

    try {
      final product = query.findFirst();

      if (product == null) {
        return false;
      }

      return excludeProductId == null || product.id != excludeProductId;
    } finally {
      query.close();
    }
  }
}
