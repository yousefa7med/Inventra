# Tasks: Operations History Feature

**Input**: Design documents from `specs/005-operations-history/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Tests**: Unit tests for Cubit and Repository layers are NOT included (per user decision). SC-007 removed from spec.

**Organization**: Tasks grouped by user story to enable independent implementation and testing.

---

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Maps to user story (US1, US2, US3, US4, US5)
- Exact file paths included

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure - already exists in this codebase, just verify.

- [ ] T001 Verify feature directory structure exists at `lib/features/operations/` with data/, controller/, presentation/, utils/ subdirectories
- [ ] T002 Verify ObjectBox codegen is current (run `dart run build_runner build --delete-conflicting-outputs` if model changes)
- [ ] T003 [P] Add `bloc_test` dependency to `pubspec.yaml` under `dev_dependencies` for potential future testing

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST complete before ANY user story work begins.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

### 2.1 Enum Localization Extension

- [ ] T004 [P] Create `lib/features/operations/utils/balance_change_type_extension.dart` with Arabic label extension on `BalanceChangeType` enum:
  ```dart
  extension BalanceChangeTypeArabic on BalanceChangeType {
    String get arabicLabel => switch (this) {
      BalanceChangeType.expense => 'مصروفات',
      BalanceChangeType.buyInvoice => 'مشتريات',
      BalanceChangeType.sellInvoice => 'مبيعات',
      BalanceChangeType.returnReceipt => 'مرتجعات',
      BalanceChangeType.manualAdjustment => 'تعديل يدوي',
    };
  }
  ```

### 2.2 Data Layer - Local DataSource

- [ ] T005 Create `lib/features/operations/data/datasources/operations_local_datasource.dart`:
  - Interface for ObjectBox queries on `BalanceAuditEntryModel`
  - Methods: `getAll()`, `getByTypes(Set<int> typeIndices)`, `getByDateRange(DateTime start, DateTime end)`, `getByTypesAndDateRange(Set<int> typeIndices, DateTime start, DateTime end)`
  - Use ObjectBox query builder with indexes on `type` and `timestamp`
  - Sort by `timestamp` descending (newest first)
  - Date range: end date adjusted to 23:59:59.999 for full-day inclusivity

- [ ] T006 Create `lib/features/operations/data/datasources/operations_local_datasource_impl.dart` implementing the interface

### 2.3 Data Layer - Repository

- [ ] T007 Create `lib/features/operations/data/repositories/operations_repository.dart` interface:
  - `Future<List<BalanceAuditEntryModel>> getOperations({Set<BalanceChangeType>? types, DateTimeRange? dateRange})`
  - `Future<void> refresh()`

- [ ] T008 Create `lib/features/operations/data/repositories/operations_repository_impl.dart` implementing the interface:
  - Wraps `OperationsLocalDataSource`
  - Converts `BalanceChangeType` enum to int indices for queries
  - Handles combined filter logic (intersection)
  - Adjusts date range end to 23:59:59.999 for full-day inclusivity

### 2.4 DI Registration

- [ ] T009 Register `OperationsRepository` and `OperationsLocalDataSource` in `lib/main.dart` `configureDependencies()`:
  ```dart
  GetIt.instance.registerLazySingleton<OperationsLocalDataSource>(() => OperationsLocalDataSourceImpl());
  GetIt.instance.registerLazySingleton<OperationsRepository>(() => OperationsRepositoryImpl(GetIt.instance<OperationsLocalDataSource>()));
  GetIt.instance.registerLazySingleton<OperationsCubit>(() => OperationsCubit(GetIt.instance<OperationsRepository>()));
  ```

### 2.5 Controller Layer - Cubit State

- [ ] T010 Create `lib/features/operations/controller/cubit/operations_state.dart`:
  - Sealed class hierarchy per data-model.md:
    - `OperationsInitial`
    - `OperationsLoading`
    - `OperationsLoaded { List<OperationDisplayModel> operations, Set<BalanceChangeType> selectedTypes, DateTimeRange? dateRange }`
    - `OperationsError { String message }`
  - `OperationDisplayModel` wrapper:
    ```dart
    class OperationDisplayModel {
      final BalanceAuditEntryModel entry;
      final double previousBalance;
      final double nextBalance;
      OperationDisplayModel({required this.entry, required this.previousBalance, required this.nextBalance});
    }
    ```

### 2.6 Controller Layer - Cubit

- [ ] T011 Create `lib/features/operations/controller/cubit/operations_cubit.dart`:
  - Constructor takes `OperationsRepository`
  - `loadOperations({Set<BalanceChangeType>? types, DateTimeRange? dateRange})` - emits Loading → Loaded/Error
  - Computes running balances: sorts all entries by timestamp asc, initial balance = 0, iterates accumulating `amount` to get `nextBalance`, `previousBalance = nextBalance - amount`
  - Wraps each entry in `OperationDisplayModel` with computed balances
  - `applyTypeFilter(Set<BalanceChangeType> types)` - updates filter and reloads
  - `applyDateFilter(DateTimeRange? range)` - updates filter and reloads
  - `clearFilters()` - resets both filters and reloads
  - Uses `buildWhen` in BlocBuilder to only rebuild on relevant state changes

---

## Phase 3: User Story 1 — View All Operations History (Priority: P1) 🎯 MVP

**Goal**: Display complete chronological list of all operations (newest first) with empty state handling. Each card shows signed amount. Tap navigates to source detail screen (or shows dialog for manualAdjustment).

**Independent Test**: Open Operations tab → list loads within 1s → shows all entries sorted newest-first → each card shows signed amount → empty state shows Arabic message when no data → pull-to-refresh works.

### Implementation

- [ ] T012 [P] [US1] Create `lib/features/operations/presentation/widgets/operations_empty_state.dart`:
  - StatelessWidget showing Arabic message "لا توجد عمليات مسجلة بعد"
  - Uses `AppTextStyle` and `AppColors` only
  - Centered in available space

- [ ] T013 [P] [US1] Create `lib/features/operations/presentation/widgets/operation_list_item.dart`:
  - StatelessWidget for single list row
  - Displays: type (Arabic label via extension), amount (signed currency with +/−)
  - Uses `AppTextStyle`, `AppColors`, `flutter_screenutil` sizing
  - `const` constructor

- [ ] T014 [P] [US1] Create `lib/features/operations/presentation/widgets/operations_loading_body.dart`:
  - StatelessWidget for loading state
  - Centered CircularProgressIndicator with AppColors

- [ ] T015 [P] [US1] Create `lib/features/operations/presentation/widgets/operations_error_body.dart`:
  - StatelessWidget for error state
  - Shows error message + "إعادة المحاولة" (Retry) button using AppButton
  - Retry calls `context.read<OperationsCubit>().loadOperations()`

- [ ] T016 [P] [US1] Create `lib/features/operations/presentation/widgets/operations_loaded_body.dart`:
  - StatelessWidget for loaded state
  - ListView.builder with `itemExtent: 80.h` wrapped in RefreshIndicator
  - Pull-to-refresh calls `context.read<OperationsCubit>().loadOperations()`
  - Handles "no results" state: shows "لا توجد عمليات مطابقة للفلاتر" + "مسح الفلاتر" button
  - Each item: OperationListItem with onTap navigation logic

- [ ] T017 [US1] Create `lib/features/operations/presentation/views/operations_view.dart`:
  - Scaffold with AppBar (title: "سجل العمليات", filter button → opens OperationsFilterSheet)
  - Body: BlocBuilder<OperationsCubit, OperationsState> with `buildWhen` comparing operations list and filter values
  - States: Initial/Loading → OperationsLoadingBody; Loaded → OperationsLoadedBody; Error → OperationsErrorBody

- [ ] T018 [US1] Wire OperationsView into AppRouter:
  - Add route in `lib/core/config/configrations.dart` `AppRoutes.operationsView`
  - Add case in `AppRouter.generateRoute` returning MaterialPageRoute to OperationsView

- [ ] T019 [US1] Implement list item navigation in OperationsLoadedBody:
  - Tap on item: if entry.type != manualAdjustment AND referenceId > 0 → navigate to source detail screen
  - Navigation mapping: sellInvoice → SellInvoiceDetail, buyInvoice → BuyInvoiceDetail, expense → ExpenseDetail, returnReceipt → ReturnReceiptDetail
  - If manualAdjustment or referenceId == 0 → show OperationDetailDialog (see US5)

---

## Phase 4: User Story 2 — Filter Operations by Type (Priority: P1)

**Goal**: Multi-select type filter via bottom sheet with checkboxes for each BalanceChangeType.

**Independent Test**: Tap filter button → bottom sheet opens with 5 checkboxes → select multiple → apply → list shows only selected types within 300ms.

### Implementation

- [ ] T020 [P] [US2] Create `lib/features/operations/presentation/widgets/operations_filter_sheet.dart`:
  - StatefulWidget/BottomSheet with two sections: Type Filter + Date Filter (US3)
  - Type section: 5 CheckboxListTile items (expense, buyInvoice, sellInvoice, returnReceipt, manualAdjustment)
  - Uses `BalanceChangeTypeArabic` extension for labels
  - "تطبيق" (Apply) button emits Cubit events via `applyTypeFilter`
  - "مسح الفلاتر" (Clear Filters) button calls Cubit.clearFilters()
  - "مسح النوع" (Clear Type) button clears only type filter
  - Pre-selects currently active filters from Cubit state
  - Uses `AppTextStyle`, `AppColors`, `AppButton` for buttons

- [ ] T021 [US2] Update `OperationsCubit`:
  - `applyTypeFilter(Set<BalanceChangeType> types)` calls repository with types filter
  - Preserves existing dateRange when applying type filter
  - Emits Loaded with updated operations and selectedTypes

- [ ] T022 [US2] Update `OperationsView`:
  - Filter button in AppBar shows badge with active type count
  - Tap filter button → showModalBottomSheet with OperationsFilterSheet
  - On sheet close with applied filters → list updates automatically via Cubit state

---

## Phase 5: User Story 3 — Filter Operations by Time Period (Priority: P1)

**Goal**: Date range filter with presets (Today, This Week, This Month, Custom) via same bottom sheet.

**Independent Test**: Open filter sheet → tap "هذا الأسبوع" → apply → list shows only entries from current week within 300ms.

### Implementation

- [ ] T023 [P] [US3] Extend `OperationsFilterSheet` date section:
  - Preset chips: "اليوم" (Today), "هذا الأسبوع" (This Week), "هذا الشهر" (This Month), "مخصص" (Custom)
  - Custom: two tappable fields showing start/end date → opens `showDatePicker` with `locale: Locale('ar')`
  - Future end dates clamped to today
  - start > end → auto-swap with showSnackBar notification
  - Selected preset highlighted
  - "مسح التاريخ" (Clear Date) button clears only date filter

- [ ] T024 [US3] Update `OperationsCubit`:
  - `applyDateFilter(DateTimeRange? range)` calls repository with date filter
  - Preserves existing type filter
  - Emits Loaded with updated operations and dateRange

- [ ] T025 [US3] Update `OperationsRepository`:
  - `getOperations` handles dateRange parameter (inclusive start/end, end adjusted to 23:59:59.999)
  - Converts DateTimeRange to DateTime for ObjectBox `.between()` query

---

## Phase 6: User Story 4 — Combine Type and Date Filters (Priority: P1)

**Goal**: Both filters work simultaneously (intersection); clearing one preserves the other.

**Independent Test**: Select "مشتريات" + "هذا الشهر" → apply → only Buy Invoices from current month shown. Clear type filter → all types from current month shown. Clear date filter → all Buy Invoices from all dates shown.

### Implementation

- [ ] T026 [US4] Verify `OperationsRepository.getOperations` handles both filters together:
  - If both types and dateRange provided → ObjectBox query with `.inInt32(type)` AND `.between(timestamp)`
  - Query uses existing indexes on both fields

- [ ] T027 [US4] Update `OperationsFilterSheet`:
  - "مسح الفلاتر" clears BOTH type and date filters
  - Badge on filter button shows combined status (e.g., "2 نوع، هذا الشهر")

- [ ] T028 [US4] Update `OperationsCubit.clearFilters()` resets both and reloads all

---

## Phase 7: User Story 5 — View Operation Details (Priority: P1)

**Goal**: Tap manualAdjustment card (or non-navigable) → dialog shows all fields with computed prev/next balance.

**Independent Test**: Tap manualAdjustment operation → dialog opens with 8 fields (ID, Type, Amount, Prev Balance, Next Balance, Ref ID, Timestamp, Note) → amount green for +, red for − → dismiss on backdrop tap.

### Implementation

- [ ] T029 [P] [US5] Create `lib/features/operations/presentation/widgets/operation_detail_dialog.dart`:
  - Dialog/BottomSheet with Column of ListTile-like rows
  - Fields: المعرف (ID), نوع العملية (Type), المبلغ (Amount with sign), الرصيد السابق (Previous Balance), الرصيد اللاحق (Next Balance), معرف المرجع (Reference ID), التاريخ والوقت (Timestamp), الملاحظة (Note)
  - Amount: `AppColors.success` for positive, `AppColors.error` for negative
  - Previous/Next Balance: formatted currency via utility
  - Reference ID shows "—" if 0
  - Note shows "—" if null/empty
  - RTL layout, `AppTextStyle` throughout
  - Dismissible via backdrop tap or close button

- [ ] T030 [US5] Update `OperationsLoadedBody`:
  - For manualAdjustment or referenceId == 0: onTap → showDialog with OperationDetailDialog(entry: operation.entry, previousBalance: operation.previousBalance, nextBalance: operation.nextBalance)

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Improvements affecting multiple stories, quality gates, validation.

### 8.1 Performance & Edge Cases

- [ ] T031 [P] Verify `ListView.builder` with `itemExtent` handles 1000 entries smoothly (<5% jank)
- [ ] T032 [P] Add Arabic currency formatting utility in `core/utils/formatters.dart` (if not exists): `formatCurrency(double amount)` → "+ ١٬٢٥٠.٠٠ ر.س" / "− ٣٠٠.٠٠ ر.س"
- [ ] T033 [P] Ensure filter state persists across navigation (Cubit registered as LazySingleton, PersistentBottomNavBar keeps widget alive)
- [ ] T034 [P] Seed 1000 test entries and verify load/filter performance meets SC-001–004 (manual verification)

### 8.2 Code Quality & Compliance

- [ ] T035 Run `flutter analyze` — zero errors/warnings on new code
- [ ] T036 Run `dart fix --apply` to auto-fix any lint issues
- [ ] T037 Verify all UI uses `AppColors`, `AppTextStyle`, `AppTheme` — no hardcoded colors/styles
- [ ] T038 Verify all navigation uses `AppNavigation` — no direct `Navigator.of(context)` calls
- [ ] T039 Verify all snackbars use `showSnackBar` helper — no direct `ScaffoldMessenger` calls
- [ ] T040 Verify all text inputs use `AppTextField` — no raw `TextFormField` (date picker uses showDatePicker, not text input)
- [ ] T041 Verify all full-width buttons use `AppButton` — no raw `ElevatedButton` in `SizedBox` (filter sheet buttons use AppButton)
- [ ] T042 Verify all BlocBuilder/BlocListener use `buildWhen`/`listenWhen` (OperationsView BlocBuilder implemented with buildWhen)
- [ ] T043 Verify `const` constructors used wherever possible

### 8.3 Constitution Compliance Verification

- [ ] T044 Verify state body widgets are separate classes: OperationsLoadingBody, OperationsErrorBody, OperationsLoadedBody (Principle VIII)
- [ ] T045 Verify BlocBuilder in OperationsView uses buildWhen comparing operations list and filter values (Principle IV/VIII)
- [ ] T046 Verify no inline Widget Function() builders or _build* methods (Principle VIII)
- [ ] T047 Verify component themes defined in AppTheme, not hardcoded (Principle IX)
- [ ] T048 Manual RTL smoke test on device/emulator (Arabic text, nav, forms) per Constitution Definition of Done

### 8.4 Integration & Validation

- [ ] T049 Run quickstart.md validation scenarios (1-10) manually
- [ ] T050 Build debug APK: `flutter build apk --debug` — compiles without warnings
- [ ] T051 Update `CHANGELOG.md` under `## [Unreleased]` with feat: Operations History feature
- [ ] T052 Verify ObjectBox model has @Index on type and timestamp in BalanceAuditEntryModel; run build_runner if changed

