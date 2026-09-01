import 'package:Inventra/core/models/customer_model.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/core/models/invoice_item_model.dart';

abstract class SellInvoiceRepository {
  List<CustomerModel> getAllCustomers();
  List<ProductModel> getAllProducts();
  List<ProductModel> searchProducts(String query);
  void createSellInvoice({
    required List<InvoiceItemModel> items,
    required CustomerModel customer,
    required double discount,
  });
}
