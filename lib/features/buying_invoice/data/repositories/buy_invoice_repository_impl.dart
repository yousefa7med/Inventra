import 'package:Inventra/core/helper/arabic_normalizer.dart';
import 'package:Inventra/core/helper/cache_helper.dart';
import 'package:Inventra/core/models/balance_audit_entry_model.dart';
import 'package:Inventra/core/models/balance_change_type.dart';
import 'package:Inventra/core/models/buying_invoice_model.dart';
import 'package:Inventra/core/models/invoice_item_model.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/core/models/safe_balance_model.dart';
import 'package:Inventra/core/models/supplier_model.dart';
import 'package:Inventra/features/buying_invoice/data/repositories/buy_invoice_repository.dart';
import 'package:Inventra/objectbox.g.dart';

class BuyInvoiceRepositoryImpl implements BuyInvoiceRepository {
  final ObjectBoxServices _objectBox;

  BuyInvoiceRepositoryImpl(this._objectBox);

  @override
  List<SupplierModel> getAllSuppliers() {
    final query = _objectBox.suppliersBox
        .query()
        .order(SupplierModel_.name)
        .build();

    final suppliers = query.find();
    query.close();
    return suppliers;
  }

  @override
  List<ProductModel> getAllProducts() {
    final query = _objectBox.productsBox
        .query()
        .order(ProductModel_.name)
        .build();

    final products = query.find();
    query.close();
    return products;
  }

  @override
  void insertProduct(ProductModel product) {
    _objectBox.productsBox.put(product);
  }

  @override
  List<ProductModel> searchProducts(String query) {
    final searchText = query.trim().normalizeArabic();
    if (searchText.isEmpty) {
      return getAllProducts();
    }

    if (RegExp(r'^\d+$').hasMatch(searchText)) {
      final barcodeQuery = _objectBox.productsBox
          .query(ProductModel_.barcode.contains(searchText))
          .build();
      final products = barcodeQuery.find();
      barcodeQuery.close();

      return products;
    }
    final nameQuery = _objectBox.productsBox
        .query(ProductModel_.name.contains(searchText, caseSensitive: false))
        .order(ProductModel_.name)
        .build();
    final products = nameQuery.find();
    nameQuery.close();
    return products;
  }

  @override
  BuyingInvoiceModel createBuyInvoice({
    required List<InvoiceItemModel> items,
    required SupplierModel supplier,
  }) {
    BuyingInvoiceModel? savedInvoice;
    double totalPrice = 0.0;
    _objectBox.store.runInTransaction(TxMode.write, () {
      final invoice = BuyingInvoiceModel(date: DateTime.now());
      invoice.supplier.target = supplier;
      _objectBox.buyInvoicesBox.put(invoice);

      for (final item in items) {
        invoice.items.add(item);

        final product = item.product.target!;
        product.quantity += item.quantity;
        _objectBox.productsBox.put(product);

        totalPrice += item.lineTotal;
      }
      _objectBox.buyInvoicesBox.put(invoice);

      invoice.items.addAll(items);
      savedInvoice = invoice;
    });

    final balance =
        _objectBox.safeBalanceBox.get(1) ??
        SafeBalanceModel(currentBalance: 0, lastUpdated: DateTime.now());

    balance.currentBalance -= totalPrice;
    _objectBox.safeBalanceBox.put(balance);

    final auditEntry = BalanceAuditEntryModel(
      type: BalanceChangeType.buyInvoice.index,
      amount: -totalPrice,
      referenceId: savedInvoice!.id,
      timestamp: savedInvoice!.date,
      note: 'فاتورة شراء: ${supplier.name}',
    );
    _objectBox.balanceAuditEntryBox.put(auditEntry);

    return savedInvoice!;
  }

  @override
  void addItem(InvoiceItemModel item) {
    _objectBox.sellInvoiceItemsBox.put(item);
  }
}
