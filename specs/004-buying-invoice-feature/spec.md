# Buying Invoice Feature Specification

## Feature Overview
**Short Name**: buying-invoice-feature

Enable users to create buying invoices when purchasing products from suppliers. This feature mirrors the selling invoice functionality but for purchases: inventory increases and safe balance decreases. Includes supplier selection, adding products from a searchable list (with FAB to add new product), and restocking existing products with price change handling.

## User Scenarios & Testing

### Primary User Flow: Create Buying Invoice
1. User opens the app and accesses the side drawer
2. User taps "فواتير المشتريات" (Buying Invoices) drawer item
3. User is navigated to the Buying Invoice form page
4. User selects a supplier from the dropdown (searchable, like CustomerDropdownMenu)
5. User taps FAB to open product selection view (similar to AddProductToInvoiceView)
   - Product list shows all existing products with search
   - User taps a product to add it to invoice with quantity 0
   - User can edit quantity inline (via quantity counter)
   - FAB in product selection view opens ProductFormView to add new product
   - After creating new product, returns to product selection with new product added
6. User reviews invoice items and totals
7. User taps "Confirm Invoice" to save
8. System validates: supplier selected, at least one item with quantity > 0 added
9. System creates buying invoice, increases product quantities in inventory, decreases safe balance
10. Success message shown, form resets

### Alternative Flow: Restock with Price Change
1. User selects existing product from product list
2. If the product's current buying price differs from the price in the invoice item
3. System shows dialog: "Price has changed. Update product buying price to new value?"
4. If user confirms: product's buying price in inventory is updated to new price
5. If user cancels: product is added with original buying price (no price update)

### Error Scenarios
- No supplier selected → show error "Please select a supplier"
- No items with quantity > 0 in invoice → show error "Please add at least one product with quantity"
- Insufficient safe balance → show error "Insufficient safe balance"

## Functional Requirements

### FR-001: Buying Invoice Data Model
The system shall support a Buying Invoice entity with:
- Date (DateTime)
- Supplier (one-to-one relationship with SupplierModel)
- Items (one-to-many relationship with InvoiceItemModel - existing model)
- Total amount (calculated from items)
- Paid amount (partial payment support)

### FR-002: Buying Invoice Item Data Model
Each invoice item shall use the existing **InvoiceItemModel** (from lib/core/models/invoice_item_model.dart) with:
- Product (reference to ProductModel)
- Quantity (integer, default 0)
- Unit buying price (decimal)
- Line total (quantity × unit price)

### FR-003: Supplier Selection Widget
The system shall provide a SupplierDropdownMenu widget (mirroring CustomerDropdownMenu) that:
- Displays searchable dropdown of all suppliers
- Shows supplier name with store name and phone
- Allows selection via tap or text search with Arabic normalization
- Updates the buying invoice cubit with selected supplier
- Clears selection on unmatched text input

### FR-004: Buying Invoice Form Page
The system shall provide a BuyingInvoiceView page with:
- App bar titled "فاتورة شراء" (Buying Invoice)
- Supplier dropdown at top
- List of invoice items (products with quantities and prices) using quantity counter for editing
- Invoice totals card showing subtotal and total
- Single FAB to open product selection view (like AddProductToInvoiceView)
- Confirm button at bottom

### FR-005: Product Selection Flow
When user taps FAB to open product selection view:
- Navigate to product search/list view (similar to AddProductToInvoiceView)
- Shows all products with search by name/barcode
- Each product shows quantity counter (default 0, user increments to add)
- FAB in product selection view opens ProductFormView to add new product
- After creating new product, returns to product selection with new product in list
- When user returns from product selection, selected products with quantity > 0 are added to invoice

### FR-006: Restock Existing Product with Price Change
When adding an existing product to invoice:
- If the invoice item's unit price differs from product's current buying price
- Show confirmation dialog: "Price changed. Update product buying price to new value?"
- If confirmed: update product's buying price in inventory to new value
- If cancelled: use product's current buying price (no update)

### FR-007: Business Logic - Inventory & Safe Balance
Upon confirming a buying invoice:
- For each item with quantity > 0: increase product quantity in inventory by item quantity
- Decrease safe balance by invoice total amount
- Create buying invoice record with all items
- Create balance audit entry for the safe balance decrease

### FR-008: Navigation - Drawer Item
The main view drawer shall include a "فواتير المشتريات" (Buying Invoices) item that:
- Navigates to the buying invoice list/history page (placeholder for now)
- Uses AppNavigation.pushName with route AppRoutes.buyInvoices

