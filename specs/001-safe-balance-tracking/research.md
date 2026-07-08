# Research: Safe Balance Tracking

**Date**: 2026-07-07  
**Feature**: Safe Balance Tracking  
**Status**: Complete - All decisions resolved

---

## Research Questions & Decisions

### 1. State Management Pattern

**Question**: What state management pattern should be used for the Safe feature?

**Decision**: BLoC Cubit (flutter_bloc ^9.1.1)

**Rationale**: 
- Constitution Principle V mandates "BLoC Cubits over full Blocs"
- Existing project uses Cubit pattern (AppCubit, ProductCubit)
- Cubit provides simpler API for straightforward state mutations
- Matches team's existing expertise and codebase patterns

**Alternatives Considered**:
- Full Bloc: Rejected - unnecessary complexity for this feature
- Riverpod: Rejected - not in project dependencies, Constitution prohibits new deps without justification
- Provider: Rejected - less structured for complex state transitions
- setState: Rejected - doesn't scale, no testability

---

### 2. Local Persistence

**Question**: What local database should be used for offline-first storage?

**Decision**: ObjectBox ^5.3.2

**Rationale**:
- Constitution Principle V: "NO external backend—ObjectBox is the ONLY persistence"
- ObjectBox provides native Dart/Flutter support with excellent performance
- Built-in code generation via objectbox_generator
- Reactive queries with `watch()` for real-time UI updates
- ACID transactions for atomic balance updates

**Alternatives Considered**:
- SQLite (sqflite): Rejected - slower, manual query writing, no reactive streams
- Hive: Rejected - less performant for complex queries, no indexing
- SharedPreferences: Rejected - only for simple key-value, not relational data
- Drift: Rejected - adds extra dependency, Constitution limits deps

---

### 3. Dependency Injection

**Question**: How should dependencies be registered and accessed?

**Decision**: GetIt ^9.2.1 with LazySingleton registrations

**Rationale**:
- Constitution Principle V: "GetIt singletons over code-gen DI"
- Existing project uses GetIt (main.dart registrations)
- LazySingleton ensures single instance per feature, created on first access
- Simple API, no code generation needed

**Alternatives Considered**:
- Provider/InheritedWidget: Rejected - more boilerplate, less explicit
- Riverpod: Rejected - new dependency
- Manual singleton: Rejected - no lifecycle management

---

### 4. Navigation

**Question**: What navigation solution should be used?

**Decision**: Custom AppRouter + AppNavigation (existing project pattern)

**Rationale**:
- Constitution Principle: "Custom AppRouter + AppNavigation (NO go_router)"
- Existing codebase has established routing in `core/config/configrations.dart`
- Named routes with `AppNavigation.pushName()` helpers
- Custom page transitions already implemented

**Alternatives Considered**:
- go_router: Explicitly forbidden by Constitution
- AutoRoute: Rejected - code generation, new dependency
- Navigator 2.0 direct: Rejected - reinventing existing pattern

---

### 5. Theming & Styling

**Question**: How should theming and styling be handled for Arabic RTL?

**Decision**: AppTheme (light/dark) + AppColors + AppTextStyle exclusively

**Rationale**:
- Constitution Principle IV: "NEVER hardcode colors or TextStyles"
- AppColors provides single source of truth for color palette
- AppTextStyle provides consistent typography scale
- AppTheme composes both into light/dark ThemeData
- flutter_screenutil for responsive sizing (.w, .h, .sp)

**Alternatives Considered**:
- Hardcoded values: Explicitly forbidden
- ThemeExtension: Rejected - adds complexity, existing pattern works
- Flutter's built-in ThemeData only: Rejected - doesn't enforce single source of truth

---

### 6. Localization

**Question**: What localization approach for Arabic-only RTL app?

**Decision**: Hardcoded `Locale('ar')` with flutter_localizations delegates

**Rationale**:
- Constitution: "Hardcoded Arabic locale: `Locale('ar')`"
- No other locales planned (single-market app)
- RTL support automatic via Flutter's directionality
- All user-facing text uses Arabic localization keys (no hardcoded strings)

**Alternatives Considered**:
- Full intl/arb system: Rejected - overkill for single locale
- Dynamic locale switching: Rejected - not needed per requirements

---

### 7. Responsive Design

**Question**: How to handle responsive sizing across devices?

**Decision**: flutter_screenutil ^5.9.3 with design size 360×690

