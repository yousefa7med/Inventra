# Implementation Plan: Selling Invoice Form

**Feature Directory**: `specs/002-selling-invoice-form`
**Spec Version**: 1.0
**Created**: 2026-07-09

---

## 1. Architecture Overview

### 1.1 System Context
The Selling Invoice Form is a new feature in the Inventra Flutter app that enables creating sales transactions. It integrates with the existing architecture:
- **State Management**: flutter_bloc (Cubit pattern)
- **Dependency Injection**: GetIt
- **Database**: ObjectBox (local, offline-first)
- **Routing**: Custom AppRouter + AppNavigation
- **Theme**: AppTheme with AppColors/AppTextStyles
- **Responsive**: flutter_screenutil

### 1.2 Component Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        SellingInvoiceFormView                    │
│  ┌──────────────┐  ┌──────────────────┐  ┌───────────────────┐  │
│  │CustomerAuto- │  │  InvoiceProduct  │  │ InvoiceTotalsCard │  │
│  │ completeDrop │  │      List        │  │                   │  │
│  │     down     │  │                  │  │  - Subtotal       │  │
│  └──────┬───────┘  └────────┬─────────┘  │  - Discount Input │  │
│         │                   │            │  - Total After    │  │
│         ▼                   ▼            │    Discount       │  │
│  ┌─────────────────────────────────────┐ └────────┬──────────┘  │
│  │         SellInvoiceCubit             │          │            │
│  │  State: Initial | Loading | Success  │          │            │
│  │           | Error | ValidationError  │          │            │
│  └──────────────────┬───────────────────┘          │            │
│                     │                              │            │
│         ┌───────────┴───────────┐                  │            │
│         ▼                       ▼                  ▼            │
│  ┌─────────────┐        ┌──────────────┐    ┌────────────┐    │
│  │ObjectBoxServices│      │  AppNavigation│    │showSnackBar│    │
│  │(ProductsBox,   │        │  (routing)    │    │(feedback)  │    │
│  │ CustomersBox,  │        └──────────────┘    └────────────┘    │
│  │ InvoicesBox,   │                                              │
│  │ ItemsBox,      │                                              │
│  │ OperationsBox) │                                              │
│  └────────────────┘                                              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      AddProductToInvoiceView                     │
│  ┌──────────────┐  ┌─────────────────────────────────────────┐  │
│  │ProductSearch │  │         ProductListWithCounters         │  │
│  │   Field      │  │  ┌──────────────────────────────────┐   │  │
│  └──────┬───────┘  │  │ ProductCard × N                  │   │  │
│         │          │  │  - Name + Sell Price             │   │  │
│         ▼          │  │  - QuantityCounter (inc/dec/input)│   │  │
│  ┌─────────────┐   │  │  - [Add to Invoice] Button       │   │  │
│  │SellInvoiceCubit│  │  └──────────────────────────────────┘   │  │
│  │(shared state)│   └─────────────────────────────────────────┘  │
│  └─────────────┘                                                │
└─────────────────────────────────────────────────────────────────┘
```

### 1.3 Data Flow

```
User Action → SellInvoiceCubit → ObjectBoxServices → Database
     │                                         │
     ▼                                         ▼
UI Update (BlocBuilder)              Inventory/SafeBalance/Operations
     │                                         │
     └────────────── State ◄───────────────────┘
```

---

## 2. Data Model

### 2.1 New ObjectBox Entities (core/models/)

#### SellInvoiceItem (NEW)
```dart
@Entity()
class SellInvoiceItem {
  @Id()
  int id = 0;
  
  int sellInvoiceId = 0;
  @Property(index: true)
  int productId = 0;
  
  int quantity = 0;
  double unitPrice = 0.0;  // snapshot of sellPrice at time of sale
  double lineTotal = 0.0;  // quantity * unitPrice
  
  @Transient
  Product? product;  // for UI display
  
  @Transient
  SellInvoice? sellInvoice;  // back-reference
  
  // To-one relations
  @Backlink('items')
  final ToOne<SellInvoice> invoice = ToOne<SellInvoice>();
  
  @Backlink('invoiceItems')
  final ToOne<Product> productRef = ToOne<Product>();
}
```

#### SellOperation (NEW) - for future Operations feature
```dart
@Entity()
class SellOperation {
  @Id()
  int id = 0;
  
  int sellInvoiceId = 0;
  @Property(index: true)
  DateTime date = DateTime.now();
  
