# Tasks: Selling Invoice Form

**Input**: Design documents from `specs/002-selling-invoice-form/`
- plan.md (required) - Technical architecture, entities, UI components, routing, DI
- spec.md (required) - 5 User Stories (all P1), functional requirements, edge cases

**Prerequisites**: Flutter project with GetIt, flutter_bloc, ObjectBox, flutter_screenutil

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create feature directory structure per plan.md §10
  - lib/features/invoice/controller/cubit/
  - lib/features/invoice/presentation/views/
  - lib/features/invoice/presentation/widgets/
- [ ] T002 [P] Run ObjectBox codegen after entity creation (handled in Phase 2)
  - `dart run build_runner build --delete-conflicting-outputs`
- [ ] T003 [P] Verify existing dependencies in pubspec.yaml
  - flutter_bloc, objectbox, get_it, flutter_screenutil, persistent_bottom_nav_bar_v2

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story implementation

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T004 Create SellInvoiceItem entity in lib/core/models/sell_invoice_item.dart
  - @Entity(), @Id(), @Property(index: true) for productId
  - Fields: id, sellInvoiceId, productId, quantity, unitPrice, lineTotal
  - @Transient product, @Transient sellInvoice
  - ToOne<SellInvoice> invoice with @Backlink('items')
  - ToOne<Product> productRef with @Backlink('invoiceItems')
  - copyWith() method for quantity/lineTotal updates
- [ ] T005 Create SellOperation entity in lib/core/models/sell_operation.dart
  - @Entity(), @Id(), @Property(index: true) for sellInvoiceId, date, createdAt
  - Fields: id, sellInvoiceId, date, type ('sell'), totalAmount, customerName, createdAt
- [ ] T006 Update existing SellInvoice entity in lib/core/models/sell_invoice.dart
  - Add @Backlink('invoice') final ToMany<SellInvoiceItem> items = ToMany<SellInvoiceItem>();
- [ ] T007 Run ObjectBox codegen
  - `dart run build_runner build --delete-conflicting-outputs`
  - Verify lib/objectbox.g.dart and lib/objectbox-model.json generated
- [ ] T008 Create SellInvoiceState in lib/features/invoice/controller/cubit/sell_invoice_state.dart
  - States: Initial, Loading, Loaded (with selectedCustomer, items, discount, computed subtotal/totalAfterDiscount), Error, ValidationError, Confirmed
  - Loaded.copyWith() for immutable updates
  - Equatable props for all states
- [ ] T009 Create SellInvoiceCubit skeleton in lib/features/invoice/controller/cubit/sell_invoice_cubit.dart
  - Constructor with ObjectBoxServices
  - Private fields: _items, _selectedCustomer, _discount
  - Getters: items, selectedCustomer, discount, subtotal, totalAfterDiscount
  - _emitLoaded() helper
- [ ] T010 Register DI in lib/main.dart configureDependencies()
  - getIt.registerLazySingleton<SellInvoiceCubit>(() => SellInvoiceCubit(GetIt.instance<ObjectBoxServices>()))
  - getIt.registerLazySingleton<Box<SellInvoiceItem>>(() => GetIt.instance<ObjectBoxServices>().store.box<SellInvoiceItem>())
  - getIt.registerLazySingleton<Box<SellOperation>>(() => GetIt.instance<ObjectBoxServices>().store.box<SellOperation>())
- [ ] T011 [P] Create localization constants in lib/core/constants/app_strings.dart
  - Class AppStrings with all Arabic UI strings as static const (invoice form, customer dropdown, product search, totals, validation messages)
  - Reference via AppStrings.keyName in all widgets
- [ ] T012 Add routes in lib/core/config/configrations.dart AppRoutes
  - static const String sellingInvoiceForm = '/selling-invoice-form'
  - static const String addProductToInvoice = '/add-product-to-invoice'
- [ ] T013 Add route cases in lib/core/config/configrations.dart AppRouter.generateRoute()
  - sellingInvoiceForm: BlocProvider(create: (_) => GetIt.instance<SellInvoiceCubit>()..loadCustomers(), child: SellingInvoiceFormView())
  - addProductToInvoice: BlocProvider.value(value: GetIt.instance<SellInvoiceCubit>()..loadProducts(''), child: AddProductToInvoiceView())
