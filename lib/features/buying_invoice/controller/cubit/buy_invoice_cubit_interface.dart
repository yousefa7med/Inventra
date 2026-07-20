import 'package:Inventra/core/models/invoice_item_model.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/core/models/supplier_model.dart';

abstract class BuyInvoiceCubitInterface {
  // State getters
  List<InvoiceItemModel> get items;
  SupplierModel? get selectedSupplier;
  double get subtotal;
  double get total;
  List<SupplierModel> get suppliers;
  List<ProductModel> get products;

  // Supplier actions
  Future<void> loadSuppliers();
  void selectSupplier(SupplierModel supplier);
  void clearSupplier();

  // Product actions
  Future<void> loadProducts(String query);
  void addProductItem(ProductModel product, int quantity);
  void updateItemQuantity(int itemIndex, int newQuantity);
  void removeItem(int index);

  // Confirmation
  Future<void> confirmInvoice();
  bool validateBuyInvoice();
}