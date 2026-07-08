---

description: "Task list for Safe Balance Tracking feature implementation"
---

# Tasks: Safe Balance Tracking

**Input**: Design documents from `/specs/001-safe-balance-tracking/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: The examples below include test tasks. Tests are MANDATORY per Constitution Principle II (TDD required for all business logic). The Constitution mandates TDD for business logic (90% cubit, 80% views).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Flutter Mobile**: `lib/` at repository root
- Feature module: `lib/features/safe/`
- Core models: `lib/core/models/`
- Tests: `test/features/safe/` (unit), `test/integration/` (integration)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure for the Safe feature

- [ ] T001 Create Safe feature directory structure per plan.md (`lib/features/safe/{controller/cubit,data/repositories,presentation/views}`)
- [ ] T002 [P] Add Safe feature routes to `lib/core/config/configrations.dart` (AppRoutes + AppRouter cases for SafeView, AddExpenseView)
- [ ] T003 [P] Register SafeCubit as LazySingleton in `lib/main.dart` configureDependencies()
- [ ] T004 [P] Add SafeBalance, Expense, BalanceAuditEntry boxes to ObjectBoxServices in `lib/core/helper/cache_helper.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T005 Create Expense entity in `lib/core/models/expense.dart` with ObjectBox annotations (@Entity, @Id, @Index on date)
- [ ] T006 Create SafeBalance entity in `lib/core/models/safe_balance.dart` with ObjectBox annotations (singleton id=1)
- [ ] T007 Create BalanceAuditEntry entity in `lib/core/models/balance_audit_entry.dart` with ObjectBox annotations (@Entity, @Id, @Index on type, timestamp)
- [ ] T008 Create BalanceChangeType enum in `lib/core/models/balance_change_type.dart`
- [ ] T009 Run ObjectBox codegen: `dart run build_runner build --delete-conflicting-outputs`
- [ ] T010 Create SafeRepository interface in `lib/features/safe/data/repositories/safe_repository.dart`
- [ ] T011 Implement SafeRepository with ObjectBox in `lib/features/safe/data/repositories/safe_repository_impl.dart` (getBalance, updateBalance, initializeBalance, getAllExpenses, getExpensesFiltered, addExpense, watchExpenses, getAuditEntries, addAuditEntry, watchAuditEntries)
- [ ] T012 Create SafeState sealed class in `lib/features/safe/controller/cubit/safe_state.dart` (SafeInitial, SafeLoading, SafeLoaded, SafeError, SafeExpenseAdding, SafeBalanceAdjusting)
- [ ] T013 Create SafeCubit in `lib/features/safe/controller/cubit/safe_cubit.dart` implementing SafeCubitInterface from contracts (load, addExpense, setDateFilter, setSearchFilter, clearFilters, adjustBalance, adjustBalanceForTransaction, balanceStream, currentBalance, expensesStream, filteredExpenses, filterFromDate, filterToDate, searchText)
- [ ] T014 [P] Create SafeCubitInterface in `lib/features/safe/controller/cubit/safe_cubit_interface.dart` (per contracts/safe_cubit_interface.md)

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - View Safe Balance & Expense History (Priority: P1) 🎯 MVP

**Goal**: Display current safe balance prominently with chronological expense list (newest first), showing zero-state correctly

**Independent Test**: Open Safe screen → balance shows 0.00, empty list → add expenses via test → balance decreases, list shows expenses newest-first with date/value/note

### Tests for User Story 1 (MANDATORY - Constitution Principle II: TDD required) ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T015 [P] [US1] Contract test for SafeCubit balanceStream in `test/features/safe/controller/cubit/safe_cubit_balance_stream_test.dart`
- [ ] T016 [P] [US1] Contract test for SafeCubit expensesStream in `test/features/safe/controller/cubit/safe_cubit_expenses_stream_test.dart`
- [ ] T017 [P] [US1] Unit test for SafeRepository getBalance in `test/features/safe/data/repositories/safe_repository_balance_test.dart`
- [ ] T018 [P] [US1] Unit test for SafeRepository getAllExpenses in `test/features/safe/data/repositories/safe_repository_expenses_test.dart`
- [ ] T019 [P] [US1] Integration test for initial load flow in `test/integration/safe_us1_initial_load_test.dart`

### Implementation for User Story 1

