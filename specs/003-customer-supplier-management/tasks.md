# Tasks: Customer Supplier Management

**Input**: Design documents from `/specs/003-customer-supplier-management/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Tests**: The examples below include test tasks. Tests are OPTIONAL - only include them if explicitly requested in the feature specification.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

---

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1-US8)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure for this feature

- [ ] T001 Add `url_launcher: ^6.2.0` dependency to pubspec.yaml
- [ ] T002 Run `flutter pub get` to fetch new dependency
- [ ] T003 [P] Create feature folder structure: `lib/features/customers/` with controller/cubit and presentation/views/widgets subdirectories
- [ ] T004 [P] Create feature folder structure: `lib/features/suppliers/` with controller/cubit and presentation/views/widgets subdirectories
- [ ] T005 Run `dart run build_runner build --delete-conflicting-outputs` to ensure ObjectBox codegen is up to date

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T006 [P] Create `lib/core/utils/validators.dart` with Validator class containing static methods for Customer (validateName, validatePhone, validateAddress) and Supplier (validateName, validateStoreName, validateStoreAddress, validatePhone) per AddCustomerView/AddSupplierView validators
- [ ] T006a [US1,US4] Refactor `lib/features/dashboard/presentation/views/add_customer_view.dart` to use `Validator.validateName/Phone/Address` from validators.dart
- [ ] T006b [US5,US8] Refactor `lib/features/dashboard/presentation/views/add_supplier_view.dart` to use `Validator.validateName/StoreName/StoreAddress/Phone` from validators.dart
- [ ] T007 [P] Create `lib/core/utils/phone_utils.dart` with `launchDialer(String phoneNumber)` helper using url_launcher tel: scheme
- [ ] T008 Add `AppRoutes.editCustomerView = '/edit-customer'` and `AppRoutes.editSupplierView = '/edit-supplier'` constants in `lib/core/config/configrations.dart` (camelCase)
- [ ] T008a Rename existing route constants to camelCase: `addCustomerView`, `addSupplierView`, `addProductView`, `editProductView`, `addInvoiceView`, `addExpenseView`, `sellingInvoiceView`, `addProductToInvoice`, `allCustomers`, `allSuppliers`, `buyInvoices`, `settings` in `lib/core/config/configrations.dart` and update all usages
- [ ] T008a Update existing route constants to camelCase: `addCustomerView`, `addSupplierView`, `addProductView`, `editProductView`, `addInvoiceView`, `addExpenseView`, `sellingInvoiceView`, `addProductToInvoice`, `allCustomers`, `allSuppliers`, `buyInvoices`, `settings`
- [ ] T009 Add route cases for `editCustomerView` and `editSupplierView` in `AppRouter.generateRoute()` following EditProductView pattern (expects full model object as arguments)
- [ ] T010 Register `CustomerCubit` and `SupplierCubit` as LazySingleton in GetIt within `lib/main.dart` configureDependencies()
- [ ] T011 [P] Create `lib/features/customers/controller/cubit/customer_state.dart` with states: CustomerInitial, CustomerLoading, CustomerLoaded(customers, searchQuery), CustomerError(message), CustomerOperationSuccess(message)
- [ ] T012 [P] Create `lib/features/suppliers/controller/cubit/supplier_state.dart` with states: SupplierInitial, SupplierLoading, SupplierLoaded(suppliers, searchQuery), SupplierError(message), SupplierOperationSuccess(message)
- [ ] T013 Create `lib/features/customers/controller/cubit/customer_cubit.dart` with methods: loadCustomers(), searchCustomers(query), updateCustomer(customer) - using ObjectBox queries with debounced search (300ms Timer)
- [ ] T014 Create `lib/features/suppliers/controller/cubit/supplier_cubit.dart` with methods: loadSuppliers(), searchSuppliers(query), updateSupplier(supplier) - using ObjectBox queries with debounced search (300ms Timer)

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Search Customers by Name (Priority: P1) 🎯 MVP

**Goal**: Implement searchable customer list screen (AllCustomersView) with real-time filtering

**Independent Test**: Navigate to AllCustomersView, type in search bar, verify list filters in real-time (300ms debounce), clear shows all, no-match shows empty state

### Implementation for User Story 1

- [ ] T015 [P] [US1] Use existing `SearchField` widget from core/widgets (or create `lib/features/customers/presentation/widgets/customer_search_bar.dart` if custom needed) - search input with debounce (300ms), RTL support, AppTextField, clear button
- [ ] T016 [US1] Create `lib/features/customers/presentation/views/all_customers_view.dart` - BlocBuilder with CustomerCubit, shows search bar, customer list (ListView.builder), empty states, loading/error states as separate widget classes
- [ ] T017 [US1] Implement search integration in AllCustomersView - connect search bar to CustomerCubit.searchCustomers(), use buildWhen for performance per constitution
- [ ] T018 [P] [US1] Create `lib/core/widgets/empty_state_widget.dart` - generic widget taking message and action button params, used by both features

---

## Phase 4: User Story 2 - View Customer Details in Card (Priority: P1)

**Goal**: Display customers as cards with name, address, phone, call button, edit button

**Independent Test**: Navigate to AllCustomersView, verify each card shows name/address/phone with RTL layout, placeholders for missing fields

### Implementation for User Story 2

- [ ] T019 [P] [US2] Create `lib/features/customers/presentation/widgets/customer_card.dart` - Card widget showing name, address (or "لا يوجد عنوان"), phone (or "لا يوجد هاتف"), call button (phone icon), edit button (edit icon) - all RTL compliant using AppTheme.cardTheme, AppColors, AppTextStyle via Theme.of(context)
- [ ] T020 [US2] Integrate CustomerCard into AllCustomersView ListView.builder - pass CustomerModel, handle onCallTap and onEditTap callbacks
- [ ] T021 [US2] Implement call button in CustomerCard - uses phone_utils.launchDialer(), shows snackbar via showSnackBar() if phone is empty/null
- [ ] T022 [US2] Implement edit button in CustomerCard - uses AppNavigation.pushName() to editCustomerView with CustomerModel as arguments

---

## Phase 5: User Story 3 - Call Customer from Card (Priority: P1)

**Goal**: Phone dialer integration on customer cards

**Independent Test**: Tap call button on customer with phone → dialer opens with number; tap call on customer without phone → snackbar shows "لا يوجد رقم هاتف لهذا العميل"

### Implementation for User Story 3

- [ ] T023 [US3] Call functionality already implemented in T021 as part of CustomerCard - verify integration and test

---

## Phase 6: User Story 4 - Edit Customer Details (Priority: P1)

**Goal**: Edit form pre-filled with customer data, same validations as AddCustomerView

**Independent Test**: Tap edit on card → form pre-filled → modify valid data → save → returns to list with updated data; invalid data shows inline errors; cancel returns without saving

### Implementation for User Story 4

- [ ] T025 [P] [US4] Create `lib/features/customers/presentation/views/edit_customer_view.dart` - form with AppTextField for name/phone/address, takes `CustomerModel?` as constructor param; if not null, initializes TextEditingControllers with model data in initState; validators from Validator class; AppButton for save
- [ ] T026 [US4] Implement form submission in EditCustomerView - validate using Validator class, call CustomerCubit.updateCustomer(), show success snackbar, navigate back via AppNavigation.pop()
- [ ] T027 [US4] Implement cancel/back navigation in EditCustomerView - AppNavigation.pop() without saving
- [ ] T028 [US4] Wire edit navigation in AllCustomersView (from T022) to pass full CustomerModel object as route argument

---

## Phase 7: User Story 5 - Search Suppliers by Name (Priority: P1)

**Goal**: Implement searchable supplier list screen (AllSuppliersView) with real-time filtering

**Independent Test**: Navigate to AllSuppliersView, type in search bar, verify list filters in real-time (300ms debounce), clear shows all, no-match shows empty state

### Implementation for User Story 5

- [ ] T029 [P] [US5] Use existing `SearchField` widget from core/widgets (or create `lib/features/suppliers/presentation/widgets/supplier_search_bar.dart` if custom needed) - search input with debounce (300ms), RTL support, AppTextField, clear button
- [ ] T030 [US5] Create `lib/features/suppliers/presentation/views/all_suppliers_view.dart` - BlocBuilder with SupplierCubit, shows search bar, supplier list (ListView.builder), empty states, loading/error states as separate widget classes
- [ ] T031 [US5] Implement search integration in AllSuppliersView - connect search bar to SupplierCubit.searchSuppliers(), use buildWhen for performance per constitution
- [ ] T032 [US5] Use shared `lib/core/widgets/empty_state_widget.dart` (from T018) with "لا يوجد موردين" message and "إضافة مورد" button navigating to AddSupplierView

---

## Phase 8: User Story 6 - View Supplier Details in Card (Priority: P1)

**Goal**: Display suppliers as cards with contact name, store name, store address, phone, call button, edit button

**Independent Test**: Navigate to AllSuppliersView, verify each card shows 4 fields with RTL layout, placeholders for missing fields

### Implementation for User Story 6

- [ ] T033 [P] [US6] Create `lib/features/suppliers/presentation/widgets/supplier_card.dart` - Card widget showing contact name, store name, store address (or "لا يوجد عنوان"), phone (or "لا يوجد هاتف"), call button (phone icon), edit button (edit icon) - all RTL compliant using AppTheme.cardTheme, AppColors, AppTextStyle via Theme.of(context)
- [ ] T034 [US6] Integrate SupplierCard into AllSuppliersView ListView.builder - pass SupplierModel, handle onCallTap and onEditTap callbacks
- [ ] T035 [US6] Implement call button in SupplierCard - uses phone_utils.launchDialer(), shows snackbar via showSnackBar() if phone is empty/null
- [ ] T036 [US6] Implement edit button in SupplierCard - uses AppNavigation.pushName() to editSupplierView with SupplierModel as arguments

---

## Phase 9: User Story 7 - Call Supplier from Card (Priority: P1)

**Goal**: Phone dialer integration on supplier cards

**Independent Test**: Tap call button on supplier with phone → dialer opens with number; tap call on supplier without phone → snackbar shows "لا يوجد رقم هاتف لهذا المورد"

### Implementation for User Story 7

- [ ] T037 [US7] Call functionality already implemented in T035 as part of SupplierCard - verify integration and test

---

## Phase 10: User Story 8 - Edit Supplier Details (Priority: P1)

**Goal**: Edit form pre-filled with supplier data (4 fields), same validations as AddSupplierView

**Independent Test**: Tap edit on card → form pre-filled (name, storeName, storeAdd, phone) → modify valid data → save → returns to list with updated data; invalid data shows inline errors; cancel returns without saving

### Implementation for User Story 8

- [ ] T038 [P] [US8] Create `lib/features/suppliers/presentation/views/edit_supplier_view.dart` - form with AppTextField for name/storeName/storeAdd/phone, takes `SupplierModel?` as constructor param; if not null, initializes TextEditingControllers with model data in initState; validators from Validator class; AppButton for save
- [ ] T039 [US8] Implement form submission in EditSupplierView - validate using Validator class, call SupplierCubit.updateSupplier(), show success snackbar, navigate back via AppNavigation.pop()
- [ ] T040 [US8] Implement cancel/back navigation in EditSupplierView - AppNavigation.pop() without saving
- [ ] T041 [US8] Wire edit navigation in AllSuppliersView (from T036) to pass full SupplierModel object as route argument

---

## Phase 11: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T042 [P] Verify `flutter analyze` shows zero errors/warnings in new files
- [ ] T043 Verify all new screens respect RTL layout (Arabic locale) - test on device/emulator
- [ ] T044 Verify no hardcoded colors/styles in new files - all use AppTheme/AppColors/AppTextStyle; custom widgets use `Theme.of(context).cardTheme`, `inputDecorationTheme`, `elevatedButtonTheme` via Theme.of(context)
- [ ] T045 Verify all navigation uses AppNavigation.pushName/pop, snackbars use showSnackBar helper
- [ ] T046 Verify all form inputs use AppTextField, submit buttons use AppButton
- [ ] T047 [P] Run quickstart.md manual test scenarios 1-10 to validate all user stories
- [ ] T047a Note: SC-001 (300ms search) and SC-002 (dialer 100%) verified manually per quickstart; automated coverage tracked separately
- [ ] T048 [P] Run `flutter build apk --debug` to verify compilation
- [ ] T049 [P] Add CHANGELOG.md entry under `## [Unreleased]` with type `feat`: `feat: customer/supplier management - search, call, edit (url_launcher)`
- [ ] T050 Remove deleteCustomer/deleteSupplier methods from Cubits (YAGNI - not in spec)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - **BLOCKS all user stories**
- **User Stories (Phases 3-10)**: All depend on Foundational phase completion
  - Customer stories (US1-US4) can run in parallel with Supplier stories (US5-US8) after Foundational
  - Within Customer: US1 → US2 → US3/US4 (US3/US4 depend on US2 card widget)
  - Within Supplier: US5 → US6 → US7/US8 (US7/US8 depend on US6 card widget)
