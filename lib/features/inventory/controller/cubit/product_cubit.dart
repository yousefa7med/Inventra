import 'package:Inventra/core/helper/arabic_normalizer.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/features/inventory/controller/cubit/product_cubit_interface.dart';
import 'package:Inventra/features/inventory/data/repositories/product_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState>
    implements ProductCubitInterface {
  final ProductRepository _repository;

  ProductCubit(this._repository) : super(const ProductInitial());
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  String searchQuery = '';
  @override
  List<ProductModel> get products => _allProducts;

  @override
  List<ProductModel> get filteredProducts => _filteredProducts;

  @override
  void loadProducts() {
    emit(const ProductLoading());
    try {
      _allProducts = _repository.getAllProducts();
      _filteredProducts = List.from(_allProducts);
      emit(const ProductsLoadingSuccessed());
    } catch (e) {
      emit(ProductErrorState('فشل تحميل المنتجات: $e'));
    }
  }

  @override
  void searchProducts(String query) {
    if (query.isEmpty) {
      loadProducts();
    } else {
      emit(const ProductLoading());
      final cleanedQuery = query.trim().toLowerCase();
      final normalizedQuery = cleanedQuery.normalizeArabic();

      _filteredProducts = _allProducts.where((product) {
        final nameMatch = product.name.toLowerCase().normalizeArabic().contains(
          normalizedQuery,
        );

        final barcodeMatch =
            product.barcode != null &&
            product.barcode!.toLowerCase().contains(cleanedQuery);

        return nameMatch || barcodeMatch;
      }).toList();
      emit(const ProductsLoadingSuccessed());
    }
  }

  @override
  void addProduct(ProductModel product) async {
    try {
      _repository.insertProduct(product);
      _allProducts.add(product);
      _filteredProducts = List.from(_allProducts);
      // ignore: prefer_const_constructors
      emit(ProductsLoadingSuccessed());
    } catch (e) {
      emit(ProductErrorState('فشل إضافة المنتج: $e'));
    }
  }

  @override
  void updateProduct(ProductModel product) async {
    try {
      _repository.insertProduct(product);

      final index = _allProducts.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _allProducts[index] = product;
      } else {
        _allProducts.add(product);
      }

      final filteredIndex = _filteredProducts.indexWhere(
        (p) => p.id == product.id,
      );
      if (filteredIndex != -1) {
        _filteredProducts[filteredIndex] = product;
      } else {
        _filteredProducts.add(product);
      }

      // ignore: prefer_const_constructors
      emit(ProductsLoadingSuccessed());
    } catch (e) {
      emit(ProductErrorState('فشل تعديل المنتج: $e'));
    }
  }

  @override
  void deleteProduct(ProductModel product) async {
    try {
      _repository.deleteProduct(product.id);
      _allProducts.removeWhere((p) => p.id == product.id);
      _filteredProducts.removeWhere((p) => p.id == product.id);
      // ignore: prefer_const_constructors
      emit(ProductsLoadingSuccessed());
    } catch (e) {
      emit(ProductErrorState('فشل حذف المنتج: $e'));
    }
  }

  @override
  bool isBarcodeUnique(String barcode, {int? excludeId}) {
    return _repository.isBarcodeUnique(barcode, excludeId: excludeId);
  }
}
