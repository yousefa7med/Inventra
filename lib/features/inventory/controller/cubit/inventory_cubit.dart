import 'package:Inventra/core/exceptions/product_barcode_taken_exception.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/features/inventory/controller/cubit/inventory_cubit_interface.dart';
import 'package:Inventra/features/inventory/data/repositories/inventory_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'inventory_state.dart';

class InventoryCubit extends Cubit<InventoryState>
    implements InventoryCubitInterface {
  final InventoryRepository _repository;

  InventoryCubit(this._repository) : super(const InventoryInitial());
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  String searchQuery = '';

  @override
  void loadProducts() {
    emit(const InventoryLoading());
    try {
      _allProducts = _repository.getAllProducts();
      _filteredProducts = List.from(_allProducts);
      emit(InventoryLoadingSuccessed(products: _filteredProducts));
    } catch (e) {
      emit(InventoryErrorState('فشل تحميل المنتجات: $e'));
    }
  }

  @override
  void searchProducts(String query) {
    try {
      if (query.isEmpty) {
        _filteredProducts = List.from(_allProducts);
        emit(InventoryLoadingSuccessed(products: _filteredProducts));
        return;
      }
      emit(const InventoryLoading());
      _filteredProducts = _repository.searchProduct(query);

      emit(InventoryLoadingSuccessed(products: _filteredProducts));
    } catch (e) {
      emit(InventoryErrorState('فشل البحث عن المنتج: $e'));
    }
  }

  @override
  bool insertProduct(ProductModel product) {
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

      emit(ProductInsertedSuccessed(products: _filteredProducts));
      return true;
    } on ProductBarcodeTakenException catch (e) {
      emit(ProductInsertError(e.msg));

      return false;
    } catch (e) {
      emit(ProductInsertError('فشل تعديل المنتج: $e'));
      return false;
    }
  }

  @override
  void deleteProduct(ProductModel product) async {
    try {
      _repository.deleteProduct(product.id);
      _allProducts.removeWhere((p) => p.id == product.id);
      _filteredProducts.removeWhere((p) => p.id == product.id);
      emit(InventoryLoadingSuccessed(products: _filteredProducts));
    } catch (e) {
      emit(InventoryErrorState('فشل حذف المنتج: $e'));
    }
  }
}