- [ ] T020 [P] [US1] Create SafeView in `lib/features/safe/presentation/views/safe_view.dart` (balance display, expense ListView, FAB, Adjust Balance button, filter/search UI)
- [ ] T021 [US1] Wire SafeView to SafeCubit via BlocProvider in MainView bottom nav (modify `lib/features/main/presentation/views/main_view.dart`)
- [ ] T022 [US1] Implement balance display with AppColors/AppTextStyle, negative balance highlighting (red), RTL currency format (FR-021)
- [ ] T023 [US1] Implement expense list with date, value, note columns, newest-first ordering
- [ ] T024 [US1] Implement pull-to-refresh calling SafeCubit.load()
- [ ] T025 [US1] Add Arabic localization keys for all user-facing strings (balance, expense, date, value, note, filter, search, adjust)

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Add New Expense (Priority: P1)

**Goal**: Allow users to add expenses via FAB → form → save, with validation, balance decrease, and audit entry

**Independent Test**: Tap FAB → enter valid value+note → save → balance decreases by value → expense appears in list with today's date → audit entry created

### Tests for User Story 2 (MANDATORY - Constitution Principle II: TDD required) ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T026 [P] [US2] Contract test for SafeCubit addExpense in `test/features/safe/controller/cubit/safe_cubit_add_expense_test.dart`
- [ ] T027 [P] [US2] Unit test for expense validation (value>0, note not empty) in `test/features/safe/controller/cubit/safe_cubit_validation_test.dart`
- [ ] T028 [P] [US2] Unit test for SafeRepository addExpense in `test/features/safe/data/repositories/safe_repository_add_expense_test.dart`
- [ ] T029 [US2] Integration test for expense creation flow in `test/integration/safe_us2_add_expense_test.dart`

### Implementation for User Story 2

- [ ] T030 [P] [US2] Create AddExpenseView in `lib/features/safe/presentation/views/add_expense_view.dart` (value TextFormField, note TextFormField, save/cancel buttons, validation)
- [ ] T031 [US2] Wire FAB in SafeView to navigate to AddExpenseView using AppNavigation.pushName()
- [ ] T032 [US2] Implement expense form validation (value: positive number, 2 decimals max; note: required; show Arabic error messages)
- [ ] T033 [US2] Implement SafeCubit.addExpense to call repository, update balance atomically with audit entry, emit SafeLoaded
- [ ] T034 [US2] Add expense creation timestamp auto-capture (current date, time ignored per assumptions)
- [ ] T035 [US2] Implement duplicate expense detection (same value+note within 5 seconds) with confirmation dialog

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - Filter & Search Expenses (Priority: P2)

**Goal**: Allow users to filter expenses by date range and search by note text, with combined AND logic

**Independent Test**: Add expenses across dates → set date filter → only matching expenses shown → search by note → only matching shown → combine both → only matching both shown → clear filters → all shown

### Tests for User Story 3 (MANDATORY - Constitution Principle II: TDD required) ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T036 [P] [US3] Contract test for SafeCubit setDateFilter in `test/features/safe/controller/cubit/safe_cubit_date_filter_test.dart`
- [ ] T037 [P] [US3] Contract test for SafeCubit setSearchFilter in `test/features/safe/controller/cubit/safe_cubit_search_filter_test.dart`
- [ ] T038 [P] [US3] Unit test for SafeRepository getExpensesFiltered in `test/features/safe/data/repositories/safe_repository_filtered_expenses_test.dart`
- [ ] T039 [US3] Integration test for filter + search combined flow in `test/integration/safe_us3_filter_search_test.dart`

### Implementation for User Story 3

- [ ] T040 [P] [US3] Add filter UI to SafeView (filter icon, date range picker, search field, clear button, filter chips)
- [ ] T041 [US3] Implement SafeCubit.setDateFilter, setSearchFilter, clearFilters with session persistence (reset on app restart)
- [ ] T042 [US3] Implement SafeRepository.getExpensesFiltered with ObjectBox query (date range + note contains, case-insensitive Arabic, NFC normalized, diacritic-insensitive)
- [ ] T043 [US3] Add filter state indicators (active filter chips showing from/to dates, search text)
- [ ] T044 [US3] Handle empty filter results state (show localization key for "no matching expenses")

