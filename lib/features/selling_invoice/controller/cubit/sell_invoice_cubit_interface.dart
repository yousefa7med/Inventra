import 'package:Inventra/core/models/customer_model.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/core/models/invoice_item_model.dart';

abstract class SellInvoiceCubitInterface {
  // State getters
  List<InvoiceItemModel> get items;
  CustomerModel? get selectedCustomer;
  double get discount;
  double get subtotal;
  double get totalAfterDiscount;
  List<CustomerModel> get customers;
  List<ProductModel> get products;
  String searchQuery = "";
  // Customer actions
  Future<void> loadCustomers();
  void selectCustomer(CustomerModel customer);
  void clearCustomer();

  // Product actions
  Future<void> loadProducts(String query);
  void addProductItemLine(ProductModel product, int quantity);
  void updateItemQuantity(int itemIndex, int newQuantity);
  void removeItem(int index);

  // Discount
  void setDiscount(double value);

  // Confirmation
  Future<void> confirmInvoice();
  bool validateSellInvoice();
}
