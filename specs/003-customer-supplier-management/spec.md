# Feature Specification: Customer Supplier Management

**Feature Branch**: `003-customer-supplier-management`

**Created**: 2026-07-16

**Status**: Draft

**Input**: User description: "in AppDrawer there is Drawer item "All Customer", that navigate to AllCustomerView make search bar that search with customer name and customer card contain that name and address and phone number and buttom to call the customer (use url_luncher to go out the app and call the customer) and onther buttom to edit customer data that navigate to Edit Customer show form like add customer form with same validations, same tasks to AllSuppliersView"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Search Customers by Name (Priority: P1)
A user navigates to "All Customers" from the drawer and wants to find a specific customer quickly by searching their name.

**Why this priority**: Core search functionality is essential for finding customers quickly in a large database.

**Independent Test**: Can be tested by navigating to AllCustomersView, typing in the search bar, and verifying filtered results show only matching customers.

**Acceptance Scenarios**:
1. **Given** the user is on AllCustomersView with multiple customers in the database, **When** they type a customer name in the search bar, **Then** the customer list filters in real-time to show only customers whose names contain the search text (case-insensitive).
2. **Given** the user is on AllCustomersView with no search text, **When** they clear the search bar, **Then** all customers are displayed again.
3. **Given** the user searches for a name that matches no customers, **When** they submit the search, **Then** an empty state message is shown indicating no customers found.

---

### User Story 2 - View Customer Details in Card (Priority: P1)
A user views the customer list and sees each customer displayed as a card with their name, address, and phone number.

**Why this priority**: Core display functionality - users need to see customer details at a glance.

**Independent Test**: Can be tested by navigating to AllCustomersView and verifying each customer card displays name, address, and phone number correctly.

**Acceptance Scenarios**:
1. **Given** the user is on AllCustomersView with customers in the database, **When** the view loads, **Then** each customer is displayed as a card showing their name, address, and phone number.
2. **Given** a customer has no address or phone number, **When** their card is displayed, **Then** the missing fields show a placeholder (e.g., "لا يوجد عنوان" / "لا يوجد هاتف").

---

### User Story 3 - Call Customer from Card (Priority: P1)
A user taps the call button on a customer card to initiate a phone call using the device's dialer.

**Why this priority**: Core business functionality - calling customers directly from the app is a primary use case.

**Independent Test**: Can be tested by tapping the call button on a customer card and verifying the device dialer opens with the correct phone number.

**Acceptance Scenarios**:
1. **Given** the user is on AllCustomersView and a customer has a valid phone number, **When** they tap the call button on that customer's card, **Then** the device's phone dialer opens with the customer's phone number pre-filled.
2. **Given** a customer has no phone number, **When** the user taps the call button, **Then** a snackbar shows an error message "لا يوجد رقم هاتف لهذا العميل" (No phone number for this customer).

---

### User Story 4 - Edit Customer Details (Priority: P1)
A user taps the edit button on a customer card to navigate to an edit form pre-filled with the customer's current data, with the same validations as the Add Customer form.

**Why this priority**: Core CRUD functionality - editing existing customers is essential for data maintenance.

**Independent Test**: Can be tested by tapping edit on a customer card, verifying the form is pre-filled, modifying data, submitting, and verifying the changes persist.

**Acceptance Scenarios**:
1. **Given** the user is on AllCustomersView, **When** they tap the edit button on a customer card, **Then** they navigate to EditCustomerView with the form pre-filled with that customer's current data (name, phone, address).
2. **Given** the user is on EditCustomerView, **When** they modify the customer data and tap save, **Then** the same validations as Add Customer apply (required fields, phone format, etc.), and on success the customer is updated in the database and the user returns to AllCustomersView.
3. **Given** the user is on EditCustomerView, **When** they tap cancel or back, **Then** they return to AllCustomersView without saving changes.
4. **Given** the user submits invalid data (empty name, invalid phone format), **When** they tap save, **Then** validation errors are shown inline and the form is not submitted.

---

### User Story 5 - Search Suppliers by Name (Priority: P1)
Same as User Story 1 but for AllSuppliersView - search suppliers by name.

**Why this priority**: Same core search functionality needed for suppliers.

**Independent Test**: Same as User Story 1 but for suppliers.