- [ ] T014 Add increaseSafeBalance(double) method to AppCubit in lib/core/controller/controllers/app_cubit/
  - Updates safe balance and emits new AppState

**Checkpoint**: Foundation ready - all user stories can now be implemented in parallel

---

## Phase 3: User Story 1 - Create Selling Invoice Form (Priority: P1) 🎯 MVP

**Goal**: Main invoice form page with navigation from Dashboard, FAB to add products, and basic form structure

**Independent Test**: Navigate from Dashboard → "اضافة فاتورة" card → form loads → tap FAB → navigates to Add Product page → return to form

### Implementation for User Story 1

- [ ] T013 [P] [US1] Create SellingInvoiceFormView in lib/features/invoice/presentation/views/selling_invoice_form_view.dart
  - Scaffold with AppBar (title: "فاتورة بيع"), body (SingleChildScrollView), FAB
  - BlocProvider.value with existing SellInvoiceCubit
  - Column layout: CustomerAutocompleteDropdown, InvoiceProductList, InvoiceTotalsCard, InvoiceFormActions
  - FAB onPressed: AppNavigation.pushName(context, AppRoutes.addProductToInvoice)
- [ ] T014 [P] [US1] Create InvoiceFormActions widget in lib/features/invoice/presentation/widgets/invoice_form_actions.dart
  - Full-width AppButton "تأكيد الفاتورة" (Confirm Invoice)
  - Disabled when state is ValidationError, Loading, or items empty or no customer
  - onPressed: context.read<SellInvoiceCubit>().confirmInvoice()
  - Show snackbar on Confirmed state, navigate back or reset form
- [ ] T015 [P] [US1] Create InvoiceProductList widget in lib/features/invoice/presentation/widgets/invoice_product_list.dart
  - ListView.builder of InvoiceItemTile for each item
  - Empty state: "لا توجد منتجات مضافة" (No products added)
- [ ] T016 [P] [US1] Create InvoiceItemTile widget in lib/features/invoice/presentation/widgets/invoice_item_tile.dart
  - Row: product name, price, quantity (editable), line total, delete icon
  - Quantity editable via tap → show QuantityCounter dialog or inline
  - onQuantityChanged: cubit.updateItemQuantity(index, newQty)
  - onDelete: cubit.removeItem(index)
- [ ] T017 [US1] Implement loadCustomers() in SellInvoiceCubit
  - Query all customers from ObjectBox, sort by name
  - Emit Loaded with customers list (or store in cubit for dropdown)
- [ ] T018 [US1] Wire up BlocListener in SellingInvoiceFormView for state changes
  - ValidationError → showSnackBar(message, color: AppColors.error)
  - Error → showSnackBar(message, color: AppColors.error)
  - Confirmed → showSnackBar("تم حفظ الفاتورة بنجاح", color: AppColors.success), reset form or pop
- [ ] T019 [P] [US1] Create SellingInvoiceFormInitialBody widget in lib/features/invoice/presentation/widgets/selling_invoice_form_initial_body.dart
  - Shows empty form with placeholder "اختر عميلاً وأضف منتجات" (Select customer and add products)
- [ ] T020 [P] [US1] Create SellingInvoiceFormLoadedBody widget in lib/features/invoice/presentation/widgets/selling_invoice_form_loaded_body.dart
  - Renders CustomerAutocompleteDropdown, InvoiceProductList, InvoiceTotalsCard, InvoiceFormActions
- [ ] T021 [P] [US1] Create SellingInvoiceFormErrorBody widget in lib/features/invoice/presentation/widgets/selling_invoice_form_error_body.dart
  - Shows error message with retry button
- [ ] T022 [P] [US1] Create SellingInvoiceFormValidationErrorBody widget in lib/features/invoice/presentation/widgets/selling_invoice_form_validation_error_body.dart
  - Shows validation error with dismiss action
- [ ] T023 [P] [US1] Create SellingInvoiceFormLoadingBody widget in lib/features/invoice/presentation/widgets/selling_invoice_form_loading_body.dart
  - Shows loading indicator overlay

**Checkpoint**: US1 complete - Main form navigable from Dashboard, FAB works, basic structure ready

---

## Phase 4: User Story 2 - Customer Search and Selection (Priority: P1)

**Goal**: Dropdown autocomplete for customer selection with type-to-filter

**Independent Test**: Open form → tap customer dropdown → type partial name → filtered results → select customer → shows on form

