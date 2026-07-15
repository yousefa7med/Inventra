import 'dart:developer';

import 'package:Inventra/core/helper/arabic_normalizer.dart';
import 'package:Inventra/core/helper/cache_helper.dart';
import 'package:Inventra/core/models/balance_audit_entry_model.dart';
import 'package:Inventra/core/models/balance_change_type.dart';
import 'package:Inventra/core/models/customer_model.dart';
import 'package:Inventra/core/models/selling_invoice_model.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/core/models/sell_invoice_item_model.dart';
import 'package:Inventra/features/selling_invoice/data/repositories/sell_invoice_repository.dart';
import 'package:Inventra/objectbox.g.dart';

class SellInvoiceRepositoryImpl implements SellInvoiceRepository {
  final ObjectBoxServices _objectBox;

  SellInvoiceRepositoryImpl(this._objectBox);

  @override
  List<CustomerModel> getAllCustomers() {
    final query = _objectBox.customersBox
        .query()
        .order(CustomerModel_.name)
        .build();

    final customers = query.find();
    query.close();
    return customers;
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
  List<ProductModel> searchProducts(String search) {
    final searchText = search.trim().normalizeArabic();
    log(searchText);
    late final List<ProductModel> products;
    if (searchText.isEmpty) {
      print(searchText.isEmpty);
      return getAllProducts();
    }

    if (RegExp(r'^\d+$').hasMatch(searchText)) {
      print("RegExphasMatch(searchText)");
      final query = _objectBox.productsBox
          .query(ProductModel_.barcode.contains(searchText))
          .build();
      products = query.find();
      query.close();

      return products;
    }
    print("object");
    final query = _objectBox.productsBox
        .query(ProductModel_.name.contains(searchText, caseSensitive: false))
        .order(ProductModel_.name)
        .build();
    products = query.find();
    query.close();
    return products;
  }

  @override
  SellingInvoiceModel createSellInvoice({
    required List<SellInvoiceItemModel> items,
    required CustomerModel customer,
    double? discount,
  }) {
    SellingInvoiceModel? savedInvoice;
    double totalPrice = 0.0;

    _objectBox.store.runInTransaction(TxMode.write, () {
      final invoice = SellingInvoiceModel(
        date: DateTime.now(),
        discount: discount,
      );
      customer.invoices.add(invoice);
      _objectBox.invoicesBox.put(invoice);
      _objectBox.customersBox.put(customer);

      for (final item in items) {
        invoice.items.add(item);

        final product = item.product.target!;
        product.quantity -= item.quantity;
        _objectBox.productsBox.put(product);

        totalPrice += item.lineTotal;
      }
      _objectBox.invoicesBox.put(invoice);

      invoice.items.addAll(items);
      savedInvoice = invoice;
    });

    final balance = _objectBox.safeBalanceBox.get(1);
    balance?.currentBalance += (totalPrice - (discount ?? 0));
    _objectBox.safeBalanceBox.put(balance!);
    // Record BalanceAuditEntry for sell invoice
    final auditEntry = BalanceAuditEntryModel(
      type: BalanceChangeType.sellInvoice.index,
      amount: (totalPrice - (discount ?? 0)).clamp(0.0, double.infinity),
      referenceId: savedInvoice!.id,
      timestamp: savedInvoice!.date,
      note: 'فاتورة بيع: ${customer.name}',
    );
    _objectBox.balanceAuditEntryBox.put(auditEntry);

    return savedInvoice!;
  }

  @override
  Stream<List<SellingInvoiceModel>> watchInvoices() {
    return _objectBox.invoicesBox
        .query()
        .order(SellingInvoiceModel_.date, flags: Order.descending)
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  @override
  void addItem(SellInvoiceItemModel item) {
    _objectBox.sellInvoiceItemsBox.put(item);
  }
}