- **Polish (Phase 11)**: Depends on all desired user stories being complete

### User Story Dependencies

- **US1 (Search Customers)**: After Foundational - No dependencies on other stories
- **US2 (View Customer Cards)**: After US1 (needs AllCustomersView) - Enables US3, US4
- **US3 (Call Customer)**: After US2 (uses CustomerCard) - Independent of US4
- **US4 (Edit Customer)**: After US2 (needs card edit callback) - Independent of US3
- **US5 (Search Suppliers)**: After Foundational - No dependencies on Customer stories
- **US6 (View Supplier Cards)**: After US5 (needs AllSuppliersView) - Enables US7, US8
- **US7 (Call Supplier)**: After US6 (uses SupplierCard) - Independent of US8
- **US8 (Edit Supplier)**: After US6 (needs card edit callback) - Independent of US7

### Within Each User Story

- Tests (if included) MUST be written and FAIL before implementation
- Models before Services/Cubits
- Services/Cubits before Views
- Widgets before View integration
- Core implementation before Polish

---

## Parallel Opportunities

### Phase 1 (Setup)
```bash
# All can run in parallel:
T003 - Create customers feature folders
T004 - Create suppliers feature folders
```

### Phase 2 (Foundational)
```bash
# All can run in parallel:
T006 - Create validators.dart
T007 - Create phone_utils.dart
T011 - Create customer_state.dart
T012 - Create supplier_state.dart
```

