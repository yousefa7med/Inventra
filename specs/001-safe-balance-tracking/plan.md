# Implementation Plan: Safe Balance Tracking

**Branch**: `[001-safe-balance-tracking]` | **Date**: 2026-07-07 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-safe-balance-tracking/spec.md`

## Summary

Implement a Safe (cash balance) feature with expense tracking in the existing `lib/features/safe` folder. The feature displays current balance, manages expenses (date, value, note), supports date filtering and note search, allows manual balance adjustment, and provides an integration interface for future invoice/return features. Built with Flutter 3.22, BLoC Cubit, ObjectBox, GetIt DI, following Arabic RTL design system.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.22.x (pinned in `.fvm/fvm_config.json`)

**Primary Dependencies**:
- `flutter_bloc` ^9.1.1 (Cubit pattern only)
- `objectbox` ^5.3.2 + `objectbox_generator` (codegen mandatory)
- `get_it` ^9.2.1 (LazySingleton registrations)
- `flutter_screenutil` ^5.9.3 (design size 360×690)
- `persistent_bottom_nav_bar_v2` ^6.3.2
- `flutter_svg` ^2.3.0
- `shared_preferences` ^2.5.5

**Storage**: ObjectBox (local, offline-first, no backend)

**Testing**: `flutter_test` + `bloc_test` + `mocktail` (unit: 90% cubit, 80% views; integration: ObjectBox CRUD, navigation, BLoC transitions)

**Target Platform**: Android (primary), iOS (secondary) - mobile app

**Project Type**: Mobile app (Flutter)

**Performance Goals**:
- Cold start ≤2s on mid-range Android (Snapdragon 680 / 4GB RAM)
- Frame drops <5% during scroll-heavy screens
- View balance/history ≤1s
- Add expense + balance update ≤2s
- Filter 100+ expenses ≤500ms
- Search expenses ≤500ms

**Constraints**:
- Arabic-only RTL (`Locale('ar')`)
- No hardcoded colors (use `AppColors`) or TextStyles (use `AppTextStyle`)
- Custom `AppRouter` + `AppNavigation` (NO go_router)
- ObjectBox codegen required after model changes (`build_runner`)
- DI order: CacheHelper before ObjectBoxServices
- Zero `flutter analyze` warnings

**Scale/Scope**:
- Single feature module: `lib/features/safe`
- 3 ObjectBox entities: Expense, SafeBalance, BalanceAuditEntry
- 2 presentation screens: SafeView, AddExpenseView
- 1 Cubit: SafeCubit
- Integration points for future: BuyInvoice, SellInvoice, ReturnReceipt features

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Code Quality & Maintainability | ✅ PASS | Feature module in `features/safe`, single-responsibility, GetIt DI, error handling via Result/Either |
| II. Test-First Discipline | ✅ PASS | TDD mandatory, 90%/80% coverage targets, integration tests for ObjectBox/navigation/BLoC |
| III. UX Consistency (Arabic RTL) | ✅ PASS | RTL only, Arabic localization keys, AppTheme, screenutil, PersistentBottomNavBarV2, AppRouter transitions |
| IV. Visual Consistency | ✅ PASS | AppColors + AppTextStyle only, no hardcoded values |
| IV. Performance | ✅ PASS | ≤2s startup, <5% jank, ObjectBox indexes + watch(), no getAll() in build |
| V. Architectural Simplicity | ✅ PASS | Cubit over Bloc, feature folder, GetIt singleton, ObjectBox only, no extra codegen |

**All gates pass. No violations requiring justification.**

## Project Structure

### Documentation (this feature)

```text
specs/001-safe-balance-tracking/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (internal method contracts)
└── tasks.md             # Phase 2 output (future /speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── models/
│   │   ├── expense.dart              # NEW: Expense entity
│   │   ├── safe_balance.dart         # NEW: SafeBalance entity
│   │   ├── balance_audit_entry.dart  # NEW: BalanceAuditEntry entity
│   │   └── ...existing models...
│   ├── controller/
│   │   └── controllers/
│   │       └── app_cubit/            # Existing
│   └── utilities/
│       ├── app_theme.dart            # Existing
│       ├── app_colors.dart           # Existing
│       └── app_text_style.dart       # Existing
├── features/
│   ├── safe/                         # NEW FEATURE MODULE
│   │   ├── controller/
│   │   │   └── cubit/
│   │   │       ├── safe_cubit.dart
│   │   │       └── safe_state.dart
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── safe_repository.dart
│   │   └── presentation/
│   │       └── views/
│   │           ├── safe_view.dart
│   │           └── add_expense_view.dart
│   ├── inventory/                    # Existing
│   ├── dashboard/                    # Existing
│   ├── operations/                   # Existing
│   ├── expenses/                     # Existing (different from safe expenses)
│   ├── settings/                     # Existing
│   └── main/                         # Existing (MainView with bottom nav)
├── main.dart                         # Existing (DI registration)
└── objectbox.g.dart                  # Generated (updated after model changes)
```

**Structure Decision**: Feature-based module under `lib/features/safe` following existing pattern. New ObjectBox entities added to `core/models/`. Cubit registered as LazySingleton in `main.dart`. Routes added to `AppRoutes` and `AppRouter`.

## Complexity Tracking

No Constitution violations - all gates pass. Standard feature implementation within existing architecture.

---

## Phase 0: Research

All technical decisions resolved from spec and constitution. No NEEDS CLARIFICATION remains.

### Research Findings Summary

| Topic | Decision | Rationale |
|-------|----------|-----------|
| State Management | BLoC Cubit (flutter_bloc 9.1.1) | Constitution mandates Cubit pattern; matches existing AppCubit, ProductCubit |
| Persistence | ObjectBox 5.3.2 | Constitution: ONLY persistence, codegen mandatory |
| DI | GetIt 9.2.1 LazySingleton | Constitution: GetIt singletons in main.dart |
| Navigation | Custom AppRouter + AppNavigation | Constitution: NO go_router |
| Theming | AppTheme (light/dark) + AppColors + AppTextStyle | Constitution: NEVER hardcode colors/styles |
| Localization | Arabic only (Locale('ar')) | Constitution: hardcoded Arabic, RTL |
| Responsive | flutter_screenutil 5.9.3 (360×690) | Constitution: design size fixed |
| Testing | flutter_test + bloc_test + mocktail | Constitution: TDD, coverage targets |
| Entity Codegen | build_runner after model changes | Constitution: ObjectBox requires codegen |

---

## Phase 1: Design & Contracts

### 1. Data Model (`data-model.md`)

See [data-model.md](data-model.md) for complete entity definitions, relationships, validation rules, and state transitions.

### 2. Internal Contracts (`contracts/`)

**SafeCubit Public Interface** (for future invoice/return integration):

```dart
// lib/features/safe/controller/cubit/safe_cubit.dart
abstract class SafeCubitInterface {
  // Balance
  Stream<double> get balanceStream;
  double get currentBalance;
  
  // Expenses
  Stream<List<Expense>> get expensesStream;
  List<Expense> get currentExpenses;
  Future<Result<void>> addExpense({required double value, required String note});
  Future<Result<void>> loadExpenses();
  Future<Result<void>> loadExpensesFiltered({DateTime? from, DateTime? to, String? searchText});
  
  // Manual Adjustment
  Future<Result<void>> adjustBalance({required double newBalance, String? note});
  
  // Integration (called by other features via GetIt)
  Future<Result<void>> adjustBalanceForTransaction({
    required double amount,
    required BalanceChangeType type,
    required int referenceId,
    String? note,
  });
}

enum BalanceChangeType {
  expense,
  buyInvoice,
  sellInvoice,
  returnReceipt,
  manualAdjustment,
}
```

### 3. Quickstart Guide (`quickstart.md`)

See [quickstart.md](quickstart.md) for validation scenarios.

---

## Phase 2: Task Generation

Run `/speckit.tasks` to generate detailed implementation tasks from this plan.