**Acceptance Scenarios**:
1. **Given** the user is on AllSuppliersView with multiple suppliers, **When** they type a supplier name in the search bar, **Then** the supplier list filters in real-time to show only suppliers whose names contain the search text (case-insensitive).
2. **Given** the user clears the search, **Then** all suppliers are displayed again.
3. **Given** no suppliers match the search, **Then** an empty state message is shown.

---

### User Story 6 - View Supplier Details in Card (Priority: P1)
Same as User Story 2 but for suppliers - cards show supplier name, address, phone number.

**Why this priority**: Core display functionality for suppliers.

**Independent Test**: Navigate to AllSuppliersView and verify supplier cards display correctly.

**Acceptance Scenarios**:
1. **Given** the user is on AllSuppliersView with suppliers in the database, **When** the view loads, **Then** each supplier is displayed as a card showing their name, address, and phone number.
2. **Given** a supplier has missing address or phone, **Then** placeholders are shown for missing fields.

---

### User Story 7 - Call Supplier from Card (Priority: P1)
Same as User Story 3 but for suppliers - call button opens dialer with supplier's phone number.

**Why this priority**: Core business functionality for suppliers.

**Independent Test**: Tap call button on supplier card, verify dialer opens with correct number.

**Acceptance Scenarios**:
1. **Given** a supplier has a valid phone number, **When** the user taps the call button, **Then** the device dialer opens with the supplier's phone number.
2. **Given** a supplier has no phone number, **When** the user taps call, **Then** a snackbar shows "لا يوجد رقم هاتف لهذا المورد".

---

### User Story 8 - Edit Supplier Details (Priority: P1)
Same as User Story 4 but for suppliers - edit form with same validations as Add Supplier.

**Why this priority**: Core CRUD for suppliers.

**Independent Test**: Edit supplier, verify form pre-filled, validations apply, changes persist.

**Acceptance Scenarios**:
1. **Given** the user taps edit on a supplier card, **Then** they navigate to EditSupplierView with form pre-filled with supplier data.
2. **Given** the user modifies and saves valid data, **Then** validations apply (same as Add Supplier), supplier is updated in database, user returns to AllSuppliersView.
3. **Given** the user cancels, **Then** they return to AllSuppliersView without changes.
4. **Given** invalid data is submitted, **Then** validation errors show inline.

---

### Edge Cases