### Phase 3-4 (Customer Feature - US1/US2)
```bash
# After Foundational complete:
T015 - customer_search_bar.dart [P]
T018 - empty_state_widget.dart (shared core) [P]
# Then sequentially:
T016 - all_customers_view.dart (depends on T015, T018)
T017 - search integration (depends on T016)
T019 - customer_card.dart [P]
T020 - integrate card (depends on T019)
T021 - call button (depends on T020)
T022 - edit navigation (depends on T020)
```

### Phase 5-6 (Supplier Feature - US5/US6)
```bash
# After Foundational complete (can run in parallel with Customer feature):
T029 - supplier_search_bar.dart [P]
# Then sequentially:
T030 - all_suppliers_view.dart (depends on T029, T018 shared)
T031 - search integration (depends on T030)
T033 - supplier_card.dart [P]
T034 - integrate card (depends on T033)
T035 - call button (depends on T034)
T036 - edit navigation (depends on T034)
```

### Phase 6 & 10 (Edit Forms - US4 & US8)
```bash
# Can run in parallel after respective card integrations:
T025 - edit_customer_view.dart [P] (after T022)
T038 - edit_supplier_view.dart [P] (after T041)
# Then sequentially:
T026 - edit customer submit (depends on T025)
T027 - edit customer cancel (depends on T025)
T039 - edit supplier submit (depends on T038)
T040 - edit supplier cancel (depends on T038)
```

