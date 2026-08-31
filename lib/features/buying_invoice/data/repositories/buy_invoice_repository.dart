import 'package:Inventra/core/models/invoice_item_model.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/core/models/supplier_model.dart';

abstract class BuyInvoiceRepository {
  // Supplier queries
  List<SupplierModel> getAllSuppliers();

  // Product queries
  List<ProductModel> searchProducts(String query);
  void insertProduct(ProductModel product);
  // Invoice operations
  void createBuyInvoice({
    required List<InvoiceItemModel> items,
    required SupplierModel supplier,
  });

}
