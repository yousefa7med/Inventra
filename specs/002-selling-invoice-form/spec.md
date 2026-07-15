# Feature Specification: Selling Invoice Form

**Feature Directory**: `specs/002-selling-invoice-form`
**Created**: 2026-07-09
**Status**: Draft

---

## Overview

Build a selling invoice creation feature for the Inventra inventory management app. A selling invoice represents selling products to a customer, which decreases product inventory and increases the safe balance. The feature includes a dashboard card "اضافة فاتورة" (Add Invoice) that navigates to a form where users can select a customer, apply optional discount, add products with quantities, and confirm the invoice to record it as an operation for future reporting.

---

## User Stories

### User Story 1 - Create Selling Invoice Form (Priority: P1)

As a store owner, I want to create a selling invoice by selecting a customer, adding products with quantities, and applying an optional discount, so that I can record sales transactions that automatically update inventory and safe balance.

**Why this priority**: Core business functionality - selling products is the primary revenue operation.

**Independent Test**: Navigate from Dashboard → "اضافة فاتورة" card → fill form with customer, products, quantities, discount → confirm → verify inventory decreases, safe balance increases, operation recorded.

**Acceptance Scenarios**:

1. **Given** the user is on the Dashboard, **When** they tap the "اضافة فاتورة" card, **Then** they navigate to the Selling Invoice Form page.
2. **Given** the user is on the Selling Invoice Form, **When** they search for a customer by name and select one, **Then** the customer is associated with the invoice.
3. **Given** the user is on the Selling Invoice Form, **When** they enter a discount value, **Then** the discount is applied to the total price calculation.
4. **Given** the user is on the Selling Invoice Form, **When** they tap the FAB to add products, **Then** they navigate to the "Add Product to Invoice" page.
5. **Given** the user is on the "Add Product to Invoice" page, **When** they search for a product by barcode or name, **Then** matching products are displayed with name, price, and quantity counter.
6. **Given** the user is on the "Add Product to Invoice" page, **When** they adjust the quantity counter (increment/decrement or manual entry) and tap "Add to Invoice", **Then** the product with selected quantity is added to the invoice product list.
7. **Given** the user has added products to the invoice, **When** they view the invoice form, **Then** the total price and total price after discount are displayed correctly.
8. **Given** the user has completed the invoice form, **When** they confirm the invoice, **Then** the invoice is saved, product quantities are decreased in inventory, safe balance is increased, and the operation is recorded for future Operations feature.

---

### User Story 2 - Customer Search and Selection (Priority: P1)

As a store owner, I want to search for customers by name using a dropdown autocomplete menu when creating a selling invoice, so that I can quickly find and select the correct customer.

**Why this priority**: Essential for creating invoices - cannot complete a sale without a customer.

**Independent Test**: Open invoice form → tap customer dropdown → type customer name to filter → see filtered results in dropdown → select customer → customer name displayed on form.

**Acceptance Scenarios**:

1. **Given** the user is on the Selling Invoice Form, **When** they tap the customer dropdown field, **Then** a dropdown menu opens showing all customers.
2. **Given** the dropdown is open, **When** the user types in the search box within the dropdown, **Then** customers matching the name are filtered and displayed in the dropdown list.
3. **Given** filtered results are displayed in the dropdown, **When** the user taps a customer, **Then** that customer is selected, the dropdown closes, and the customer name is displayed on the form.
4. **Given** no customers match the search, **When** the user searches, **Then** an empty state message is shown within the dropdown.

---

### User Story 3 - Product Search and Quantity Selection (Priority: P1)

As a store owner, I want to search products by barcode or name, adjust quantities with a counter, and add them to the invoice, so that I can quickly build the product list for a sale.

**Why this priority**: Core workflow for adding line items to an invoice.

**Independent Test**: Open "Add Product to Invoice" page → search by barcode/name → see product cards with price and quantity counter → adjust quantity → tap "Add to Invoice" → return to invoice form with product added.

**Acceptance Scenarios**:

1. **Given** the user is on the "Add Product to Invoice" page, **When** they search by product barcode, **Then** the exact product match is displayed prominently.
2. **Given** the user is on the "Add Product to Invoice" page, **When** they search by product name, **Then** products matching the name are displayed in a list.
3. **Given** a product is displayed, **When** the user taps the increment/decrement buttons, **Then** the quantity counter updates accordingly (minimum 1).
4. **Given** a product is displayed, **When** the user manually types a quantity, **Then** the quantity updates to the entered value (minimum 1, maximum available stock).
5. **Given** a product with selected quantity, **When** the user taps "Add to Invoice", **Then** the product is added to the invoice with the selected quantity and the user returns to the invoice form.

---

### User Story 4 - Invoice Totals and Discount Calculation (Priority: P1)

As a store owner, I want to see the total price and the discounted total on the invoice form, so that I know the final amount before confirming.

**Why this priority**: Critical for verifying sale amounts before finalizing.