**Checkpoint**: At this point, User Stories 1, 2, AND 3 should all work independently

---

## Phase 6: User Story 4 - Manual Balance Adjustment (Priority: P2)

**Goal**: Allow users to set balance to a specific value with audit trail

**Independent Test**: Tap Adjust Balance button → enter new balance value → confirm → balance updates to entered value → audit entry created with type=manualAdjustment, amount=delta

### Tests for User Story 4 (MANDATORY - Constitution Principle II: TDD required) ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T045 [P] [US4] Contract test for SafeCubit adjustBalance in `test/features/safe/controller/cubit/safe_cubit_adjust_balance_test.dart`
- [ ] T046 [P] [US4] Unit test for SafeRepository updateBalance in `test/features/safe/data/repositories/safe_repository_update_balance_test.dart`
- [ ] T047 [US4] Integration test for balance adjustment flow in `test/integration/safe_us4_adjust_balance_test.dart`

### Implementation for User Story 4

- [ ] T048 [P] [US4] Create AdjustBalanceDialog in `lib/features/safe/presentation/views/adjust_balance_dialog.dart` (value field, optional note, confirm/cancel)
- [ ] T049 [US4] Wire Adjust Balance button in SafeView to show AdjustBalanceDialog
- [ ] T050 [US4] Implement SafeCubit.adjustBalance to set balance (replace), create audit entry with delta amount, emit SafeLoaded
- [ ] T051 [US4] Add validation for numeric input bounds (max 999,999,999.99 per edge case)
- [ ] T052 [US4] Ensure cancel leaves balance unchanged, no audit entry created

**Checkpoint**: At this point, User Stories 1, 2, 3, AND 4 should all work independently

---

## Phase 7: User Story 5 - Invoice/Return Integration (Priority: P3 - Future)

**Goal**: Expose SafeCubit interface for other features (BuyInvoice, SellInvoice, ReturnReceipt) to notify balance changes

**Independent Test**: Call SafeCubit.adjustBalanceForTransaction with each type → balance updates per business rules (buy↓, sell↑, return↓) → audit entries created with correct type, amount, referenceId

### Tests for User Story 5 (MANDATORY - Constitution Principle II: TDD required) ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T053 [P] [US5] Contract test for SafeCubit adjustBalanceForTransaction in `test/features/safe/controller/cubit/safe_cubit_integration_test.dart`
- [ ] T054 [P] [US5] Unit test for Result<T> error codes (validationError, notFound, databaseError, unknown) in `test/features/safe/controller/cubit/safe_cubit_result_codes_test.dart`
- [ ] T055 [US5] Integration test for all 3 integration types in `test/integration/safe_us5_invoice_integration_test.dart`

### Implementation for User Story 5

- [ ] T056 [P] [US5] Implement SafeCubit.adjustBalanceForTransaction with signed amount, BalanceChangeType, referenceId, note
- [ ] T057 [US5] Ensure transactional atomicity (balance update + audit entry in single ObjectBox transaction)
- [ ] T058 [US5] Add validation: referenceId > 0 for invoice/return types, amount != 0
- [ ] T059 [US5] Document integration usage examples in `lib/features/safe/controller/cubit/safe_cubit_integration_docs.dart`
- [ ] T060 [US5] Add error handling for GetIt resolution failures (SafeCubit not registered)