- **Empty database**: Both AllCustomersView and AllSuppliersView should show an empty state with a message like "لا يوجد عملاء" / "لا يوجد موردين" and a button to add a new customer/supplier (navigating to the add form).
- **Phone number formats**: The call button should handle various phone formats (with/without country code, spaces, dashes) by passing the raw number to `url_launcher`.
- **RTL layout**: Since the app is Arabic-only (RTL), all cards, forms, and search bars must respect RTL layout.
- **Search performance**: Search should debounce (e.g., 300ms) to avoid excessive database queries on large datasets.
- **Edit navigation**: Edit screens should receive the customer/supplier ID via route arguments (using AppNavigation.pushName with arguments).
- **Validation reuse**: Edit forms must reuse the exact same validation logic as Add forms (DRY principle - extract validation to shared utilities).
- **Offline support**: Since ObjectBox is local-only, all operations work offline. No network error handling needed.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide an "All Customers" screen accessible from the AppDrawer that displays a searchable list of all customers.
- **FR-002**: System MUST provide a search bar on AllCustomersView that filters customers by name in real-time (case-insensitive, partial match).
- **FR-003**: System MUST display each customer as a card showing: customer name, address, and phone number.
- **FR-004**: System MUST provide a call button on each customer card that launches the device dialer with the customer's phone number using `url_launcher`.
- **FR-005**: System MUST show an error snackbar when the call button is tapped for a customer without a phone number.
- **FR-006**: System MUST provide an edit button on each customer card that navigates to EditCustomerView with the customer's data pre-filled.
- **FR-007**: System MUST provide an EditCustomerView with a form identical to AddCustomerView (same fields: name, phone, address) pre-filled with existing customer data.
- **FR-008**: System MUST apply the same validation rules on EditCustomerView as AddCustomerView (required name, valid phone format, etc.).
- **FR-009**: System MUST update the customer in the ObjectBox database on successful edit form submission and navigate back to AllCustomersView.
- **FR-010**: System MUST provide an "All Suppliers" screen accessible from the AppDrawer with identical functionality to AllCustomersView but for suppliers.
- **FR-011**: System MUST provide a search bar on AllSuppliersView that filters suppliers by name in real-time.
- **FR-012**: System MUST display each supplier as a card showing: supplier name (contact person), store name, store address, and phone number.
- **FR-013**: System MUST provide a call button on each supplier card that launches the device dialer with the supplier's phone number.
- **FR-014**: System MUST show an error snackbar when the call button is tapped for a supplier without a phone number.
- **FR-015**: System MUST provide an edit button on each supplier card that navigates to EditSupplierView with the supplier's data pre-filled.
- **FR-016**: System MUST provide an EditSupplierView with a form identical to AddSupplierView (fields: contact name, store name, store address, phone) pre-filled with existing supplier data.
- **FR-017**: System MUST apply the same validation rules on EditSupplierView as AddSupplierView (required contact name min 3 chars, required store name, required store address, required phone with format regex).
- **FR-018**: System MUST update the supplier in the ObjectBox database on successful edit form submission and navigate back to AllSuppliersView.
- **FR-019**: System MUST show an empty state with appropriate message when no customers/suppliers exist or no search results match.
- **FR-020**: System MUST use `AppNavigation.pushName()` for all navigation (never `Navigator.of(context)` directly).
- **FR-021**: System MUST use `showSnackBar()` from `core/helper/functions.dart` for all snackbars (never `ScaffoldMessenger.of(context)` directly).
- **FR-022**: System MUST use `AppTextField` from `core/widgets/app_text_field.dart` for all form inputs (never raw `TextFormField`).
- **FR-023**: System MUST use `AppButton` from `core/widgets/app_button.dart` for full-width form submit buttons.
- **FR-024**: System MUST use `AppTheme`, `AppColors`, and `AppTextStyle` for all styling (no hardcoded colors, text styles, or decorations).
- **FR-025**: System MUST use RTL layout (Arabic locale) for all screens.
- **FR-026**: System MUST debounce search input (300ms) to avoid excessive database queries.
- **FR-027**: System MUST extract validation logic into shared utilities reusable by both Add and Edit forms for customers and suppliers.
- **FR-028**: System MUST use BLoC/Cubit pattern for state management (CustomerCubit, SupplierCubit) registered as LazySingleton in GetIt.
- **FR-029**: System MUST add routes for EditCustomerView and EditSupplierView in AppRoutes and AppRouter.

---

### Key Entities

- **Customer**: Represents a customer entity with fields: `id` (int), `name` (String), `phoneNum` (String), `address` (String?), `balance` (double). Stored in ObjectBox. Note: `address` is nullable in the model.
- **Supplier**: Represents a supplier entity with fields: `id` (int), `name` (String), `storeName` (String), `storeAdd` (String?), `phoneNum` (String). Stored in ObjectBox. Note: Supplier has separate `name` (contact person) and `storeName` (company/store), with `storeAdd` as address.
- **CustomerCubit**: Manages state for customer list, search, and edit operations. States: CustomerLoading, CustomerLoaded(List<Customer>), CustomerError(String), CustomerOperationSuccess.
- **SupplierCubit**: Manages state for supplier list, search, and edit operations. States: SupplierLoading, SupplierLoaded(List<Supplier>), SupplierError(String), SupplierOperationSuccess.
- **EditCustomerView**: Screen for editing an existing customer, receives CustomerModel object via route arguments.
- **EditSupplierView**: Screen for editing an existing supplier, receives SupplierModel object via route arguments.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: User can search customers by name and see filtered results within 300ms of typing.
- **SC-002**: User can tap call button on a customer card and the device dialer opens with the correct phone number 100% of the time.
- **SC-003**: User can edit a customer's details, submit the form, and see the updated data reflected in the customer list immediately.
- **SC-004**: All validation rules from Add Customer form apply identically to Edit Customer form (zero validation differences).
- **SC-005**: Same measurable outcomes (SC-001 through SC-004) apply to Suppliers (AllSuppliersView, EditSupplierView).
- **SC-006**: Empty states display correctly when no customers/suppliers exist or no search matches found.
- **SC-007**: All screens respect RTL layout and use AppTheme/AppColors/AppTextStyle exclusively (zero hardcoded styling).
- **SC-008**: Navigation uses AppNavigation exclusively, snackbars use showSnackBar helper, forms use AppTextField/AppButton.

---

## Assumptions

