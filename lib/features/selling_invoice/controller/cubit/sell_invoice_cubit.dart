import 'dart:developer';

import 'package:Inventra/core/models/customer_model.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/core/models/sell_invoice_item_model.dart';
import 'package:Inventra/features/selling_invoice/data/repositories/sell_invoice_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'sell_invoice_state.dart';
import 'sell_invoice_cubit_interface.dart';

class SellInvoiceCubit extends Cubit<SellInvoiceState>
    implements SellInvoiceCubitInterface {
  final SellInvoiceRepository _repository;

  final List<SellInvoiceItemModel> _items = [];
  CustomerModel? _selectedCustomer;
  double _discount = 0.0;
  List<CustomerModel> _customers = [];
  List<ProductModel> _products = [];

  SellInvoiceCubit(this._repository) : super(const SellInvoiceInitial());

  // Getters for UI
  @override
  List<SellInvoiceItemModel> get items => List.unmodifiable(_items);
  @override
  CustomerModel? get selectedCustomer => _selectedCustomer;
  @override
  double get discount => _discount;
  @override
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.lineTotal);
  @override
  double get totalAfterDiscount =>
      (subtotal - _discount).clamp(0.0, double.infinity);
  @override
  List<CustomerModel> get customers => List.unmodifiable(_customers);
  @override
  List<ProductModel> get products => List.unmodifiable(_products);

  // Actions
  @override
  Future<void> loadCustomers() async {
    try {
      _customers = _repository.getAllCustomers();
    } catch (e) {
      emit(SellInvoiceError('Failed to load customers: $e'));
    }
  }

  @override
  Future<void> loadProducts(String search) async {
    try {
      emit(const SellInvoiceProductLoading());
      _products = _repository.searchProducts(search);
      emit(const SellInvoiceProductSuccessed());
    } catch (e) {
      emit(SellInvoiceError('Failed to load products: $e'));
    }
  }

  @override
  void selectCustomer(CustomerModel customer) {
    _selectedCustomer = customer;
  }

  @override
  void clearCustomer() {
    _selectedCustomer = null;
  }

  @override
  void setDiscount(double value) {
    _discount = value.clamp(0.0, subtotal);
    // ignore: prefer_const_constructors
    emit(SellInvoiceDiscountChanged());
  }

  @override
  void addProductItemLine(ProductModel product, int quantity) {
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

      final newItem = SellInvoiceItemModel(
        // sellInvoiceId: 0,
        quantity: qty,
        unitPrice: product.saleingPrice,
        lineTotal: qty * product.saleingPrice,
      )..product.target = product;
      _items.add(newItem);
      _repository.addItem(newItem);
    }

    emit(const SellInvoiceAddProduct());
  }

  @override
  void updateItemQuantity(int itemIndex, int newQuantity) {
    log("message");
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
    log("message");

    // ignore: prefer_const_constructors
    emit(SellInvoiceUpdateProductQuantity());
  }

  @override
  void removeItem(int index) {
    _items.removeAt(index);
    emit(const SellInvoiceRemoveProduct());
  }

  @override
  bool validateSellInvoice() {
    if (_selectedCustomer == null) {
      // ignore: prefer_const_constructors
      emit(SellInvoiceError('يرجى اختيار عميل'));
      return false;
    }
    if (_items.isEmpty) {
      // ignore: prefer_const_constructors
      emit(SellInvoiceError('يرجى إضافة منتج واحد على الأقل'));
      return false;
    }
    return true;
  }

  @override
  Future<void> confirmInvoice() async {
    for (final item in _items) {
      final product = item.product.target;
      if (product == null || product.quantity < item.quantity) {
        emit(
          SellInvoiceError(
            'الكمية غير متوفرة للمنتج: ${product?.name ?? 'غير معروف'}',
          ),
        );
        return;
      }
    }

    emit(const SellInvoiceLoading());
    try {
      _repository.createSellInvoice(
        items: _items,
        customer: _selectedCustomer!,
        discount: _discount,
      );

      _items.clear();
      _selectedCustomer = null;
      _discount = 0.0;
      emit(const SellInvoiceConfirmed());
    } catch (e) {
      emit(SellInvoiceError('Failed to save invoice: $e'));
    }
  }
}