**Rationale**:
- Constitution: "flutter_screenutil initialized with designSize: Size(360, 690)"
- Standard mobile design baseline
- .w, .h, .sp extensions for width, height, font scaling
- Consistent with existing project usage

---

### 8. Testing Strategy

**Question**: What testing frameworks and coverage targets?

**Decision**: flutter_test + bloc_test + mocktail with 90%/80% coverage

**Rationale**:
- Constitution Principle II: "Test-Driven Development is mandatory"
- bloc_test for Cubit state testing
- mocktail for mocking dependencies (Repository, ObjectBox boxes)
- Coverage: 90% for core/cubit layers, 80% for presentation/views
- Integration tests for ObjectBox CRUD, navigation, BLoC transitions

**Alternatives Considered**:
- Integration test package: Rejected - flutter_test covers integration
- patrol: Rejected - new dependency, overkill
- Manual testing only: Rejected - Constitution mandates automated TDD

---

### 9. Entity Code Generation

**Question**: How to handle ObjectBox entity code generation?

**Decision**: build_runner with objectbox_generator

**Rationale**:
- Constitution: "ObjectBox requires codegen" and "NO code generation beyond ObjectBox"
- Run `dart run build_runner build --delete-conflicting-outputs` after model changes
- Generated files: `lib/objectbox.g.dart`, `lib/objectbox-model.json`

---

### 10. Currency Formatting for Arabic RTL

**Question**: How should monetary values be formatted in Arabic RTL context?

**Decision**: Western digits (0-9) with Arabic currency symbol (ر.س) on the right, dot decimal separator, comma thousand separator

**Rationale**:
- Clarification session decision: "Western digits, Arabic symbol"
- Example: `1,234.50 ر.س`
- Most Arabic-speaking regions accept Western digits for currency
- Easier implementation with Dart's NumberFormat
- Currency symbol on right follows RTL convention

**Alternatives Considered**:
- Arabic-Indic digits (٠١٢٣٤٥٦٧٨٩): Rejected - complex implementation, less common in financial apps
- Device locale dependent: Rejected - inconsistent UX

---

### 11. Filter State Persistence

**Question**: Should date range and search filters persist across app sessions?

**Decision**: Session persistence only (reset on fresh app launch)

**Rationale**:
- Clarification session decision: "Session persistence"
- Filters are transient UI state, not user preferences
- Reduces complexity (no SharedPreferences needed for filters)
- Fresh start each session matches typical expense tracking workflow

**Alternatives Considered**:
- Full persistence (SharedPreferences): Rejected - over-engineering for transient filters
- No persistence (reset on navigation): Rejected - poor UX when switching tabs

---

### 12. Integration Contract for Invoices/Returns

**Question**: How will future Invoice/Return features integrate with Safe balance?

**Decision**: Direct method call on SafeCubit via GetIt with signed amount, called within same transaction

**Rationale**:
- Clarification session decision: "Signed amount, transactional"
- Method: `adjustBalanceForTransaction(amount, type, referenceId, note)`
- Signed amount: negative=decrease, positive=increase
- Called within invoice/return save transaction for atomicity
- Type enum: expense, buyInvoice, sellInvoice, returnReceipt, manualAdjustment
- Creates audit entry automatically

---

### 13. Audit Entry Amount Convention

**Question**: Should audit entry amounts be signed or absolute with type indicating direction?

**Decision**: Signed amounts (negative=decrease, positive=increase)

**Rationale**:
- Clarification session decision: "Signed amounts"
- Simplifies balance calculation (sum of all audit amounts = net change)
- Consistent with data model showing "amount (decimal, positive or negative)"
- Easier querying and reporting

---

### 14. Initial Balance Behavior

**Question**: What should the initial safe balance be on first app launch?

**Decision**: Always zero (0)

**Rationale**:
- Clarification session decision: "Always zero"
- Resolves conflict between US1-AS1 ("configurable default or zero") and Assumptions
- User can set opening balance via "Adjust Balance" button
- Simplest behavior, no first-run wizard needed

---

### 15. Expense Immutability

**Question**: Can users edit or delete expenses after creation?

**Decision**: No edit/delete - expenses are immutable

**Rationale**:
- Clarification session decision: "No edit/delete"
- Financial records should be immutable for audit integrity
- Corrections made via manual balance adjustment with audit trail
- Simplifies data model (no UPDATE/DELETE operations)

---

## Summary

All technical decisions have been resolved through Constitution mandates and clarification sessions. No NEEDS CLARIFICATION items remain. The feature is ready for implementation with clear patterns established by the existing codebase and Constitution.