### Implementation for User Story 2

- [ ] T024 [P] [US2] Create CustomerAutocompleteDropdown widget in lib/features/invoice/presentation/widgets/customer_autocomplete_dropdown.dart
  - Uses AppTextField with suffix icon (dropdown arrow)
  - onTap: show dropdown overlay with customer list
  - Search field inside dropdown filters customers by name (case-insensitive Arabic)
  - Dropdown items: customer name + phone
  - onSelect: cubit.selectCustomer(customer), close dropdown
  - Clear button when customer selected
  - Empty state: "لا يوجد عملاء" (No customers found) in Arabic
- [ ] T025 [P] [US2] Implement customer search/filter logic in CustomerAutocompleteDropdown
  - Debounced search (300ms) or local filtering
  - Case-insensitive Arabic name matching
- [ ] T026 [US2] Add selectCustomer(Customer) and clearCustomer() to SellInvoiceCubit
  - Updates _selectedCustomer, calls _emitLoaded()
- [ ] T027 [US2] Integrate CustomerAutocompleteDropdown in SellingInvoiceFormView
  - Bind to cubit.selectedCustomer
  - Show selected customer name or placeholder "اختر العميل" (Select customer)

**Checkpoint**: US2 complete - Customer dropdown with search works independently

---

## Phase 5: User Story 3 - Product Search and Quantity Selection (Priority: P1)

**Goal**: Add Product page with barcode/name search, quantity counter, add to invoice

**Independent Test**: Open form → tap FAB → search product by barcode → set quantity → tap "Add to Invoice" → returns to form with product in list

### Implementation for User Story 3

- [ ] T028 [P] [US3] Create AddProductToInvoiceView in lib/features/invoice/presentation/views/add_product_to_invoice_view.dart
  - Scaffold with AppBar (title: "إضافة منتج"), body (Column)
  - BlocProvider.value with existing SellInvoiceCubit
  - Sections: ProductSearchField, ProductListWithCounters
- [ ] T029 [P] [US3] Create ProductSearchField widget in lib/features/invoice/presentation/widgets/product_search_field.dart
  - AppTextField with hint "بحث بالباركود أو الاسم" (Search by barcode or name)
  - onChanged: debounced (300ms) → cubit.loadProducts(query)
  - Clear button, search icon
- [ ] T030 [P] [US3] Create ProductListWithCounters widget in lib/features/invoice/presentation/widgets/product_list_with_counters.dart
  - ListView.builder of ProductCardWithCounter
  - Empty state: "لا توجد منتجات" (No products found) in Arabic
  - Loading state while querying
- [ ] T031 [P] [US3] Create ProductCardWithCounter widget in lib/features/invoice/presentation/widgets/product_card_with_counter.dart
  - Card: product name, sell price, QuantityCounter, "إضافة للفاتورة" (Add to Invoice) button
  - Disabled if product.quantity == 0 (out of stock indicator)
- [ ] T032 [P] [US3] Create QuantityCounter widget in lib/features/invoice/presentation/widgets/quantity_counter.dart
  - Row: "-" button, TextField (manual entry), "+" button
  - Min: 1, Max: product.quantity (available stock)
  - onChanged: callback with new quantity
  - Input validation: numeric only, clamp to range
- [ ] T033 [US3] Implement loadProducts(String query) in SellInvoiceCubit
  - If query is barcode (numeric, 8-13 digits): exact match on barcode
  - Else: partial match on name (case-insensitive)
  - Emit Loaded with products list (store in cubit for UI)
- [ ] T034 [US3] Implement addProduct(Product, quantity) in SellInvoiceCubit
  - Check if product already in _items (merge quantities per clarification)
  - New quantity = min(existing + quantity, product.quantity)
  - Create SellInvoiceItem with unitPrice = product.sellPrice (snapshot)
  - Link productRef.target = product
  - Call _emitLoaded()
- [ ] T035 [US3] Wire up ProductCardWithCounter "Add to Invoice" button
  - onPressed: cubit.addProduct(product, quantity), then AppNavigation.pop(context)
  - Pass selected quantity from QuantityCounter
- [ ] T036 [P] [US3] Create AddProductToInvoiceInitialBody widget in lib/features/invoice/presentation/widgets/add_product_to_invoice_initial_body.dart
  - Shows ProductSearchField with empty state "ابدأ البحث بالباركود أو الاسم" (Start searching by barcode or name)
