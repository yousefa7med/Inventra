import 'package:Inventra/core/helper/cache_helper.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit() : super(ProductInitial());
  static ProductCubit get(BuildContext context) => BlocProvider.of(context);
  List<ProductModel> allProducts = [];
  List<ProductModel> filteredProducts = [];
  void loadProducts() {
    allProducts = GetIt.instance<ObjectBoxServices>().productsBox.getAll();
    filteredProducts = List.from(allProducts);
    emit(ProductsListChanges());
  }
   void filterProducts(String query) {
    if (query.isEmpty) {
      filteredProducts = List.from(allProducts);
    } else {
      filteredProducts = allProducts.where((product) {
        final nameMatch = product.name.toLowerCase().contains(
          query.toLowerCase(),
        );
        if (product.barcode != null) {
          final barcodeMatch = product.barcode!.toLowerCase().contains(
            query.toLowerCase(),
          );
          return nameMatch || barcodeMatch;
        }
        return nameMatch;
      }).toList();
    }
    emit(ProductsListChanges());
  }


  
}