**Independent Test**: Add multiple products with quantities → verify subtotal = sum(price × quantity) → enter discount → verify total after discount = subtotal - discount.

**Acceptance Scenarios**:

1. **Given** products are added to the invoice, **When** the user views the form, **Then** the total price (sum of price × quantity for all products) is displayed.
2. **Given** a discount value is entered, **When** the user views the form, **Then** the total price after discount (total - discount) is displayed.
3. **Given** the discount exceeds the total price, **When** the user enters the discount, **Then** the total after discount shows 0 (or prevents discount > total).

---

### User Story 5 - Invoice Confirmation and Inventory/Safe Balance Update (Priority: P1)

As a store owner, I want to confirm the invoice and have it automatically update inventory and safe balance, so that my records stay accurate without manual adjustments.

**Why this priority**: Core business logic - selling decreases inventory and increases cash/safe balance.

**Independent Test**: Create invoice with products → confirm → verify each product quantity decreased in inventory → verify safe balance increased by total after discount → verify operation recorded.

**Acceptance Scenarios**:

1. **Given** a confirmed selling invoice, **When** the invoice is saved, **Then** each product's quantity in inventory is decreased by the sold quantity.
2. **Given** a confirmed selling invoice, **When** the invoice is saved, **Then** the safe balance is increased by the total price after discount.
3. **Given** a confirmed selling invoice, **When** the invoice is saved, **Then** the operation is recorded with type "sell" for future display in the Operations feature.
4. **Given** a product has insufficient stock, **When** the user tries to confirm the invoice, **Then** an error is shown and the invoice is not confirmed.

---

## Requirements

### Functional Requirements

- **FR-001**: System MUST allow creating a selling invoice with date (auto-set to current date), customer (1:1), products (1:many), and optional discount.
- **FR-002**: System MUST provide a "Add Invoice" (اضافة فاتورة) card on the Dashboard that navigates to the Selling Invoice Form.
- **FR-003**: System MUST allow searching and selecting a customer by name using a dropdown autocomplete menu on the invoice form (tap to open dropdown, type to filter, tap to select).
- **FR-004**: System MUST allow entering an optional discount amount on the invoice form.
- **FR-005**: System MUST display a Floating Action Button (FAB) on the invoice form to navigate to the "Add Product to Invoice" page.
- **FR-006**: System MUST provide an "Add Product to Invoice" page with search by product barcode or name.
- **FR-007**: System MUST display products in search results with name, sell price, and a quantity counter (increment/decrement buttons + manual input).
- **FR-008**: System MUST allow adding selected product with quantity to the invoice and return to the invoice form.
- **FR-009**: System MUST display the invoice product list on the form with each product's name, price, quantity, and line total.
- **FR-010**: System MUST display the total price (sum of line totals) and total price after discount on the invoice form.
- **FR-011**: System MUST validate that discount does not exceed total price.
- **FR-012**: System MUST confirm the invoice, which: (a) saves the SellInvoice entity, (b) decreases each product's quantity in inventory, (c) increases safe balance by total after discount, (d) records a SellOperation for the Operations feature.
- **FR-013**: System MUST prevent confirming an invoice if any product has insufficient stock.
- **FR-014**: System MUST use the existing ObjectBox entities: Product, Customer, SellInvoice, and create SellInvoiceItem (new entity for invoice line items).
- **FR-015**: System MUST follow existing architecture: BLoC pattern (SellInvoiceCubit), GetIt DI, AppRouter/AppNavigation, AppTheme/AppColors/AppTextStyles, AppTextField, AppButton, BlocBuilder with separate state body widgets.

### Key Entities

- **Customer**: Existing entity (id, name, phone, address, balance) - used for 1:1 relationship with SellInvoice.
- **Product**: Existing entity (id, name, barcode, quantity, buyPrice, sellPrice, supplierId) - inventory decreases on sell.
- **SellInvoice** (existing): id, customerId (ToOne<Customer>), date, total, paidAmount, discount. Need to add items relationship.
- **SellInvoiceItem** (NEW entity): id, sellInvoiceId (ToOne<SellInvoice>), productId (ToOne<Product>), quantity, unitPrice, lineTotal.
- **SellOperation** (NEW entity for Operations feature): id, sellInvoiceId, date, type (BalanceChangeType.sellInvoice), totalAmount, customerName.

---

## Success Criteria

### Measurable Outcomes

- **SC-001**: User can create a complete selling invoice in under 60 seconds (search customer, add 3+ products, apply discount, confirm).
- **SC-002**: After confirming an invoice, all product quantities are correctly decreased in inventory within 500ms.
- **SC-003**: Safe balance increases by the exact total-after-discount amount upon invoice confirmation.
- **SC-004**: Operations feature (future) will have a recorded "sell" operation for each confirmed invoice.
- **SC-005**: Zero data inconsistency - inventory quantity never goes negative, safe balance always matches sum of confirmed sell invoices minus buy invoices minus returns minus expenses.
- **SC-006**: User can search and find a customer by partial name match in under 2 seconds.
- **SC-007**: User can search products by barcode (exact match) or name (partial match) in under 2 seconds.