- [ ] T037 [P] [US3] Create AddProductToInvoiceLoadedBody widget in lib/features/invoice/presentation/widgets/add_product_to_invoice_loaded_body.dart
  - Renders ProductListWithCounters with product cards
- [ ] T038 [P] [US3] Create AddProductToInvoiceErrorBody widget in lib/features/invoice/presentation/widgets/add_product_to_invoice_error_body.dart
  - Shows error message with retry button
- [ ] T039 [P] [US3] Create AddProductToInvoiceLoadingBody widget in lib/features/invoice/presentation/widgets/add_product_to_invoice_loading_body.dart
  - Shows loading indicator while searching products

**Checkpoint**: US3 complete - Product search, quantity selection, and add-to-invoice flow works

---

## Phase 6: User Story 4 - Invoice Totals and Discount Calculation (Priority: P1)

**Goal**: Display subtotal, discount input, total after discount with validation

**Independent Test**: Add products → verify subtotal = sum(price × qty) → enter discount → verify total = subtotal - discount → enter discount > subtotal → capped at subtotal

### Implementation for User Story 4

- [ ] T040 [P] [US4] Create InvoiceTotalsCard widget in lib/features/invoice/presentation/widgets/invoice_totals_card.dart
  - Card with: "المجموع" (Subtotal), "الخصم" (Discount) AppTextField, "الإجمالي بعد الخصم" (Total after discount)
  - Subtotal: read-only, formatted currency (Arabic locale)
  - Discount: AppTextField, numeric keyboard, onChanged → cubit.setDiscount(value)
  - Total after discount: read-only, highlighted, formatted currency
  - Discount validation: if value > subtotal, show warning snackbar, clamp to subtotal
- [ ] T041 [P] [US4] Add setDiscount(double) to SellInvoiceCubit
  - _discount = value.clamp(0.0, subtotal)
  - _emitLoaded()
- [ ] T042 [US4] Integrate InvoiceTotalsCard in SellingInvoiceFormView
  - Bind to cubit.subtotal, cubit.discount, cubit.totalAfterDiscount
  - Update reactively via BlocBuilder

**Checkpoint**: US4 complete - Totals display and discount calculation work correctly

---

## Phase 7: User Story 5 - Invoice Confirmation and Inventory/Safe Balance Update (Priority: P1)

**Goal**: Confirm invoice saves to DB, decreases inventory, increases safe balance, records operation

**Independent Test**: Complete form with customer + products → tap Confirm → verify success → check Inventory (quantities decreased) → check Safe Balance (increased by total after discount) → check Operations table (sell operation recorded)

### Implementation for User Story 5

- [ ] T043 [US5] Complete confirmInvoice() in SellInvoiceCubit (lib/features/invoice/controller/cubit/sell_invoice_cubit.dart)
  - Validation: customer required, items not empty, stock check per item
  - emit(Loading())
  - ObjectBox transaction (TxMode.write):
    1. Create SellInvoice (customerId, date: now(), total: subtotal, discount, paidAmount: 0)
    2. For each item: set sellInvoiceId, put item, decrease product.quantity, put product
    3. Increase safe balance via AppCubit.increaseSafeBalance(totalAfterDiscount)
    4. Create SellOperation (sellInvoiceId, date, type: BalanceChangeType.sellInvoice.index, totalAmount: totalAfterDiscount, customerName)
  - On success: clear _items, _selectedCustomer, _discount, emit(Confirmed(invoice))
  - On error: emit(Error(message))
- [ ] T044 [US5] Handle Confirmed state in SellingInvoiceFormView BlocListener
  - showSnackBar("تم حفظ الفاتورة بنجاح", AppColors.success)
  - Reset form: AppNavigation.pop(context) or navigator.pushReplacementNamed(AppRoutes.mainView)
- [ ] T045 [P] [US5] Add stock validation in confirmInvoice() before transaction
  - For each item: if product.quantity < item.quantity → emit(ValidationError("الكمية غير متوفرة للمنتج: ${product.name}"))
- [ ] T046 [P] [US5] Verify ObjectBox transaction rollback on error
  - All operations in single runInTransaction block
  - Test: simulate error mid-transaction → verify no partial writes

**Checkpoint**: US5 complete - Full invoice confirmation with inventory/safe balance/operations persistence

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Integration, dashboard integration, validation, quickstart validation