- **Arabic-only locale**: The app only supports Arabic (Locale('ar')) with RTL layout. All text in the spec assumes Arabic UI.
- **ObjectBox models exist**: Customer and Supplier entities already exist in `core/models/` with @Entity annotations. Customer has: id, name, phoneNum, address?, balance. Supplier has: id, name, storeName, storeAdd?, phoneNum, balance. (Note: fields differ between entities - Supplier has separate contact name and store name/address).
- **Add Customer/Supplier forms exist**: The "Add Customer" and "Add Supplier" forms with validation logic already exist in `features/dashboard/presentation/views/` and can be referenced/reused.
- **AppDrawer already has menu items**: "All Customers" and "All Suppliers" items already exist in the drawer navigation pointing to AllCustomersView and AllSuppliersView routes.
- **Routes exist**: AppRoutes already contains routes for `allCustomers` and `allSuppliers`. New routes for `editCustomerView` and `editSupplierView` need to be added.
- **ADD url_launcher**: The `url_launcher` package is NOT currently in pubspec.yaml - it MUST BE ADDED as a dependency for the call feature.
- **GetIt DI configured**: GetIt is set up in main.dart with LazySingleton registration pattern for Cubits.
- **ObjectBox codegen**: After any model changes, `dart run build_runner build --delete-conflicting-outputs` must be run.
- **No network dependency**: All data is local (ObjectBox). No API calls or network error handling needed.
- **Shared validation utils**: Validation logic for customer/supplier forms can be extracted to `core/utils/validators.dart` with separate validators for each entity (they differ between Customer and Supplier).
- **Route argument pattern**: Edit views receive the full model object as route argument (following EditProductView pattern), not just the ID.
- **Feature folders**: New features will use dedicated folders `features/customers/` and `features/suppliers/` following the project's feature-based architecture.

---

## Clarifications

**Session 2026-07-16**

- Q: url_launcher dependency missing from pubspec.yaml → A: Add `url_launcher` to pubspec.yaml (required for call feature)
- Q: Supplier model fields differ from Customer (has storeName, storeAdd separate from name/address) → A: EditSupplierView uses 4 fields matching AddSupplierView: name, storeName, storeAdd, phoneNum
- Q: Validation rules differ between Customer and Supplier add forms → A: Each edit form uses the exact same validations as its corresponding add form (they differ between entities but match within each entity)
- Q: Route argument pattern for edit views → A: Pass full model object as argument (following EditProductView pattern), not just ID
- Q: Feature folder structure for new customer/supplier features → A: Create new feature folders `features/customers/` and `features/suppliers/` with controller/cubit and presentation/views/widgets

### Routes to Add (in `core/config/configrations.dart`):
- `AppRoutes.editCustomerView` → `/edit-customer` (expects `CustomerModel` as arguments)
- `AppRoutes.editSupplierView` → `/edit-supplier` (expects `SupplierModel` as arguments)

### Route Arguments (following EditProductView pattern):
- `editCustomerView`: Expects `arguments` as `CustomerModel` (full object)
- `editSupplierView`: Expects `arguments` as `SupplierModel` (full object)

### Cubits to Create:
- `CustomerCubit` in `features/customers/controller/cubit/`
- `SupplierCubit` in `features/suppliers/controller/cubit/`

### Views to Create:
- `features/customers/presentation/views/all_customers_view.dart`
- `features/customers/presentation/views/edit_customer_view.dart`
- `features/suppliers/presentation/views/all_suppliers_view.dart`
- `features/suppliers/presentation/views/edit_supplier_view.dart`

### Widgets to Create (feature-specific):
- `features/customers/presentation/widgets/customer_card.dart`
- `features/customers/presentation/widgets/customer_search_bar.dart`
- `features/suppliers/presentation/widgets/supplier_card.dart`
- `features/suppliers/presentation/widgets/supplier_search_bar.dart`

### Shared Utilities:
- `core/utils/validators.dart` - Extract validation logic with separate validators for Customer (name, phone, address) and Supplier (name, storeName, storeAdd, phone)
- `core/utils/phone_utils.dart` - Helper for formatting/launching phone URLs via url_launcher

### Dependencies to Add:
- `url_launcher` to pubspec.yaml (required for call feature - NOT currently present)

### Dependencies to Verify (already present):
- `flutter_bloc`, `get_it`, `objectbox`, `flutter_screenutil`