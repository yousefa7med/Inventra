# BuyInvoiceCubitInterface Contract

**Source**: `lib/features/buying_invoice/controller/cubit/buy_invoice_cubit_interface.dart`

```dart
import 'package:Inventra/core/models/invoice_item_model.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/core/models/supplier_model.dart';

abstract class BuyInvoiceCubitInterface {
  // State getters
  List<InvoiceItemModel> get items;
  SupplierModel? get selectedSupplier;
  double get discount;
  double get subtotal;
  double get totalAfterDiscount;
  List<SupplierModel> get suppliers;
  List<ProductModel> get products;

  // Actions
  Future<void> loadSuppliers();
  Future<void> loadProducts(String search);
  void selectSupplier(SupplierModel supplier);
  void clearSupplier();
  void setDiscount(double value);
  void addProductItem(ProductModel product, int quantity);
  void updateItemQuantity(int itemIndex, int newQuantity);
  void removeItem(int index);
  bool validateBuyInvoice();
  Future<void> confirmInvoice();
}
```

## Method Contracts

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `loadSuppliers()` | — | `Future<void>` | Fetches all suppliers from repository, emits loading/error/success states |
| `loadProducts(search)` | `search`: query string | `Future<void>` | Searches products by name/barcode (Arabic normalized), emits product list |
| `selectSupplier(supplier)` | `SupplierModel` | `void` | Sets selected supplier |
| `clearSupplier()` | — | `void` | Clears selected supplier |
| `setDiscount(value)` | `double` | `void` | Sets discount (clamped 0..subtotal), emits discountChanged |
| `addProductItem(product, quantity)` | Product, qty > 0 | `void` | Adds/updates item line, emits itemAdded |
| `updateItemQuantity(index, newQty)` | Index, new quantity | `void` | Updates qty (removes if < 1), emits itemUpdated |
| `removeItem(index)` | Index | `void` | Removes item, emits itemRemoved |
| `validateBuyInvoice()` | — | `bool` | Validates: supplier selected, at least one item with qty > 0, safe balance sufficient |
| `confirmInvoice()` | — | `Future<void>` | Calls repository.createBuyInvoice(), on success clears form, emits confirmed; on error emits error |

## State Management

**States** (mirror SellInvoiceState):
- `BuyInvoiceInitial` — initial/cleared
- `BuyInvoiceLoading` — confirming invoice
- `BuyInvoiceSuppliersLoaded` — suppliers loaded
- `BuyInvoiceProductsLoaded` — products loaded
- `BuyInvoiceProductLoading` — loading products
- `BuyInvoiceAddProduct` — item added
- `BuyInvoiceUpdateProductQuantity` — qty changed
- `BuyInvoiceRemoveProduct` — item removed
- `BuyInvoiceDiscountChanged` — discount changed
- `BuyInvoiceConfirmed` — successfully saved
- `BuyInvoiceError(message)` — error with message

**BuildWhen / ListenWhen**: All BlocBuilder/BlocListener MUST use `buildWhen`/`listenWhen` to prevent unnecessary rebuilds.

## Implementation Notes

**File**: `lib/features/buying_invoice/controller/cubit/buy_invoice_cubit.dart`

**Dependencies** (injected via GetIt):
- `BuyInvoiceRepository`
- `SafeRepository` or `SafeCubit` (for balance check/decrease)

**Internal State**:
```dart
final List<InvoiceItemModel> _items = [];
SupplierModel? _selectedSupplier;
double _discount = 0.0;
List<SupplierModel> _suppliers = [];
List<ProductModel> _products = [];
```

**confirmInvoice() Logic**:
1. Validate (supplier, items with qty > 0, safe balance >= total)
2. Emit `BuyInvoiceLoading`
3. Call `repository.createBuyInvoice(items: _items, supplier: _selectedSupplier!, discount: _discount)`
4. On success: clear `_items`, `_selectedSupplier`, `_discount`; emit `BuyInvoiceConfirmed`
5. On error: emit `BuyInvoiceError(message)`

## Related Contracts

- [BuyInvoiceRepository](../contracts/buy_invoice_repository.md) — data access
- [data-model.md](data-model.md) — entity definitions