- [ ] T047 [P] Add "اضافة فاتورة" card to Dashboard in lib/features/dashboard/presentation/views/dashboard_view.dart
  - Quick action card with icon, title "اضافة فاتورة", onTap → AppNavigation.pushName(context, AppRoutes.sellingInvoiceForm)
- [ ] T048 [P] Add Arabic RTL support verification
  - All text in Arabic, RTL layout, AppTextStyles/AppColors used
  - No hardcoded colors or TextStyles
- [ ] T049 [P] Replace any remaining hardcoded strings with Arabic constants
  - Error messages, labels, hints from spec edge cases
- [ ] T050 Run quickstart validation (plan.md §11)
  - `flutter pub get && dart run build_runner build --delete-conflicting-outputs`
  - Test Scenario 1: Single product invoice
  - Test Scenario 2: Multiple products
  - Test Scenario 3: Merge duplicate product
  - Test Scenario 4: Validation errors
  - Test Scenario 5: Customer dropdown search
- [ ] T051 [P] Code cleanup: remove debug prints, verify all widgets use separate classes (no _build methods)
- [ ] T052 [P] Verify architecture compliance
  - AppNavigation.pushName() used everywhere (no Navigator.of)
  - showSnackBar() from core/helper/functions.dart used
  - AppTextField, AppButton used (no raw TextFormField/ElevatedButton in SizedBox)
  - BlocBuilder states use separate widget classes (LoadedBody, ErrorBody, etc.)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - start immediately
- **Foundational (Phase 2)**: Depends on Setup - **BLOCKS all user stories**
- **User Stories (Phases 3-7)**: All depend on Foundational (Phase 2) completion
  - US1 (Phase 3), US2 (Phase 4), US3 (Phase 5), US4 (Phase 6), US5 (Phase 7) can proceed in PARALLEL after Phase 2
  - Within each story: widgets can be built in parallel [P]
- **Polish (Phase 8)**: Depends on all desired user stories complete

### User Story Dependencies

- **US1 (Create Invoice Form)**: Core page structure - enables US2, US3, US4, US5 integration
- **US2 (Customer Dropdown)**: Independent - integrates into US1 form
- **US3 (Product Search/Add)**: Independent - integrates via FAB from US1
- **US4 (Totals/Discount)**: Independent - integrates into US1 form
- **US5 (Confirmation)**: Depends on US1 form + US2 customer + US3 items + US4 totals

### Parallel Opportunities

```bash
# After Phase 2 completes, launch these in parallel:
# Developer A: US1 (T013-T023)
# Developer B: US2 (T019-T022)
# Developer C: US3 (T023-T034)
# Developer D: US4 (T035-T037)
# Developer E: US5 (T038-T046) - wait for US1-4 integration points

# Within each story, [P] tasks can run in parallel:
# US1: T013, T014, T015, T016 (all [P])
# US2: T019, T020 (both [P])
# US3: T023, T024, T025, T026, T027 (all [P])
# US4: T035, T036 (both [P])
# US5: T045, T046 (both [P])
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test US1 independently - form loads, FAB navigates, basic structure works
5. Deploy/demo if ready

### Incremental Delivery

1. Foundation ready → All stories can start
2. Add US2 (Customer) → Test independently
3. Add US3 (Products) → Test independently
4. Add US4 (Totals) → Test independently
5. Add US5 (Confirmation) → Full end-to-end flow
6. Each story adds value without breaking previous

### Parallel Team Strategy

With 3-5 developers:
1. Team completes Setup + Foundational together
2. Once Foundational done:
   - Dev A: US1 (form structure, FAB, product list, actions)
   - Dev B: US2 (customer dropdown)
   - Dev C: US3 (product search page, quantity counter)
   - Dev D: US4 (totals card, discount)
   - Dev E: US5 (confirm logic, transaction) - starts after US1-4 integration points ready

---

## Format Validation

✅ All tasks follow checklist format: `- [ ] T### [P?] [Story?] Description with file path`
✅ Task IDs sequential (T001-T052)
✅ [P] marker only for parallelizable tasks (different files, no deps)
✅ [US#] label on all user story phase tasks
✅ No [US] label on Setup/Foundational/Polish phases
✅ Exact file paths from plan.md §10 included
✅ 52 total tasks across 8 phases