---

## Assumptions

- **Arabic-only locale**: The app uses Arabic (RTL) only, no localization needed beyond what's already configured.
- **Existing entities**: Product, Customer, SellInvoice entities exist in ObjectBox. SellInvoiceItem and SellOperation entities need to be created.
- **Existing architecture**: Uses BLoC (flutter_bloc), GetIt DI, custom AppRouter/AppNavigation, AppTheme with AppColors/AppTextStyles, flutter_screenutil for responsive sizing.
- **Localization constants**: All Arabic UI strings centralized in `lib/core/constants/app_strings.dart` (class `AppStrings`). Widgets reference `AppStrings.keyName`. No hardcoded strings in widgets (Constitution III).
- **Operations feature**: Not implemented yet - this feature only needs to record the operation data for future use.
- **Safe balance**: Already tracked in AppCubit or similar - selling invoice increases it.
- **Customer balance**: Not updated in this feature (only safe balance and inventory).
- **Discount**: Absolute amount (fixed currency value, not percentage), optional, cannot exceed subtotal. (Clarified: user confirmed absolute amount)
- **Currency precision**: All monetary values use `double` rounded to 2 decimal places (EGP piasters). Display formatted with Arabic locale currency.
- **Product quantity counter**: Minimum 1, maximum = current product quantity in inventory.
- **Date**: Auto-set to current date/time on invoice creation.
- **Navigation**: Use AppNavigation.pushName() for all navigation, never Navigator.of(context) directly.
- **Snackbars**: Use showSnackBar() from core/helper/functions.dart.
- **Widgets**: Extract all UI into separate widget classes per conventions (no inline builders or _build methods).

---

## Clarifications

### Session 2026-07-09

- Q: When a user adds a product already on the invoice, should the system merge quantities or show a warning? → A: Merge quantities - automatically increase the existing line item's quantity by the newly selected amount.

---

## Edge Cases

- What happens when customer search returns no results? → Show empty state with "No customers found" message in Arabic.
- What happens when product search returns no results? → Show empty state with "No products found" message in Arabic.
- What happens when user tries to add a product already in the invoice? → **Merge quantities** - automatically increase the existing line item's quantity by the newly selected amount.
- What happens when discount field is empty? → Treat as 0.
- What happens when discount > subtotal? → Cap discount at subtotal, show warning snackbar.
- What happens when product stock is 0? → Disable adding to invoice or show out-of-stock indicator.
- What happens when user navigates back from "Add Product" page without adding? → Return to invoice form without changes.
- What happens if user tries to confirm empty invoice (no products)? → Disable confirm button or show validation error.
- What happens if customer is not selected? → Disable confirm button or show validation error.
- What happens during concurrent sells of same product? → ObjectBox transactions handle this; verify stock at confirmation time.

---

## Technical Notes

### New Entities to Create (core/models/)

1. **SellInvoiceItem** - Links SellInvoice to Product with quantity and pricing
2. **SellOperation** - Records the sell operation for future Operations feature

### Localization Constants (core/constants/)

- **AppStrings** - Centralized Arabic UI strings in `lib/core/constants/app_strings.dart`

### New Cubits to Create (features/invoice/controller/cubit/)

- **SellInvoiceCubit** - Manages invoice creation state (loading, error, success)

### New Pages/Widgets (features/invoice/presentation/views/ + widgets/)

- **SellingInvoiceFormView** - Main form page (accessible from Dashboard card)
- **AddProductToInvoiceView** - Product search and selection page
- **Widgets**: CustomerAutocompleteDropdown, ProductSearchField, QuantityCounter, InvoiceProductList, InvoiceTotalsCard, InvoiceFormActions
- **State Body Widgets**: SellingInvoiceFormInitialBody, SellingInvoiceFormLoadedBody, SellingInvoiceFormErrorBody, SellingInvoiceFormValidationErrorBody, SellingInvoiceFormLoadingBody, AddProductToInvoiceInitialBody, AddProductToInvoiceLoadedBody, AddProductToInvoiceErrorBody, AddProductToInvoiceLoadingBody

### Routing (core/config/configrations.dart)

- Add route: AppRoutes.sellingInvoiceForm ('/selling-invoice-form')
- Add route: AppRoutes.addProductToInvoice ('/add-product-to-invoice')

### DI Registration (main.dart)

- Register SellInvoiceCubit as LazySingleton
- Register ObjectBox boxes for new entities

### ObjectBox Codegen

- Run `dart run build_runner build --delete-conflicting-outputs` after adding new entities.

---

## Dependencies

- Existing: flutter_bloc, objectbox, get_it, flutter_screenutil, persistent_bottom_nav_bar_v2
- No new external dependencies required.