**Checkpoint**: At this point, all 5 User Stories should be independently functional

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T061 [P] Add unit tests for all SafeCubit methods (target 90% coverage) in `test/features/safe/controller/cubit/`
- [ ] T062 [P] Add unit tests for SafeRepository methods (target 90% coverage) in `test/features/safe/data/repositories/`
- [ ] T063 [P] Add integration tests for all user story flows (target 80% coverage) in `test/integration/`
- [ ] T064 Run `flutter test --coverage` and verify thresholds (core 90%, features 80%)
- [ ] T065 Run `flutter analyze` and fix all warnings/errors
- [ ] T066 Run `flutter build apk --debug` and verify clean compilation
- [ ] T067 [P] Manual RTL smoke test on device/emulator (Arabic text, nav, forms, RTL mirroring)
- [ ] T068 [P] Performance profile: `flutter run --profile --trace-startup`, verify no jank frames in Safe screens
- [ ] T069 [P] Verify ObjectBox reactive queries (watch()) used, no getAll() in build methods
- [ ] T070 Run quickstart.md validation scenarios (all 13 scenarios)
- [ ] T071 Update CHANGELOG.md under `## [Unreleased]` with feat: safe-balance-tracking
- [ ] T072 [P] Add AppColors entries for balance negative/error states if missing
- [ ] T073 [P] Add AppTextStyle entries for balance display, expense list items if missing
- [ ] T074 [P] Verify all user-facing strings use Arabic localization keys (no hardcoded strings)
- [ ] T075 [P] Verify touch targets ≥48×48dp, contrast ≥4.5:1 (WCAG AA)
- [ ] T076 [P] Add automated integration test: verify SafeView load time ≤1s with 100 expenses (SC-001)
- [ ] T077 [P] Add automated integration test: verify addExpense → SafeLoaded ≤2s (SC-002)
- [ ] T078 [P] Add automated integration test: verify getExpensesFiltered with 500 expenses ≤500ms (SC-003)
- [ ] T079 [P] Add automated integration test: verify note search with 500 expenses ≤500ms (SC-004)
- [ ] T080 [P] Add automated integration test: verify balance/expenses survive process death (SC-005, SC-007)
- [ ] T081 [P] Add golden tests for RTL layout compliance on key screens (SC-008)
- [ ] T082 [P] Add CI gate: fail if coverage < thresholds (SC-009)
- [ ] T083 [P] Add CI gate: fail on analyze warnings (SC-010)
- [ ] T084 [P] Add integration test: verify transactional atomicity (balance + audit rollback on failure)
- [ ] T085 [P] Add integration test: verify filters reset on app restart (FR-008a)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-7)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Phase 8)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - May integrate with US1 but should be independently testable
- **User Story 3 (P2)**: Can start after Foundational (Phase 2) - May integrate with US1/US2 but should be independently testable
- **User Story 4 (P2)**: Can start after Foundational (Phase 2) - May integrate with US1/US2/US3 but should be independently testable
- **User Story 5 (P3)**: Can start after Foundational (Phase 2) - Integrates with all but should be independently testable

### Within Each User Story

- Tests (if included) MUST be written and FAIL before implementation
- Models/Repository before Cubit
- Cubit before Views
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Models/Repository within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together (MANDATORY - Constitution Principle II):
Task: "Contract test for SafeCubit balanceStream in test/features/safe/controller/cubit/safe_cubit_balance_stream_test.dart"
Task: "Contract test for SafeCubit expensesStream in test/features/safe/controller/cubit/safe_cubit_expenses_stream_test.dart"
Task: "Unit test for SafeRepository getBalance in test/features/safe/data/repositories/safe_repository_balance_test.dart"
Task: "Unit test for SafeRepository getAllExpenses in test/features/safe/data/repositories/safe_repository_expenses_test.dart"

# Launch implementation models/repo in parallel:
Task: "Create SafeView in lib/features/safe/presentation/views/safe_view.dart"
Task: "Wire SafeView to SafeCubit in lib/features/main/presentation/views/main_view.dart"
```

---

## Parallel Example: User Story 2

```bash
# Launch all tests for User Story 2 together (MANDATORY - Constitution Principle II):
Task: "Contract test for SafeCubit addExpense in test/features/safe/controller/cubit/safe_cubit_add_expense_test.dart"
Task: "Unit test for expense validation in test/features/safe/controller/cubit/safe_cubit_validation_test.dart"
Task: "Unit test for SafeRepository addExpense in test/features/safe/data/repositories/safe_repository_add_expense_test.dart"

# Launch implementation in parallel:
Task: "Create AddExpenseView in lib/features/safe/presentation/views/add_expense_view.dart"
Task: "Wire FAB to AddExpenseView in lib/features/safe/presentation/views/safe_view.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently (quickstart Scenario 1, 3, 8)
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Add User Story 4 → Test independently → Deploy/Demo
6. Add User Story 5 → Test independently → Deploy/Demo
7. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
   - Developer D: User Story 4
3. Stories complete and integrate independently
4. Developer E: User Story 5 (integration contracts) + Polish

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing (TDD per Constitution)
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
- Constitution compliance: `flutter analyze` zero warnings, TDD, Arabic RTL, AppColors/AppTextStyle only, ObjectBox codegen