### Phase 11 (Polish)
```bash
# All can run in parallel:
T042 - flutter analyze
T043 - RTL verification
T044 - Hardcoded styling check (includes component themes)
T045 - Navigation/snackbar helpers check
T046 - Form widgets check
T047 - Manual test scenarios
T048 - Build verification
T049 - CHANGELOG entry
```

---

## Implementation Strategy

### MVP First (Customer Feature Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phases 3-6: Customer Feature (US1-US4)
4. **STOP and VALIDATE**: Test Customer feature independently per quickstart.md
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add Customer Feature (US1-US4) → Test independently → Deploy/Demo (MVP!)
3. Add Supplier Feature (US5-US8) → Test independently → Deploy/Demo
4. Each feature adds value without breaking previous

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: Customer Feature (US1-US4)
   - Developer B: Supplier Feature (US5-US8)
3. Features complete and integrate independently
4. Polish phase shared

---

## Notes

- **[P]** tasks = different files, no dependencies on incomplete tasks
- **[Story]** label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing (if tests requested)
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
- **Constitution compliance**: All tasks enforce AppNavigation, showSnackBar, AppTextField, AppButton, AppTheme/AppColors/AppTextStyle, RTL, buildWhen/listenWhen for BlocBuilder/BlocListener, component themes via Theme.of(context)

---

## File Path Reference

```
lib/
├── core/
│   ├── config/configrations.dart          # T008, T008a, T009
│   ├── utils/
│   │   ├── validators.dart                # T006 (Validator class)
│   │   └── phone_utils.dart               # T007
│   ├── widgets/
│   │   ├── empty_state_widget.dart        # T018 (shared)
│   │   └── search_field.dart              # Existing SearchField (T015, T029)
│   └── ...
├── features/
│   ├── customers/
│   │   ├── controller/cubit/
│   │   │   ├── customer_state.dart        # T011
│   │   │   └── customer_cubit.dart        # T013
│   │   └── presentation/
│   │       ├── views/
│   │       │   ├── all_customers_view.dart    # T016
│   │       │   └── edit_customer_view.dart    # T025
│   │       └── widgets/
│   │           ├── customer_search_bar.dart   # T015 (or use core SearchField)
│   │           ├── customer_card.dart         # T019
│   └── suppliers/
│       ├── controller/cubit/
│       │   ├── supplier_state.dart        # T012
│       │   └── supplier_cubit.dart        # T014
│       └── presentation/
│           ├── views/
│           │   ├── all_suppliers_view.dart    # T030
│           │   └── edit_supplier_view.dart    # T038
│           └── widgets/
│               ├── supplier_search_bar.dart   # T029 (or use core SearchField)
│               ├── supplier_card.dart         # T033
└── main.dart                              # T010
```