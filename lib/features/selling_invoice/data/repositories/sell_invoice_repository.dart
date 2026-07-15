import 'package:Inventra/core/models/customer_model.dart';
import 'package:Inventra/core/models/selling_invoice_model.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/core/models/sell_invoice_item_model.dart';

abstract class SellInvoiceRepository {
  List<CustomerModel> getAllCustomers();
  List<ProductModel> getAllProducts();
  List<ProductModel> searchProducts(String query);
  SellingInvoiceModel createSellInvoice({
    required List<SellInvoiceItemModel> items,
    required CustomerModel customer,
    required double discount,
  });
  Stream<List<SellingInvoiceModel>> watchInvoices();
  void addItem(SellInvoiceItemModel item);
}