### FR-009: Navigation - Buying Invoice Form Route
The system shall define a route AppRoutes.buyingInvoiceView that:
- Opens the BuyingInvoiceView wrapped in BuyInvoiceCubit provider
- Initializes cubit by loading suppliers
- Returns to previous screen on successful confirmation

### FR-010: State Management - BuyInvoiceCubit
The system shall provide a BuyInvoiceCubit (mirroring SellInvoiceCubit) **with interface BuyInvoiceCubitInterface** with:
- State management for: loading, error, success, items list, selected supplier, products list, discount
- Methods: loadSuppliers(), loadProducts(search), selectSupplier(), clearSupplier(), addProductItem(), updateItemQuantity(), removeItem(), validateInvoice(), confirmInvoice()
- Getters for: items, selectedSupplier, suppliers, products, subtotal, totalAfterDiscount

### FR-011: Repository & Data Access
The system shall provide BuyInvoiceRepository interface and implementation for:
- Creating buying invoices with items
- Querying buying invoices (for future history view)
- Interacting with ObjectBox for persistence

## Key Entities

### BuyingInvoiceModel
Represents a purchase invoice from a supplier.
- id (auto-generated)
- date (DateTime)
- supplier (ToOne<SupplierModel>)
- items (ToMany<InvoiceItemModel>) - uses existing InvoiceItemModel
- discount (double, optional)
- paidAmount (double, default 0)
- total (computed from items minus discount)

### InvoiceItemModel (existing - lib/core/models/invoice_item_model.dart)
Represents a line item in an invoice (shared with selling invoices).
- id (auto-generated)
- product (ToOne<ProductModel>)
- quantity (int, default 0)
- unitPrice (double) - buying price at time of purchase
- lineTotal (double) - quantity × unitPrice
- invoice (ToOne<BuyingInvoiceModel> - backlink)

### SupplierModel (existing)
- id, name, storeName, storeAdd, phoneNum
- Used for supplier selection in dropdown

### ProductModel (existing)
- id, name, barcode, quantity, buyingPrice, sellingPrice, wholesalePrice, imgPath
- Quantity increases on buying invoice confirmation
- BuyingPrice can be updated during restock with price change confirmation

## Success Criteria

### Measurable Outcomes
- **SC-001**: User can create a buying invoice with supplier and at least one item in under 2 minutes
- **SC-002**: Inventory quantities increase correctly for all items on invoice confirmation
- **SC-003**: Safe balance decreases by exact invoice total on confirmation
- **SC-004**: Price change dialog appears when adding existing product with different buying price
- **SC-005**: Product buying price updates in inventory when user confirms price change during restock
- **SC-006**: Supplier dropdown loads and searches all suppliers within 500ms
- **SC-007**: Form validation prevents submission without supplier or items with quantity > 0

### Qualitative Outcomes
- User experience mirrors selling invoice flow for consistency
- Arabic RTL layout with proper text direction
- Clear visual feedback for price changes during restock
- Responsive design using screenutil

## Assumptions

1. **Existing Infrastructure**: ObjectBox database, GetIt DI, flutter_bloc, AppNavigation, AppRouter, AppTheme, AppColors, AppTextStyle already configured per AGENTS.md
2. **Supplier Management**: Suppliers CRUD already exists (SupplierCubit, SupplierFormView, AllSuppliersView)
3. **Product Management**: Products CRUD already exists (ProductCubit, ProductFormView, InventoryView)
4. **Safe Balance**: SafeCubit and safe balance tracking already implemented
5. **Navigation Pattern**: Custom AppRouter + AppNavigation (not go_router) as per AGENTS.md
6. **Widget Standards**: Must use AppButton, AppTextField, AppDropdownMenu patterns; no raw widgets
7. **Theme**: Use AppTheme component themes; no hardcoded colors/styles
8. **Localization**: Arabic only (Locale('ar')), RTL layout
9. **Drawer Route**: AppRoutes.buyInvoices already defined but points to placeholder

## Dependencies

- **flutter_bloc** ^9.1.1 (existing)
- **objectbox** ^5.3.2 (existing)
- **get_it** ^9.2.1 (existing)
- **flutter_screenutil** ^5.9.3 (existing)
- **persistent_bottom_nav_bar_v2** ^6.3.2 (existing)
- No new external dependencies required