  // Use existing BalanceChangeType enum (core/models/balance_change_type.dart)
  // Values: expense, buyInvoice, sellInvoice, returnReceipt, manualAdjustment
  @Property(index: true)
  int type = BalanceChangeType.sellInvoice.index;
  
  double totalAmount = 0.0;
  String customerName = '';
  
  // For future filtering in Operations feature
  @Property(index: true)
  DateTime createdAt = DateTime.now();
}
```

#### Updated SellInvoice (EXISTING - add relationship)
```dart
// In existing SellInvoice entity, add:
@Backlink('invoice')
final ToMany<SellInvoiceItem> items = ToMany<SellInvoiceItem>();
```

### 2.2 Existing Entities (referenced)

**Product** (core/models/product.dart)
- id, name, barcode, quantity, buyPrice, sellPrice, supplierId

**Customer** (core/models/customer.dart)
- id, name, phone, address, balance

**SellInvoice** (core/models/sell_invoice.dart)
- id, customerId, date, total, paidAmount, discount
- NEW: items (ToMany<SellInvoiceItem>)

---

## 3. State Management

### 3.1 SellInvoiceState (features/invoice/controller/cubit/sell_invoice_state.dart)

```dart
abstract class SellInvoiceState extends Equatable {
  const SellInvoiceState();
}

class SellInvoiceInitial extends SellInvoiceState {
  const SellInvoiceInitial();
  @override List<Object?> get props => [];
}

class SellInvoiceLoading extends SellInvoiceState {
  const SellInvoiceLoading();
  @override List<Object?> get props => [];
}

class SellInvoiceLoaded extends SellInvoiceState {
  final Customer? selectedCustomer;
  final List<SellInvoiceItem> items;
  final double discount;
  final double subtotal;
  final double totalAfterDiscount;
  
  const SellInvoiceLoaded({
    this.selectedCustomer,
    this.items = const [],
    this.discount = 0.0,
  }) : subtotal = items.fold(0.0, (sum, item) => sum + item.lineTotal),
       totalAfterDiscount = (items.fold(0.0, (sum, item) => sum + item.lineTotal)) - discount;
       
  SellInvoiceLoaded copyWith({
    Customer? selectedCustomer,
    List<SellInvoiceItem>? items,
    double? discount,
  }) => SellInvoiceLoaded(
    selectedCustomer: selectedCustomer ?? this.selectedCustomer,
    items: items ?? this.items,
    discount: discount ?? this.discount,
  );
  
  @override List<Object?> get props => [selectedCustomer, items, discount];
}

class SellInvoiceError extends SellInvoiceState {
  final String message;
  const SellInvoiceError(this.message);
  @override List<Object?> get props => [message];
}

class SellInvoiceValidationError extends SellInvoiceState {
  final String message;
  const SellInvoiceValidationError(this.message);
  @override List<Object?> get props => [message];
}

class SellInvoiceConfirmed extends SellInvoiceState {
  final SellInvoice invoice;
  const SellInvoiceConfirmed(this.invoice);
  @override List<Object?> get props => [invoice];
}
```

### 3.2 SellInvoiceCubit (features/invoice/controller/cubit/sell_invoice_cubit.dart)

```dart
class SellInvoiceCubit extends Cubit<SellInvoiceState> {
  final ObjectBoxServices _objectBox;
  final List<SellInvoiceItem> _items = [];
  Customer? _selectedCustomer;
  double _discount = 0.0;
  
  SellInvoiceCubit(this._objectBox) : super(const SellInvoiceInitial());
  
