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
    _objectBoxServices.productsBox.put(product);
  }

  @override
  void deleteProduct(int id) {
    _objectBoxServices.productsBox.remove(id);
  }


  @override
  List<ProductModel> searchProduct(String searchQuery) {
    final text = searchQuery.trim().normalizeArabic();

    if (text.isEmpty) {
      return _objectBoxServices.productsBox.getAll();
    }

    final condition = ProductModel_.barcode
        .contains(text)
        .or(ProductModel_.name.contains(text, caseSensitive: false));

    final query = _objectBoxServices.productsBox
        .query(condition)
        .order(ProductModel_.name)
        .build();

    final products = query.find();
    query.close();
    return products;
  }
}
