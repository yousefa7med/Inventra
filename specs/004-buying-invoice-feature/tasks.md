---
description: "Task list for Buying Invoice Feature implementation"
---

# Tasks: Buying Invoice Feature

**Input**: Design documents from `/specs/004-buying-invoice-feature/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: OPTIONAL - only include if explicitly requested

**Organization**: Tasks grouped by user story for independent implementation and testing

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: User story label (US1, US2, US3)
- Exact file paths required in descriptions

## Path Conventions

- **Mobile (Flutter)**: `lib/` at repository root
- Paths shown below follow plan.md project structure

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Ensure Flutter project dependencies are up to date (`flutter pub get`)
- [ ] T002 Verify ObjectBox codegen works (`dart run build_runner build --delete-conflicting-outputs`)
- [ ] T003 [P] Verify flutter analyze passes on current codebase (`flutter analyze`)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T004 [P] Create `BuyingInvoiceModel` entity in `lib/core/models/buying_invoice_model.dart` with fields: id, date, supplier (ToOne), items (ToMany<InvoiceItemModel>), paidAmount (default 0), total (computed)
- [ ] T005 [P] Update `InvoiceItemModel` in `lib/core/models/invoice_item_model.dart` - add `ToOne<BuyingInvoiceModel> invoice` backlink for buying invoices
- [ ] T006 Run ObjectBox codegen after model changes (`dart run build_runner build --delete-conflicting-outputs`)
- [ ] T007 Add `AppRoutes.buyingInvoiceView = '/buying-invoice'` constant in `lib/core/config/configrations.dart`
- [ ] T008 Add route case for `buyingInvoiceView` in `AppRouter.generateRoute()` in `lib/core/config/configrations.dart` - wraps `BuyingInvoiceView` with `BlocProvider.value(BuyInvoiceCubit()..loadSuppliers())`
- [ ] T009 Register `BuyInvoiceCubit` as `LazySingleton` in `GetIt` in `lib/main.dart` `configureDependencies()`
- [ ] T010 Update `AppDrawer` in `lib/core/widgets/app_drawer.dart` - change "فواتير المشتريات" drawer item to navigate to `AppRoutes.buyingInvoiceView` instead of `AppRoutes.buyInvoices`

**Checkpoint**: Foundation ready - models, routes, DI configured. User story implementation can begin.

---

## Phase 3: User Story 1 - Create Buying Invoice (Priority: P1) 🎯 MVP

**Goal**: Enable user to create a buying invoice with supplier selection, product selection (existing + new), quantity management, and confirmation with inventory/safe balance updates

**Independent Test**: 
1. Open app → drawer → "فواتير المشتريات" → BuyingInvoiceView loads
2. Select supplier from dropdown (Arabic search works)
3. Tap FAB → ProductSelectionView opens with products list
4. Search products by name/barcode, increment quantity counters (default 0)
5. Tap FAB in ProductSelectionView → ProductFormView opens → create new product → returns to ProductSelectionView
6. Return from ProductSelectionView → items with qty > 0 appear in BuyingInvoiceView
7. Tap "تأكيد الفاتورة" → success snackbar, form resets
8. Verify Inventory: product quantities increased
9. Verify Safe (خزنة): balance decreased by invoice total

### Implementation for User Story 1

#### Models & Repository Layer
- [ ] T011 [P] [US1] Create `BuyInvoiceRepository` interface in `lib/features/buying_invoice/data/repositories/buy_invoice_repository.dart` per contract
- [ ] T012 [P] [US1] Create `BuyInvoiceRepositoryImpl` in `lib/features/buying_invoice/data/repositories/buy_invoice_repository_impl.dart` implementing `createBuyInvoice`, `getAllSuppliers`, `getAllProducts`, `searchProducts`, `watchInvoices`, `getAllBuyInvoices`, `getBuyInvoiceById`, `addItem`
- [ ] T013 [US1] Implement `createBuyInvoice` business logic: validate items, calculate totals, ObjectBox transaction, update product quantities, decrease safe balance, create audit entry, return saved invoice

#### State Management (Cubit)
- [ ] T014 [P] [US1] Create `BuyInvoiceCubitInterface` in `lib/features/buying_invoice/controller/cubit/buy_invoice_cubit_interface.dart` per contract
- [ ] T015 [P] [US1] Create `BuyInvoiceState` states in `lib/features/buying_invoice/controller/cubit/buy_invoice_state.dart` (mirroring SellInvoiceState): Initial, Loading, SuppliersLoaded, ProductsLoaded, ProductLoading, AddProduct, UpdateProductQuantity, RemoveProduct, Confirmed, Error
- [ ] T016 [US1] Create `BuyInvoiceCubit` in `lib/features/buying_invoice/controller/cubit/buy_invoice_cubit.dart` implementing interface with internal state (_items, _selectedSupplier, _suppliers, _products) and all methods: loadSuppliers, loadProducts, selectSupplier, clearSupplier, addProductItem, updateItemQuantity, removeItem, validateBuyInvoice, confirmInvoice

#### Supplier Dropdown Widget
- [ ] T017 [P] [US1] Create `SupplierDropdownMenu` widget in `lib/features/buying_invoice/presentation/widgets/supplier_dropdown_menu.dart` mirroring `CustomerDropdownMenu` pattern: DropdownMenu<SupplierModel>, Arabic normalization, displays name + storeName + phoneNum, calls cubit.selectSupplier()

#### Product Selection View
- [ ] T018 [P] [US1] Create `ProductSelectionView` in `lib/features/buying_invoice/presentation/views/product_selection_view.dart` with: SearchField (by name/barcode), ProductListWithCountersSliver (reuse from selling_invoice), quantity counter default 0, FAB opens ProductFormView
- [ ] T019 [US1] Implement product selection flow: when returning from ProductSelectionView, add products with qty > 0 to BuyInvoiceCubit via addProductItem()

#### Buying Invoice Form View (Main)
- [ ] T020 [P] [US1] Create `BuyingInvoiceView` in `lib/features/buying_invoice/presentation/views/buying_invoice_view.dart` with: CustomAppBar "فاتورة شراء", SupplierDropdownMenu, InvoiceProductList (items with quantity counters), InvoiceTotalsCard (subtotal/total), Confirm Button "تأكيد الفاتورة", FAB to open ProductSelectionView
- [ ] T021 [P] [US1] Create `InvoiceItemTile` widget in `lib/features/buying_invoice/presentation/widgets/invoice_item_tile.dart` for displaying invoice items with quantity counter (reuse/adapt from selling_invoice)
- [ ] T022 [P] [US1] Create `InvoiceProductList` widget in `lib/features/buying_invoice/presentation/widgets/invoice_product_list.dart` - list of invoice items using InvoiceItemTile
- [ ] T023 [P] [US1] Create `InvoiceTotalsCard` widget in `lib/features/buying_invoice/presentation/widgets/invoice_totals_card.dart` showing subtotal and total

#### Integration & Validation
- [ ] T024 [US1] Wire BlocListener in BuyingInvoiceView for BuyInvoiceError (showSnackBar) and BuyInvoiceConfirmed (showSnackBar "تم اضافة الفاتورة بنجاح", pop navigation)
- [ ] T025 [US1] Implement safe balance check in `validateBuyInvoice()` / `confirmInvoice()` - emit error if insufficient balance
- [ ] T026 [US1] Run flutter analyze, flutter test, flutter build apk --debug

**Checkpoint**: User Story 1 complete - core buying invoice creation works independently

---

## Phase 4: User Story 2 - Price Change Dialog for Restocking (Priority: P2)

**Goal**: Show confirmation dialog when adding existing product with different buying price; allow updating product's buying price in inventory

**Independent Test**:
1. Start buying invoice, select supplier
2. Open ProductSelectionView, find existing product (e.g., buyingPrice=10)
3. Increment quantity counter from 0 to >0
4. If unit price differs from product.buyingPrice → dialog appears: "السعر تغير. تحديث سعر الشراء للمنتج؟" with both prices
5. Tap "تحديث السعر" → product.buyingPrice updated in inventory before adding to invoice
6. Complete invoice → verify product buyingPrice changed in Inventory
7. Alternative: Tap "الاحتفاظ بالسعر الحالي" → product keeps original price

### Implementation for User Story 2

- [ ] T027 [P] [US2] Create `PriceChangeDialog` widget in `lib/features/buying_invoice/presentation/widgets/price_change_dialog.dart` (or `core/widgets/`) with: title "تغير السعر", message showing current vs new price, two AppButtons: "تحديث السعر" (returns true), "الاحتفاظ بالسعر الحالي" (returns false)
- [ ] T028 [US2] Modify `ProductSelectionView` / `BuyInvoiceCubit.addProductItem()` to detect price difference when incrementing qty on existing product → show PriceChangeDialog
- [ ] T029 [US2] On dialog confirm: update product.buyingPrice via repository/ProductCubit before adding item to invoice
- [ ] T030 [US2] On dialog cancel: use product's current buyingPrice for invoice item
- [ ] T031 [US2] Add price change logic to `BuyInvoiceRepositoryImpl` / `BuyInvoiceCubit` for updating product buyingPrice in inventory

**Checkpoint**: User Story 2 complete - price change handling works independently

---

## Phase 5: User Story 3 - Validation & Error Handling (Priority: P3)

**Goal**: Proper validation and Arabic error messages for all error scenarios

**Independent Test**:
1. No supplier selected + tap confirm → "يرجى اختيار مورد"
2. No items with qty > 0 + tap confirm → "يرجى إضافة منتج واحد على الأقل بكمية أكبر من صفر"
3. Invoice total > safe balance + tap confirm → "رصيد الخزنة غير كافٍ"

### Implementation for User Story 3

- [ ] T032 [P] [US3] Implement all validation in `BuyInvoiceCubit.validateBuyInvoice()`: supplier required, at least one item with qty > 0, safe balance sufficient
- [ ] T033 [US3] Ensure all error messages use Arabic strings from spec (or AppStrings if available)
- [ ] T034 [US3] Add BlocListener for BuyInvoiceError to show snackbar with appropriate message
- [ ] T035 [US3] Test all three error scenarios manually per quickstart.md

**Checkpoint**: User Story 3 complete - validation and errors work

---

## Phase 6: User Story 4 - Supplier & Product Search (Priority: P2)

**Goal**: Arabic-normalized search in supplier dropdown and product selection

**Independent Test**:
1. Supplier dropdown: type Arabic with/without diacritics → matches suppliers
2. Supplier dropdown: non-matching text → selection clears
3. Product selection: search by name (Arabic) → filtered results
4. Product selection: search by barcode → filtered results
5. Clear search → all products shown

### Implementation for User Story 4

- [ ] T036 [P] [US4] Verify `SupplierDropdownMenu` uses Arabic normalization (reuse `arabic_normalizer.dart` helper) for search matching
- [ ] T037 [US4] Verify `ProductSelectionView` search uses Arabic normalization via `ProductCubit.loadProducts()` / repository `searchProducts()`
- [ ] T038 [US4] Ensure product list shows all products when search query is empty
- [ ] T039 [US4] Test search scenarios per quickstart.md sections 5 & 6

**Checkpoint**: User Story 4 complete - search works with Arabic normalization

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Improvements affecting multiple user stories

- [ ] T040 [P] Run full test suite: `flutter test --coverage` (ensure thresholds: core 90%, features 80%)
- [ ] T041 [P] Run `flutter analyze` - zero errors/warnings
- [ ] T042 [P] Run `flutter build apk --debug` - compiles without warnings
- [ ] T043 Manual RTL smoke test on device/emulator (Arabic text, nav, forms)
- [ ] T044 Performance profile: verify no jank frames in BuyingInvoiceView, ProductSelectionView
- [ ] T045 [P] Update CHANGELOG.md under `## [Unreleased]` with type: feat
- [ ] T046 [P] Verify ObjectBox indexes on BuyingInvoiceModel (date, supplier.id) and InvoiceItemModel (product.id) are working
- [ ] T047 [P] Verify all BlocBuilders use `buildWhen` and BlocListeners use `listenWhen` for optimization
- [ ] T048 [P] Verify no hardcoded colors/styles - all via AppColors, AppTextStyle, AppTheme
- [ ] T049 [P] Verify all text fields use AppTextField, buttons use AppButton
- [ ] T050 [P] Verify all navigation uses AppNavigation, snackbars use showSnackBar
- [ ] T051 Run quickstart.md validation scenarios (all 6 manual tests)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - **BLOCKS all user stories**
- **User Stories (Phase 3-6)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Phase 7)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - Requires US1's ProductSelectionView
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - Independent validation logic
- **User Story 4 (P2)**: Can start after Foundational (Phase 2) - Independent search functionality