  // Getters for UI
  List<SellInvoiceItem> get items => List.unmodifiable(_items);
  Customer? get selectedCustomer => _selectedCustomer;
  double get discount => _discount;
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.lineTotal);
  double get totalAfterDiscount => (subtotal - _discount).clamp(0.0, double.infinity);
  
  // Actions
  Future<void> loadCustomers() async { ... }
  Future<void> loadProducts(String query) async { ... }
  
  void selectCustomer(Customer customer) {
    _selectedCustomer = customer;
    _emitLoaded();
  }
  
  void clearCustomer() {
    _selectedCustomer = null;
    _emitLoaded();
  }
  
  void setDiscount(double value) {
    _discount = value.clamp(0.0, subtotal);
    _emitLoaded();
  }
  
  void addProduct(Product product, int quantity) {
    // Check if product already in items
    final existingIndex = _items.indexWhere((i) => i.productId == product.id);
    if (existingIndex >= 0) {
      // Merge quantities (per clarification)
      final newQty = (_items[existingIndex].quantity + quantity).clamp(1, product.quantity);
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: newQty,
        lineTotal: newQty * _items[existingIndex].unitPrice,
      );
    } else {
      _items.add(SellInvoiceItem(
        productId: product.id,
        quantity: quantity.clamp(1, product.quantity),
        unitPrice: product.sellPrice,
        lineTotal: quantity.clamp(1, product.quantity) * product.sellPrice,
      )..productRef.target = product);
    }
    _emitLoaded();
  }
  
  void updateItemQuantity(int itemIndex, int newQuantity) {
    if (newQuantity < 1) {
      _items.removeAt(itemIndex);
    } else {
      final product = _items[itemIndex].productRef.target;
      if (product != null) {
        newQuantity = newQuantity.clamp(1, product.quantity);
      }
      _items[itemIndex] = _items[itemIndex].copyWith(
        quantity: newQuantity,
        lineTotal: newQuantity * _items[itemIndex].unitPrice,
      );
    }
    _emitLoaded();
  }
  
  void removeItem(int index) {
    _items.removeAt(index);
    _emitLoaded();
  }
  
  Future<void> confirmInvoice() async {
    // Validation
    if (_selectedCustomer == null) {
      emit(const SellInvoiceValidationError('Please select a customer'));
      return;
    }
    if (_items.isEmpty) {
      emit(const SellInvoiceValidationError('Add at least one product'));
      return;
    }
    // Check stock
    for (final item in _items) {
      final product = item.productRef.target;
      if (product == null || product.quantity < item.quantity) {
        emit(SellInvoiceValidationError('Insufficient stock for ${product?.name ?? 'product'}'));
        return;
      }
    }
    
    emit(const SellInvoiceLoading());
    try {
      await _objectBox.store.runInTransaction(TxMode.write, () {
        // 1. Create SellInvoice
        final invoice = SellInvoice(
          customerId: _selectedCustomer!.id,
          date: DateTime.now(),
          total: subtotal,
          discount: _discount,
          paidAmount: 0.0, // Can be extended for partial payment
        );
        _objectBox.sellInvoicesBox.put(invoice);
        
        // 2. Create and link SellInvoiceItems
        for (final item in _items) {
          item.sellInvoiceId = invoice.id;
          _objectBox.sellInvoiceItemsBox.put(item);
          
          // 3. Decrease product inventory
          final product = item.productRef.target!;
          product.quantity -= item.quantity;
          _objectBox.productsBox.put(product);
        }
        
        // 4. Increase safe balance (via AppCubit or direct)
        // Assuming AppCubit manages safe balance
        // GetIt.instance<AppCubit>().increaseSafeBalance(totalAfterDiscount);
        
        // 5. Record SellOperation
        final operation = SellOperation(
          sellInvoiceId: invoice.id,
          date: invoice.date,
          type: BalanceChangeType.sellInvoice.index,
          totalAmount: totalAfterDiscount,
          customerName: _selectedCustomer!.name,
        );
        _objectBox.sellOperationsBox.put(operation);
        
        invoice.items.addAll(_items);
      });
      
      // Reset state
      _items.clear();
      _selectedCustomer = null;
      _discount = 0.0;
      emit(SellInvoiceConfirmed(invoice));
    } catch (e) {
      emit(SellInvoiceError('Failed to save invoice: $e'));
    }
  }
  
  void _emitLoaded() => emit(SellInvoiceLoaded(
    selectedCustomer: _selectedCustomer,
    items: List.from(_items),
    discount: _discount,
  ));
}
```

---

## 4. UI Components

### 4.1 Pages

#### SellingInvoiceFormView (features/invoice/presentation/views/selling_invoice_form_view.dart)
- **Route**: `/selling-invoice-form`
- **State**: BlocProvider<SellInvoiceCubit>
- **Layout**: Scaffold with AppBar, body (SingleChildScrollView), FAB
- **Sections**:
  1. CustomerAutocompleteDropdown
  2. InvoiceProductList (items with remove/update quantity)
  3. InvoiceTotalsCard (subtotal, discount input, total after discount)
  4. InvoiceFormActions (confirm button)

#### AddProductToInvoiceView (features/invoice/presentation/views/add_product_to_invoice_view.dart)
- **Route**: `/add-product-to-invoice`
- **State**: BlocProvider.value (shared SellInvoiceCubit)
- **Layout**: Scaffold with AppBar, body (Column)
- **Sections**:
  1. ProductSearchField (barcode or name)
  2. ProductListWithCounters (ListView.builder)

### 4.2 Widgets (features/invoice/presentation/widgets/)

| Widget | Responsibility |
|--------|----------------|
| `CustomerAutocompleteDropdown` | Dropdown with search filter, uses AppTextField, shows Customer list |
| `ProductSearchField` | AppTextField with barcode/name search, debounced |
| `ProductListWithCounters` | ListView of ProductCardWithCounter |
| `ProductCardWithCounter` | Product name, price, QuantityCounter, Add button |
| `QuantityCounter` | -/+ buttons, TextField for manual entry, min/max validation |
| `InvoiceProductList` | ListView of InvoiceItemTile |
| `InvoiceItemTile` | Product name, price, quantity, line total, edit/remove |
| `InvoiceTotalsCard` | Subtotal display, Discount AppTextField, Total after discount |
| `InvoiceFormActions` | Confirm AppButton (full width), disabled when invalid |

---

## 5. Routing & Navigation

### 5.1 AppRoutes (core/config/configrations.dart)
```dart
abstract class AppRoutes {
  // ... existing routes
  static const String sellingInvoiceForm = '/selling-invoice-form';
  static const String addProductToInvoice = '/add-product-to-invoice';
}
```

### 5.2 AppRouter.generateRoute()
```dart
case AppRoutes.sellingInvoiceForm:
  return _buildPageRoute(
    BlocProvider(
      create: (_) => GetIt.instance<SellInvoiceCubit>()..loadCustomers(),
      child: const SellingInvoiceFormView(),
    ),
  );

