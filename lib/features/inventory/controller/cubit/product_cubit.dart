import 'dart:io';

import 'package:Inventra/core/helper/arabic_normalizer.dart';
import 'package:Inventra/core/helper/cache_helper.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit() : super(const ProductInitial());

  static ProductCubit get(BuildContext context) => BlocProvider.of(context);

  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];

  List<ProductModel> get allProducts => _allProducts;
  List<ProductModel> get filteredProducts => _filteredProducts;

  Future<void> loadProducts() async {
    emit(const ProductLoading());
    try {
      _allProducts = GetIt.instance<ObjectBoxServices>().productsBox.getAll();
      _filteredProducts = List.from(_allProducts);
      emit(
        ProductsLoaded(
          products: _allProducts,
          filteredProducts: _filteredProducts,
        ),
      );
    } catch (e) {
      emit(ProductError('فشل تحميل المنتجات: $e'));
    }
  }

  void filterProducts(String query) {
    if (query.isEmpty) {
      _filteredProducts = List.from(_allProducts);
    } else {
      final normalizedQuery = query.normalizeArabic();
      _filteredProducts = _allProducts.where((product) {
        final nameMatch = product.name.normalizeArabic().contains(
          normalizedQuery,
        );
        if (product.barcode != null) {
          final barcodeMatch = product.barcode!.normalizeArabic().contains(
            normalizedQuery,
          );
          return nameMatch || barcodeMatch;
        }
        return nameMatch;
      }).toList();
    }
    emit(
      ProductsLoaded(
        products: _allProducts,
        filteredProducts: _filteredProducts,
      ),
    );
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      GetIt.instance<ObjectBoxServices>().productsBox.put(product);
      _allProducts.add(product);
      _filteredProducts = List.from(_allProducts);
      emit(
        ProductsLoaded(
          products: _allProducts,
          filteredProducts: _filteredProducts,
        ),
      );
    } catch (e) {
      emit(ProductError('فشل إضافة المنتج: $e'));
      rethrow;
    }
  }

void updateProduct(ProductModel product)  {
    try {
      GetIt.instance<ObjectBoxServices>().productsBox.put(product);
      final index = _allProducts.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _allProducts[index] = product;
      }
      _filteredProducts = List.from(_allProducts);
      emit(
        ProductsLoaded(
          products: _allProducts,
          filteredProducts: _filteredProducts,
        ),
      );
    } catch (e) {
      emit(ProductError('فشل تعديل المنتج: $e'));
      rethrow;
    }
  }

  Future<void> deleteProduct(ProductModel product) async {
    try {
      if (product.imgPath != null && product.imgPath!.isNotEmpty) {
        final file = File(product.imgPath!);
        if (file.existsSync()) {
          file.deleteSync();
        }
      }
      GetIt.instance<ObjectBoxServices>().productsBox.remove(product.id);
      _allProducts.removeWhere((p) => p.id == product.id);
      _filteredProducts.removeWhere((p) => p.id == product.id);
      emit(
        ProductsLoaded(
          products: _allProducts,
          filteredProducts: _filteredProducts,
        ),
      );
    } catch (e) {
      emit(ProductError('فشل حذف المنتج: $e'));
      rethrow;
    }
  }

  bool isBarcodeUnique(String barcode, {int? excludeId}) {
    return !_allProducts.any(
      (p) => p.barcode == barcode && (excludeId == null || p.id != excludeId),
    );
  }


}
