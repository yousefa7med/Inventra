# Data Model: Customer Supplier Management

**Feature**: 003-customer-supplier-management
**Date**: 2026-07-16

## Entities

### CustomerModel (Existing - core/models/customer_model.dart)

```dart
@Entity()
class CustomerModel {
  @Id()
  int id = 0;

  final String name;           // Required, min 3 chars
  final String? address;       // Nullable
  final String phoneNum;       // Required, phone format regex

  final ToMany<SellingInvoiceModel> invoices = ToMany<SellingInvoiceModel>();

  CustomerModel({
    required this.name,
    required this.address,
    required this.phoneNum,
  });
}
```

**Fields**:
| Field | Type | Required | Validation | Notes |
|-------|------|----------|------------|-------|
| id | int | Auto | - | ObjectBox assigned |
| name | String | Yes | min 3 chars, not empty | Customer display name |
| phoneNum | String | Yes | regex `^[0-9+]{7,15}$` | Phone number for dialer |
| address | String? | Yes | not empty | Nullable in DB, required in form |
| balance | double | Auto | - | Calculated from invoices |

**Indexes**: 
- `name` (for search performance)
- `phoneNum` (for lookup)

---

### SupplierModel (Existing - core/models/supplier_model.dart)

```dart
@Entity()
class SupplierModel {
  @Id()
  int id = 0;

  final String name;           // Contact person name, required, min 3 chars
  final String? storeAdd;      // Store address, nullable
  final String storeName;      // Store/company name, required
  final String phoneNum;       // Required, phone format regex

  SupplierModel({
    required this.name,
    this.storeAdd,
    required this.storeName,
    required this.phoneNum,
  });
}
```

**Fields**:
| Field | Type | Required | Validation | Notes |
|-------|------|----------|------------|-------|
| id | int | Auto | - | ObjectBox assigned |
| name | String | Yes | min 3 chars, not empty | Contact person name |
| storeName | String | Yes | not empty | Company/store name |
| phoneNum | String | Yes | regex `^[0-9+]{7,15}$` | Phone number for dialer |
| storeAdd | String? | Yes | not empty | Nullable in DB, required in form |
| balance | double | Auto | - | Calculated from buy invoices |

**Indexes**:
- `name` (for search performance)
- `storeName` (for search by store)
- `phoneNum` (for lookup)

---

## State Models

### CustomerState (features/customers/controller/cubit/customer_state.dart)

```dart
abstract class CustomerState extends Equatable {
  const CustomerState();
}

class CustomerInitial extends CustomerState {
  @override List<Object?> get props => [];
}

class CustomerLoading extends CustomerState {
  @override List<Object?> get props => [];
}

class CustomerLoaded extends CustomerState {
  final List<CustomerModel> customers;
  final String searchQuery;
  
  const CustomerLoaded(this.customers, {this.searchQuery = ''});
  
  @override List<Object?> get props => [customers, searchQuery];
}

class CustomerError extends CustomerState {
  final String message;
  const CustomerError(this.message);
  
  @override List<Object?> get props => [message];
}

class CustomerOperationSuccess extends CustomerState {
  final String message;
  const CustomerOperationSuccess(this.message);
  
  @override List<Object?> get props => [message];
}
```

**Transitions**:
```
CustomerInitial → CustomerLoading → CustomerLoaded
CustomerLoaded → CustomerLoading (on search/refresh)
CustomerLoaded → CustomerError (on failure)
CustomerLoaded → CustomerOperationSuccess (on edit success) → CustomerLoaded
CustomerError → CustomerLoading (on retry)
```

---

### SupplierState (features/suppliers/controller/cubit/supplier_state.dart)

