# Research: Customer Supplier Management

**Feature**: 003-customer-supplier-management
**Date**: 2026-07-16

## Research Tasks

### 1. url_launcher Integration for Phone Dialer

**Decision**: Use `url_launcher` ^6.x with `tel:` scheme for phone calls

**Rationale**: 
- `url_launcher` is the standard Flutter package for launching external URLs/schemes
- `tel:` scheme opens the device's phone dialer with pre-filled number
- Works on both Android and iOS
- Package is mature, well-maintained, and compatible with Flutter 3.x

**Alternatives Considered**:
- `android_intent_plus` - Android only, more complex
- `flutter_phone_direct_caller` - Deprecated, not maintained
- Custom platform channels - Overkill for simple dialer launch

**Implementation Pattern**:
```dart
import 'package:url_launcher/url_launcher.dart';

Future<void> launchPhoneDialer(String phoneNumber) async {
  final uri = Uri(scheme: 'tel', path: phoneNumber);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch dialer for $phoneNumber';
  }
}
```

**Handling Edge Cases**:
- Empty/null phone numbers: Show snackbar error before attempting launch
- Special characters in phone: Pass raw number to `tel:` scheme (handles +, spaces, dashes)
- iOS requires `LSApplicationQueriesSchemes` in Info.plist for `tel` scheme (handled by url_launcher automatically)

---

### 2. ObjectBox Query with Search Filter

**Decision**: Use ObjectBox query builder with `contains` for case-insensitive partial matching

**Rationale**:
- ObjectBox supports `Property.contains(String, caseSensitive: false)` for efficient indexed search
- Debounce search input (300ms) to avoid excessive queries
- Stream-based queries can provide real-time updates

**Implementation Pattern**:
```dart
// In CustomerCubit
final query = box.query(CustomerModel_.name.contains(searchText, caseSensitive: false)).build();
final results = query.find();

// For debouncing
Timer? _debounceTimer;
void search(String text) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(const Duration(milliseconds: 300), () {
    _performSearch(text);
  });
}
```

**Indexing**: ObjectBox models should have `@Index()` on searchable fields (name, phoneNum) for performance.

---

### 3. BLoC/Cubit Pattern for List + Search + Edit

**Decision**: Use Cubit with states: Loading, Loaded(List<T>), Error(String), OperationSuccess

**Rationale**:
- Cubit is simpler than Bloc for this use case (no complex event transformations)
- States clearly represent UI states
- Follows existing pattern in project (ProductCubit, SafeCubit, SellInvoiceCubit)

**State Definitions**:
```dart
// CustomerCubit states
abstract class CustomerState {}
class CustomerLoading extends CustomerState {}
class CustomerLoaded extends CustomerState {
  final List<CustomerModel> customers;
  CustomerLoaded(this.customers);
}
class CustomerError extends CustomerState {
  final String message;
  CustomerError(this.message);
}
class CustomerOperationSuccess extends CustomerState {
  final String message;
  CustomerOperationSuccess(this.message);
}
```

**Methods**:
- `loadCustomers()` - Fetch all customers
- `searchCustomers(String query)` - Filter by name
- `updateCustomer(CustomerModel customer)` - Save edits
- `deleteCustomer(int id)` - Optional for future

---

### 4. Route Argument Pattern (EditProductView Reference)

**Decision**: Pass full model object as route argument (following EditProductView pattern)

**Rationale**:
- EditProductView in `features/inventory/presentation/views/edit_product_view.dart` receives `ProductModel` via `settings.arguments`
- Avoids extra database fetch in edit view
- Simpler than passing ID and fetching in Cubit
- Type-safe with `as ProductModel` cast

**Pattern from existing code**:
```dart
// In AppRouter.generateRoute():
case AppRoutes.editproductView:
  final product = settings.arguments as ProductModel;
  return pageRouteBuilderMethod(
    pageBuilder: (context, animation, secondaryAnimation) =>
        BlocProvider.value(
          value: GetIt.instance<ProductCubit>(),
          child: EditProductView(product: product),
        ),
  );

// Navigation:
AppNavigation.pushName(
  context: context,
  route: AppRoutes.editproductView,
  arguments: productModel, // Pass full object
);
```

---

### 5. Shared Validation Utilities

**Decision**: Extract validators to `core/utils/validators.dart` with separate functions per entity

**Rationale**:
- AddCustomerView and AddSupplierView have different validation rules
- Customer: name (required, min 3), phone (required, regex), address (required)
- Supplier: name (required, min 3), storeName (required), storeAdd (required), phone (required, regex)
- DRY principle - reuse in Edit views
- Follows project convention of utility files in core/utils/

**Validator Structure**:
```dart
// core/utils/validators.dart
String? validateCustomerName(String? value) {
  if (value == null || value.trim().isEmpty) return 'برجاء إدخال اسم العميل';
  if (value.trim().length < 3) return 'الاسم يجب أن يكون 3 أحرف على الأقل';
  return null;
}

String? validatePhone(String? value) {
  if (value == null || value.trim().isEmpty) return 'برجاء إدخال رقم الهاتف';
  final phoneRegex = RegExp(r'^[0-9+]{7,15}$');
  if (!phoneRegex.hasMatch(value.trim())) return 'برجاء إدخال رقم هاتف صحيح';
  return null;
}

String? validateRequired(String? value, String fieldName) {
  if (value == null || value.trim().isEmpty) return 'برجاء إدخال $fieldName';
  return null;
}

// Supplier validators
String? validateSupplierName(String? value) { /* similar to customer */ }
String? validateStoreName(String? value) { /* required */ }
String? validateStoreAddress(String? value) { /* required */ }
```

---

## Summary of Decisions

| Area | Decision | Key Reference |
|------|----------|---------------|
| Phone dialer | url_launcher ^6.x with tel: scheme | pubspec.yaml add |
| Search | ObjectBox contains() + 300ms debounce | CustomerCubit.searchCustomers |
| State mgmt | Cubit with Loading/Loaded/Error/Success | ProductCubit pattern |
| Route args | Full model object (EditProductView pattern) | AppRouter.generateRoute |
| Validation | core/utils/validators.dart per entity | AddCustomerView/AddSupplierView |
| Architecture | Feature folders: features/customers/, features/suppliers/ | features/inventory/ pattern |

All decisions align with existing project conventions and constitution requirements.