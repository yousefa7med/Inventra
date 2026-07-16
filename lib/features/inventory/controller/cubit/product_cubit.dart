import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/features/inventory/controller/cubit/product_cubit_interface.dart';
import 'package:Inventra/features/inventory/data/repositories/product_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> implements ProductCubitInterface {
  final ProductRepository _repository;

  ProductCubit(this._repository) : super(const ProductInitial());

  @override
  List<ProductModel> get products => _allProducts;

  @override
  List<ProductModel> get filteredProducts => _filteredProducts;

  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];

  @override
  Future<void> loadProducts() async {
    emit(const ProductLoading());
    try {
      _allProducts = _repository.getAllProducts();
      _filteredProducts = List.from(_allProducts);
      emit(const ProductsLoaded());
    } catch (e) {
      emit(ProductError('فشل تحميل المنتجات: $e'));
    }
  }

  @override
  void searchProducts(String query) {
    try {
      _filteredProducts = _repository.searchProducts(query);
      emit(const ProductsLoaded());
    } catch (e) {
      emit(ProductError('فشل البحث: $e'));
    }
  }

  @override
  Future<void> addProduct(ProductModel product) async {
    try {
      _repository.addProduct(product);
      _allProducts.add(product);
      _filteredProducts = List.from(_allProducts);
      emit(const ProductsLoaded());
    } catch (e) {
      emit(ProductError('فشل إضافة المنتج: $e'));
      rethrow;
    }
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    try {
      _repository.updateProduct(product);

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

      emit(const ProductsLoaded());
    } catch (e) {
      emit(ProductError('فشل تعديل المنتج: $e'));
      rethrow;
    }
  }

  @override
  Future<void> deleteProduct(ProductModel product) async {
    try {
      _repository.deleteProduct(product.id);
      _allProducts.removeWhere((p) => p.id == product.id);
      _filteredProducts.removeWhere((p) => p.id == product.id);
      emit(const ProductsLoaded());
    } catch (e) {
      emit(ProductError('فشل حذف المنتج: $e'));
      rethrow;
    }
  }

  @override
  bool isBarcodeUnique(String barcode, {int? excludeId}) {
    return _repository.isBarcodeUnique(barcode, excludeId: excludeId);
  }
}