```dart
abstract class SupplierState extends Equatable {
  const SupplierState();
}

class SupplierInitial extends SupplierState {
  @override List<Object?> get props => [];
}

class SupplierLoading extends SupplierState {
  @override List<Object?> get props => [];
}

class SupplierLoaded extends SupplierState {
  final List<SupplierModel> suppliers;
  final String searchQuery;
  
  const SupplierLoaded(this.suppliers, {this.searchQuery = ''});
  
  @override List<Object?> get props => [suppliers, searchQuery];
}

class SupplierError extends SupplierState {
  final String message;
  const SupplierError(this.message);
  
  @override List<Object?> get props => [message];
}

class SupplierOperationSuccess extends SupplierState {
  final String message;
  const SupplierOperationSuccess(this.message);
  
  @override List<Object?> get props => [message];
}
```

**Transitions**: Same as CustomerState

---

## Validation Rules

### Customer Validation (shared with AddCustomerView)

| Field | Rule | Error Message (Arabic) |
|-------|------|------------------------|
| name | Required, min 3 chars | "برجاء إدخال اسم العميل" / "الاسم يجب أن يكون 3 أحرف على الأقل" |
| phoneNum | Required, regex `^[0-9+]{7,15}$` | "برجاء إدخال رقم الهاتف" / "برجاء إدخال رقم هاتف صحيح" |
| address | Required, not empty | "برجاء إدخال العنوان" |

### Supplier Validation (shared with AddSupplierView)

| Field | Rule | Error Message (Arabic) |
|-------|------|------------------------|
| name | Required, min 3 chars | "برجاء إدخال اسم المورد" / "الاسم يجب أن يكون 3 أحرف على الأقل" |
| storeName | Required, not empty | "برجاء إدخال اسم المتجر" |
| storeAdd | Required, not empty | "برجاء إدخال عنوان المتجر" |
| phoneNum | Required, regex `^[0-9+]{7,15}$` | "برجاء إدخال رقم الهاتف" / "برجاء إدخال رقم هاتف صحيح" |

---

## Route Arguments

### EditCustomerView
- **Route**: `/edit-customer` (AppRoutes.editCustomerView)
- **Arguments**: `CustomerModel` (full object)
- **Pattern**: Following EditProductView

### EditSupplierView
- **Route**: `/edit-supplier` (AppRoutes.editSupplierView)
- **Arguments**: `SupplierModel` (full object)
- **Pattern**: Following EditProductView

---

## Cubit Interfaces

### CustomerCubit
```dart
class CustomerCubit extends Cubit<CustomerState> {
  CustomerCubit() : super(CustomerInitial());
  
  // Load all customers
  Future<void> loadCustomers();
  
  // Search by name (debounced)
  void searchCustomers(String query);
  
  // Update customer
  Future<void> updateCustomer(CustomerModel customer);
  
  // Delete customer (future)
  Future<void> deleteCustomer(int id);
}
```

### SupplierCubit
```dart
class SupplierCubit extends Cubit<SupplierState> {
  SupplierCubit() : super(SupplierInitial());
  
  Future<void> loadSuppliers();
  void searchSuppliers(String query);
  Future<void> updateSupplier(SupplierModel supplier);
  Future<void> deleteSupplier(int id);
}
```

---

## Relationships

```
CustomerModel 1 ─── * SellingInvoiceModel
SupplierModel 1 ─── * BuyingInvoiceModel (if exists)
```

Both entities have `balance` computed from their respective invoice relationships.

---

## Phone Number Handling

**Storage**: Raw string as entered (e.g., "+201234567890", "01234567890", "012 345 67890")

**Dialer Launch**: Pass directly to `tel:` scheme via url_launcher
```dart
// core/utils/phone_utils.dart
Future<void> launchDialer(String phoneNumber) async {
  final uri = Uri(scheme: 'tel', path: phoneNumber);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}
```

No normalization needed - device dialer handles formats.

---

## Search Implementation

**Debounce**: 300ms timer on search input change

**Query**: ObjectBox `Property.contains(query, caseSensitive: false)`

**Index**: Ensure `@Index()` on `name` field in both models for performance

---

## Migration Notes

No model changes required - existing models already have all needed fields. 
Only new routes, cubits, views, and utilities need implementation.