---

## Dependencies & Execution Order

### Phase Dependencies

| Phase | Depends On | Blocks |
|-------|------------|--------|
| Setup (1) | — | Foundational (2) |
| Foundational (2) | Setup (1) | **ALL User Stories (3-7)** |
| US1 (3) | Foundational (2) | US5 (7) |
| US2 (4) | Foundational (2) | US4 (6) |
| US3 (5) | Foundational (2) | US4 (6) |
| US4 (6) | Foundational (2), US2 (4), US3 (5) | — |
| US5 (7) | Foundational (2), US1 (3) | — |
| Polish (8) | All desired US complete | — |

### User Story Dependencies

- **US1 (View List)**: Independent after Foundational — **MVP**
- **US2 (Type Filter)**: Independent after Foundational
- **US3 (Date Filter)**: Independent after Foundational
- **US4 (Combined)**: Requires US2 + US3 complete
- **US5 (Detail View)**: Requires US1 (list exists)

---

## Parallel Opportunities

### Within Foundational Phase (Phase 2)

```bash
# All [P] tasks can run in parallel:
T004  balance_change_type_extension.dart
T005  operations_local_datasource.dart
T007  operations_repository.dart (interface)
T010  operations_state.dart
```

### Within Each User Story

**US1 (View List)**:
```bash
T012  operations_empty_state.dart       [P]
T013  operation_list_item.dart          [P]
T014  operations_loading_body.dart      [P]
T015  operations_error_body.dart        [P]
T016  operations_loaded_body.dart       [P]
```

