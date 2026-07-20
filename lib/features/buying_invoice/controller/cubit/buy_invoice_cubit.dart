
import 'package:Inventra/core/helper/arabic_normalizer.dart';
import 'package:Inventra/core/models/invoice_item_model.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/core/models/supplier_model.dart';
import 'package:Inventra/features/buying_invoice/controller/cubit/buy_invoice_cubit_interface.dart';
import 'package:Inventra/features/buying_invoice/controller/cubit/buy_invoice_state.dart';
import 'package:Inventra/features/buying_invoice/data/repositories/buy_invoice_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BuyInvoiceCubit extends Cubit<BuyInvoiceState> implements BuyInvoiceCubitInterface {
  final BuyInvoiceRepository _repository;

  final List<InvoiceItemModel> _items = [];
  SupplierModel? _selectedSupplier;
  List<SupplierModel> _suppliers = [];
  List<ProductModel> _products = [];

  BuyInvoiceCubit(this._repository) : super(BuyInvoiceInitial());

  // Getters for UI
  @override
  List<InvoiceItemModel> get items => List.unmodifiable(_items);

  @override
  SupplierModel? get selectedSupplier => _selectedSupplier;

  @override
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.lineTotal);

  @override
  double get total => subtotal;

  @override
  List<SupplierModel> get suppliers => List.unmodifiable(_suppliers);

  @override
  List<ProductModel> get products => List.unmodifiable(_products);

  // Actions
  @override
  Future<void> loadSuppliers() async {
    try {
      _suppliers = _repository.getAllSuppliers();
      emit(BuyInvoiceSuppliersLoaded());
    } catch (e) {
      emit(BuyInvoiceError('Failed to load suppliers: $e'));
    }
  }

  @override
  Future<void> loadProducts(String search) async {
    try {
      final searchText = search.trim().normalizeArabic();
      emit(BuyInvoiceProductLoading());
      _products = _repository.searchProducts(searchText);
      emit(BuyInvoiceProductsLoaded());
    } catch (e) {
      emit(BuyInvoiceError('Failed to load products: $e'));
    }
  }

  @override
  void selectSupplier(SupplierModel supplier) {
    _selectedSupplier = supplier;
  }

  @override
  void clearSupplier() {
    _selectedSupplier = null;
  }

  @override
  void addProductItem(ProductModel product, int quantity) {
    final existingIndex = _items.indexWhere(
      (i) => i.product.target!.id == product.id,
    );
    if (existingIndex >= 0) {
      final newQty = (_items[existingIndex].quantity + quantity).clamp(
        1,
        product.quantity,
      );

      final newItem = _items[existingIndex].copyWith(
        quantity: newQty,
        lineTotal: newQty * _items[existingIndex].unitPrice,
      )..product.target = product;
      _items[existingIndex] = newItem;
      _repository.addItem(newItem);
    } else {
      final qty = quantity.clamp(1, product.quantity);

      final newItem = InvoiceItemModel(
        quantity: qty,
        unitPrice: product.buyingPrice,
        lineTotal: qty * product.buyingPrice,
      )..product.target = product;
      _items.add(newItem);
      _repository.addItem(newItem);
    }

    emit(BuyInvoiceAddProduct());
  }

  @override
  void updateItemQuantity(int itemIndex, int newQuantity) {
    if (newQuantity < 1) {
      _items.removeAt(itemIndex);
    } else {
      final product = _items[itemIndex].product.target;
      if (product != null) {
        newQuantity = newQuantity.clamp(1, product.quantity);
      }
      _items[itemIndex] = _items[itemIndex].copyWith(
        quantity: newQuantity,
        lineTotal: newQuantity * _items[itemIndex].unitPrice,
      );
    }
    emit(BuyInvoiceUpdateProductQuantity());
  }

  @override
  void removeItem(int index) {
    _items.removeAt(index);
    emit(BuyInvoiceRemoveProduct());
  }

  @override
  bool validateBuyInvoice() {
    if (_selectedSupplier == null) {
      emit(BuyInvoiceError('يرجى اختيار مورد'));
      return false;
    }
    if (_items.isEmpty) {
      emit(BuyInvoiceError('يرجى إضافة منتج واحد على الأقل بكمية أكبر من صفر'));
      return false;
    }
    return true;
  }

  @override
  Future<void> confirmInvoice() async {
    for (final item in _items) {
      final product = item.product.target;
      if (product == null) {
        emit(
          BuyInvoiceError(
            'منتج غير صالح: ${item.product.target?.name ?? 'غير معروف'}',
          ),
        );
        return;
      }
    }

    emit(BuyInvoiceLoading());
    try {
      _repository.createBuyInvoice(
        items: _items,
        supplier: _selectedSupplier!,
      );

      _items.clear();
      _selectedSupplier = null;
      emit(BuyInvoiceConfirmed());
    } catch (e) {
      emit(BuyInvoiceError('Failed to save invoice: $e'));
    }
  }
}