import 'package:Inventra/core/models/buying_invoice_model.dart';
import 'package:Inventra/core/models/invoice_item_model.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/core/models/supplier_model.dart';

abstract class BuyInvoiceRepository {
  // Supplier queries
  List<SupplierModel> getAllSuppliers();
  SupplierModel? getSupplierById(int id);

  // Product queries
  List<ProductModel> getAllProducts();
  List<ProductModel> searchProducts(String query);

  // Invoice operations
  BuyingInvoiceModel createBuyInvoice({
    required List<InvoiceItemModel> items,
    required SupplierModel supplier,
  });

  Stream<List<BuyingInvoiceModel>> watchInvoices();
  List<BuyingInvoiceModel> getAllBuyInvoices();
  BuyingInvoiceModel? getBuyInvoiceById(int id);

  // Item helpers
  void addItem(InvoiceItemModel item);
}