**US2 (Type Filter)**:
```bash
T020  operations_filter_sheet.dart      [P]
```

**US3 (Date Filter)**:
```bash
T023  operations_filter_sheet_extend    [P]
```

**US5 (Detail View)**:
```bash
T029  operation_detail_dialog.dart      [P]
```

**Polish**:
```bash
T031-T052  all [P] (independent checks)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete **Phase 1** (Setup) → verify
2. Complete **Phase 2** (Foundational) → verify Cubit loads empty list
3. Complete **Phase 3** (US1) → test manually via quickstart Scenario 1 & 2
4. **STOP and VALIDATE** — Operations tab shows list, empty state, pull-to-refresh works, tap navigates to source detail
5. Deploy/demo if ready

### Incremental Delivery

1. Foundation ready → **US1 works independently** → Deploy MVP
2. Add **US2** → Test independently → Deploy
3. Add **US3** → Test independently → Deploy
4. Add **US4** → Integration test US2+US3+US4 → Deploy
5. Add **US5** → Test independently → Deploy

### Parallel Team Strategy

With 3+ developers:
- Dev A: Phase 2 → US1 → US5
- Dev B: Phase 2 → US2 → US4
- Dev C: Phase 2 → US3 → US4
- All converge on Phase 8 (Polish)

---

## Task Summary

| Phase | Tasks | Parallelizable |
|-------|-------|----------------|
| 1: Setup | 3 | 1 ([P]) |
| 2: Foundational | 8 | 4 ([P]) |
| 3: US1 (View List) | 8 | 5 ([P]) |
| 4: US2 (Type Filter) | 3 | 1 ([P]) |
| 5: US3 (Date Filter) | 3 | 1 ([P]) |
| 6: US4 (Combined) | 3 | 0 |
| 7: US5 (Detail View) | 2 | 1 ([P]) |
| 8: Polish | 22 | 19 ([P]) |
| **Total** | **52** | **32 [P]** |

---

## Notes

- All file paths relative to `lib/` or `test/` root
- No new ObjectBox entities — reads existing `BalanceAuditEntryModel`
- Uses new `OperationsRepository` wrapping ObjectBox directly (not SafeRepository)
- Arabic RTL compliance enforced via constitution principles (AppTheme, AppColors, AppTextStyle, AppNavigation, showSnackBar, AppTextField, AppButton)
- `bloc_test` added for potential future testing (dev_dependency)
- Quickstart.md scenarios serve as acceptance test scripts
- State body widgets separated per Principle VIII: OperationsLoadingBody, OperationsErrorBody, OperationsLoadedBody
- BlocBuilder in OperationsView uses buildWhen per Principle IV/VIII
- Currency formatting in core/utils/formatters.dart per Principle III
- Filter state persists via LazySingleton Cubit + PersistentBottomNavBar
- Date range end adjusted to 23:59:59.999 for full-day inclusivity
- List item tap navigates to source detail screen based on BalanceChangeType
- manualAdjustment shows detail dialog with computed prev/next balance