### Within Each User Story

- Tests (if included) MUST be written and FAIL before implementation
- Models/Interfaces before implementation
- Repository before Cubit
- Cubit before Views
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All [P] tasks within a user story can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch all models/interfaces for User Story 1 together:
Task: "Create BuyInvoiceRepository interface in lib/features/buying_invoice/data/repositories/buy_invoice_repository.dart"
Task: "Create BuyInvoiceCubitInterface in lib/features/buying_invoice/controller/cubit/buy_invoice_cubit_interface.dart"
Task: "Create BuyInvoiceState in lib/features/buying_invoice/controller/cubit/buy_invoice_state.dart"

# Launch all widgets for User Story 1 together:
Task: "Create SupplierDropdownMenu in lib/features/buying_invoice/presentation/widgets/supplier_dropdown_menu.dart"
Task: "Create InvoiceItemTile in lib/features/buying_invoice/presentation/widgets/invoice_item_tile.dart"
Task: "Create InvoiceProductList in lib/features/buying_invoice/presentation/widgets/invoice_product_list.dart"
Task: "Create InvoiceTotalsCard in lib/features/buying_invoice/presentation/widgets/invoice_totals_card.dart"
```

---

## Parallel Example: User Story 2

```bash
Task: "Create PriceChangeDialog in lib/features/buying_invoice/presentation/widgets/price_change_dialog.dart"
Task: "Update ProductSelectionView for price change detection"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently per quickstart.md
5. Deploy/demo if ready (MVP!)

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Add User Story 4 → Test independently → Deploy/Demo
6. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1 (largest, core flow)
   - Developer B: User Story 2 + User Story 4 (price change + search)
   - Developer C: User Story 3 (validation) + Phase 7 polish tasks
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing (if tests requested)
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
- Follow AGENTS.md conventions: AppNavigation, showSnackBar, AppTextField, AppButton, AppTheme, const constructors, buildWhen/listenWhen