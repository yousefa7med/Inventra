import 'package:Inventra/core/exceptions/product_barcode_taken_exception.dart';
import 'package:Inventra/core/helper/arabic_normalizer.dart';
import 'package:Inventra/core/helper/cache_helper.dart';
import 'package:Inventra/core/models/transactions_entry.dart';
import 'package:Inventra/core/models/transaction_type.dart';
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
  void insertProduct(ProductModel product) {
       final barcode = product.barcode?.trim();
    if (barcode != null && barcode.isNotEmpty) {
      if (isBarcodeTaken(
        barcode,
        excludeProductId: product.id == 0 ? null : product.id,
      )) {
        throw const ProductBarcodeTakenException();
      }
    }
    _objectBox.productsBox.put(product);
  }

  @override
  List<ProductModel> searchProducts(String searchQuery) {
    final searchText = searchQuery.trim().normalizeArabic();
    if (searchText.isEmpty) {
      final query = _objectBox.productsBox.query().build();
      final products = query.find();
      query.close();
      return products;
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
  void createBuyInvoice({
    required List<InvoiceItemModel> items,
    required SupplierModel supplier,
  }) {
    BuyingInvoiceModel? savedInvoice;
    double totalPrice = 0.0;
    _objectBox.store.runInTransaction(TxMode.write, () {
      final invoice = BuyingInvoiceModel(date: DateTime.now());
      invoice.supplier.target = supplier;

      for (final item in items) {
        final product = item.product.target!;
        product.quantity += item.quantity;
        _objectBox.productsBox.put(product);

        totalPrice += item.lineTotal;
      }
      final balance =
          _objectBox.safeBalanceBox.get(1) ??
          SafeBalanceModel(currentBalance: 0, lastUpdated: DateTime.now());
      if (totalPrice > balance.currentBalance) {
        throw "رصيد الخزنة لا يكفي";
      }

      invoice.items.addAll(items);
      _objectBox.buyInvoicesBox.put(invoice);
      savedInvoice = invoice;

      final newBalance = balance.copyWith(
        currentBalance: balance.currentBalance - totalPrice,
      );
      _objectBox.safeBalanceBox.put(newBalance);

      final auditEntry = TransactionsEntry(
        typeIndex: TransactionType.buyingInvoice.index,
        value: -totalPrice,
        referenceId: savedInvoice!.id,
        createdAt: savedInvoice!.date,
        description: supplier.name,
      );
      _objectBox.transactionsEntryBox.put(auditEntry);
    });
  }
   bool isBarcodeTaken(String barcode, {int? excludeProductId}) {
    final query = _objectBox.productsBox
        .query(ProductModel_.barcode.equals(barcode))
        .build();

    try {
      final product = query.findFirst();

      if (product == null) {
        return false;
      }

      return excludeProductId == null || product.id != excludeProductId;
    } finally {
      query.close();
    }
  }
}