case AppRoutes.addProductToInvoice:
  final cubit = GetIt.instance<SellInvoiceCubit>();
  return _buildPageRoute(
    BlocProvider.value(
      value: cubit..loadProducts(''),
      child: const AddProductToInvoiceView(),
    ),
  );
```

---

## 6. Dependency Injection (main.dart)

```dart
// In configureDependencies()
getIt.registerLazySingleton<SellInvoiceCubit>(() => 
  SellInvoiceCubit(GetIt.instance<ObjectBoxServices>())
);

// ObjectBox boxes registration (in ObjectBoxServices init)
getIt.registerLazySingleton<Box<SellInvoiceItem>>(
  () => GetIt.instance<ObjectBoxServices>().store.box<SellInvoiceItem>()
);
getIt.registerLazySingleton<Box<SellOperation>>(
  () => GetIt.instance<ObjectBoxServices>().store.box<SellOperation>()
);
```

---

## 7. ObjectBox Codegen

After creating entities:
```bash
dart run build_runner build --delete-conflicting-outputs
```

Generated files:
- `lib/objectbox.g.dart`
- `lib/objectbox-model.json`

---

## 8. Integration Points

### 8.1 Dashboard Card (features/dashboard/presentation/views/dashboard_view.dart)
Add "اضافة فاتورة" card that calls:
```dart
AppNavigation.pushName(context, AppRoutes.sellingInvoiceForm);
```

### 8.2 Safe Balance Update
In `AppCubit` (core/controller/controllers/app_cubit/), add:
```dart
void increaseSafeBalance(double amount) {
  _safeBalance += amount;
  emit(AppState(safeBalance: _safeBalance));
}
```

Call from `SellInvoiceCubit.confirmInvoice()` after transaction.

### 8.3 Operations Feature (Future)
The `SellOperation` entity is created for the future Operations feature. No UI changes needed now.

---

## 9. Validation Rules

| Field | Rule | Error Message (Arabic) |
|-------|------|------------------------|
| Customer | Required | 'يرجى اختيار عميل' |
| Products | At least 1 item | 'يرجى إضافة منتج واحد على الأقل' |
| Product Quantity | 1 ≤ qty ≤ stock | 'الكمية غير متوفرة في المخزون' |
| Discount | 0 ≤ discount ≤ subtotal | 'الخصم لا يمكن أن يتجاوز المجموع' |

---

## 10. Currency Precision

All monetary values (prices, totals, discounts) use `double` rounded to 2 decimal places (EGP piasters). Display uses Arabic locale currency formatting (`NumberFormat.currency(locale: 'ar_EG')`).

---

## 11. Localization Constants

All user-facing Arabic strings centralized in `lib/core/constants/app_strings.dart` (class `AppStrings`). Widgets reference `AppStrings.invoiceFormTitle`, `AppStrings.selectCustomer`, etc. No hardcoded strings in widget classes. This satisfies Constitution III (Arabic RTL First - no hardcoded strings).

Example structure:
```dart
class AppStrings {
  // Invoice
  static const String invoiceFormTitle = 'فاتورة بيع';
  static const String selectCustomer = 'اختر العميل';
  static const String addProduct = 'إضافة منتج';
  static const String confirmInvoice = 'تأكيد الفاتورة';
  static const String subtotal = 'المجموع';
  static const String discount = 'الخصم';
  static const String totalAfterDiscount = 'الإجمالي بعد الخصم';
  static const String noProductsAdded = 'لا توجد منتجات مضافة';
  static const String noCustomersFound = 'لا يوجد عملاء';
  static const String noProductsFound = 'لا توجد منتجات';
  static const String searchHint = 'بحث بالباركود أو الاسم';
  static const String addToInvoice = 'إضافة للفاتورة';
  static const String invoiceSaved = 'تم حفظ الفاتورة بنجاح';
  // Validation
  static const String customerRequired = 'يرجى اختيار عميل';
  static const String atLeastOneProduct = 'يرجى إضافة منتج واحد على الأقل';
  static const String insufficientStock = 'الكمية غير متوفرة للمنتج: ';
  static const String discountExceedsSubtotal = 'الخصم لا يمكن أن يتجاوز المجموع';
  // ... more keys
}
```

---

## 12. File Structure

```
lib/
├── core/
│   ├── models/
│   │   ├── sell_invoice_item.dart       # NEW
│   │   ├── sell_operation.dart          # NEW
│   │   └── sell_invoice.dart            # MODIFIED (add items relation)
│   └── helper/functions.dart            # showSnackBar (existing)
├── features/
│   └── invoice/
│       ├── controller/
│       │   └── cubit/
│       │       ├── sell_invoice_cubit.dart
│       │       └── sell_invoice_state.dart
│       └── presentation/
│           ├── views/
│           │   ├── selling_invoice_form_view.dart
│           │   └── add_product_to_invoice_view.dart
│           └── widgets/
│               ├── customer_autocomplete_dropdown.dart
│               ├── product_search_field.dart
│               ├── product_list_with_counters.dart
│               ├── product_card_with_counter.dart
│               ├── quantity_counter.dart
│               ├── invoice_product_list.dart
│               ├── invoice_item_tile.dart
│               ├── invoice_totals_card.dart
│               └── invoice_form_actions.dart
└── main.dart                            # MODIFIED (DI registration)
```

---

## 12. Quickstart Validation Guide

### Prerequisites
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Test Scenarios

1. **Create Invoice with Single Product**
   - Open Dashboard → Tap "اضافة فاتورة"
   - Select customer from dropdown
   - Tap FAB → Search product by barcode
   - Set quantity → Tap "Add to Invoice"
   - Verify subtotal = price × qty
   - Enter discount → Verify total after discount
   - Tap Confirm → Verify success snackbar
   - Check product quantity decreased in Inventory

2. **Create Invoice with Multiple Products**
   - Add 3 different products
   - Verify line totals and subtotal
   - Apply discount
   - Confirm → Verify all 3 products decreased

3. **Merge Duplicate Product**
   - Add product A (qty 2)
   - Add product A again (qty 3)
   - Verify single line item with qty 5

4. **Validation Errors**
   - Try confirm without customer → Error snackbar
   - Try confirm with empty items → Error snackbar
   - Try discount > subtotal → Capped at subtotal
   - Try qty > stock → Error on confirm

5. **Customer Dropdown Search**
   - Tap dropdown → Type partial name → Filtered results
   - Select customer → Shows on form
   - Clear selection → Dropdown reopens

---

## 13. Rollback Plan

If issues arise:
1. Revert ObjectBox model changes
2. Run `build_runner` to regenerate
3. Remove feature routes from AppRouter
4. Remove DI registrations
5. Remove Dashboard card

---

## 14. Acceptance Criteria Mapping

| Spec ID | Test Scenario |
|---------|---------------|
| FR-001 | Create invoice with all fields |
| FR-002 | Dashboard card navigation |
| FR-003 | Customer dropdown autocomplete |
| FR-004 | Discount input |
| FR-005 | FAB to add products |
| FR-006 | Product search page |
| FR-007 | Product cards with counters |
| FR-008 | Add product returns to form |
| FR-009 | Invoice product list display |
| FR-010 | Totals display |
| FR-011 | Discount validation |
| FR-012 | Confirm updates inventory/safe/operations |
| FR-013 | Insufficient stock prevention |
| FR-014 | Uses correct ObjectBox entities |
| FR-015 | Follows architecture conventions |