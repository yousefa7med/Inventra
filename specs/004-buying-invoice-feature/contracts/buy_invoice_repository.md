# BuyInvoiceRepository Contract

**Source**: `lib/features/buying_invoice/data/repositories/buy_invoice_repository.dart`

```dart
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
    required double discount,
  });

  Stream<List<BuyingInvoiceModel>> watchInvoices();
  List<BuyingInvoiceModel> getAllBuyInvoices();
  BuyingInvoiceModel? getBuyInvoiceById(int id);

  // Item helpers
  void addItem(InvoiceItemModel item);
}
```

## Method Contracts

| Method | Preconditions | Postconditions | Errors |
|--------|---------------|----------------|--------|
| `getAllSuppliers()` | ObjectBox initialized | Returns all suppliers, sorted by name | Returns empty list on error |
| `getSupplierById(id)` | `id > 0` | Returns supplier or null if not found | — |
| `getAllProducts()` | ObjectBox initialized | Returns all products, sorted by name | Returns empty list on error |
| `searchProducts(query)` | — | Returns products matching query (name/barcode) with Arabic normalization | Returns empty list on error |
| `createBuyInvoice({items, supplier, discount})` | `items` not empty, all qty > 0, `supplier` valid | Persists BuyingInvoiceModel with items, updates product quantities, decreases safe balance, creates audit entry | Throws on DB error or validation failure |
| `watchInvoices()` | — | Reactive stream of all buying invoices (sorted by date desc) | — |
| `getAllBuyInvoices()` | — | Returns all buying invoices (sorted by date desc) | Returns empty list on error |
| `getBuyInvoiceById(id)` | `id > 0` | Returns invoice with items populated | Returns null if not found |
| `addItem(item)` | `item` valid, product set | Adds item to current invoice's items box (for building) | — |

## Implementation Notes

**`createBuyInvoice` Business Logic** (in `BuyInvoiceRepositoryImpl`):
```dart
BuyingInvoiceModel createBuyInvoice({
  required List<InvoiceItemModel> items,
  required SupplierModel supplier,
  required double discount,
}) {
  // 1. Validate items have qty > 0
  // 2. Calculate subtotal = sum(items.lineTotal)
  // 3. Calculate total = subtotal - discount
  // 4. Check safe balance >= total (via SafeCubit/Service)
  // 5. Start ObjectBox transaction
  // 6. Create BuyingInvoiceModel with date=now, discount, paidAmount=0
  // 7. Set supplier ToOne relation
  // 8. For each item:
  //    a. Set item.invoice.target = invoice
  //    b. Put item (box.put(item))
  //    c. Update product.quantity += item.quantity
  //    d. Put product (box.put(product))
  // 9. Decrease safe balance by total (via SafeService)
  // 10. Create BalanceAuditEntryModel (type=buyInvoice, amount=-total)
  // 11. Commit transaction
  // 12. Return saved invoice
}
```

**ObjectBox Boxes Used** (from `ObjectBoxServices`):
- `buyInvoicesBox` — BuyingInvoiceModel
- `invoiceItemsBox` — InvoiceItemModel (shared)
- `productsBox` — ProductModel
- `suppliersBox` — SupplierModel
- `safeBalancesBox` — SafeBalanceModel
- `balanceAuditBox` — BalanceAuditEntryModel

## Stream vs List

- `watchInvoices()` → `Stream<List<BuyingInvoiceModel>>` for reactive UI (history screen)
- `getAllBuyInvoices()` → `List<BuyingInvoiceModel>` for one-time fetch

## Error Handling

- All methods catch exceptions and rethrow as `RepositoryException` with message
- `createBuyInvoice` may throw `InsufficientBalanceException` (custom) for safe balance check