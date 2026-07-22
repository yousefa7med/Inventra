# Research: Operations History Feature

**Date**: 2026-07-23  
**Feature**: specs/005-operations-history/spec.md  

---

## Research Tasks

### 1. ObjectBox Query Patterns for Filtering

**Question**: How to efficiently query BalanceAuditEntryModel with combined type + date range filters using ObjectBox?

**Findings**: 
- ObjectBox supports `.query()` with multiple conditions: `type` (int index) and `timestamp` (DateTime)
- For multi-select type filter: use `type.isIn(selectedTypeIndexes)` 
- For date range: `timestamp.between(startDate, endDate)`
- Combined: `query.filter(typeCondition).filter(dateCondition).build().find()`
- Indexes already exist on `type` and `timestamp` (defined in BalanceAuditEntryModel with @Index())
- Use `order(BalanceAuditEntryModel_.timestamp, flags: Order.descending)` for newest-first
- For reactive updates: `.watch()` on the query returns Stream<List<BalanceAuditEntryModel>>

**Decision**: Use ObjectBox query builder with combined filters. Since real-time updates are NOT required (clarification: manual refresh only), use `.find()` for initial load and re-query on filter change.

**Rationale**: 
- Simpler than Stream-based reactive approach
- Matches "manual refresh only" clarification
- Efficient with existing indexes
- Consistent with existing SafeRepository.getAuditEntries() pattern

---

### 2. BalanceChangeType Enum Localization

**Question**: How to get Arabic labels for BalanceChangeType enum values in UI?

**Findings**:
- Enum defined in `lib/core/models/balance_change_type.dart`
- Current values: `expense`, `buyInvoice`, `sellInvoice`, `returnReceipt`, `manualAdjustment`
- No existing localization system for enums in the codebase
- Arabic labels needed: expense→مصروفات, buyInvoice→مشتريات, sellInvoice→مبيعات, returnReceipt→مرتجعات, manualAdjustment→تعديل يدوي

**Decision**: Add extension method on BalanceChangeType for Arabic labels in the operations feature (or shared core utilities).

**Rationale**: 
- Keeps localization close to where it's used
- No i18n infrastructure exists yet (Arabic-only hardcoded)
- Simple extension avoids complex localization setup

---

### 3. Date Range Picker for Arabic RTL

**Question**: What date picker to use for Arabic RTL with presets (Today, This Week, This Month)?

**Findings**:
- Flutter's `showDateRangePicker` supports RTL via `MaterialLocalizations.ar`
- Custom presets require building a wrapper widget with preset buttons
- `flutter_screenutil` handles responsive sizing
- Need Hijri/Gregorian consideration — app uses Gregorian (Locale('ar') defaults to Gregorian)

**Decision**: Build custom filter sheet with:
- Preset chips: "اليوم" (Today), "هذا الأسبوع" (This Week), "هذا الشهر" (This Month), "مخصص" (Custom)
- Custom range: two `showDatePicker` calls (start + end) with Arabic locale
- Pre-fill with last 30 days as default

**Rationale**: 
- Better UX than raw date range picker
- Matches Arabic financial app conventions
- Easy to extend with more presets

---

### 4. Pull-to-Refresh Implementation

**Question**: How to implement pull-to-refresh for manual list update?

**Findings**:
- `RefreshIndicator` widget wraps the list
- `onRefresh` callback triggers Cubit to re-query
- Cubit emits loading state, then loaded state with new data
- Must handle "already loading" gracefully (ignore duplicate refresh calls)

**Decision**: Wrap `ListView` in `RefreshIndicator`; Cubit exposes `loadOperations()` method called on refresh.

**Rationale**: 
- Standard Flutter pattern
- Matches "manual refresh only" clarification
- Simple state management

---

### 5. OperationsCubit State Design

**Question**: What states does OperationsCubit need for list + filters + detail?

**Findings**:
- Existing Cubit patterns in codebase: `AppCubit`, `ProductCubit`, `SafeCubit`
- Common states: `Initial`, `Loading`, `Loaded(List<T>)`, `Error(String)`
- Need to track current filters (type selection, date range) for re-query

**Decision**: States:
```dart
sealed class OperationsState {}
class OperationsInitial extends OperationsState {}
class OperationsLoading extends OperationsState {}
class OperationsLoaded extends OperationsState {
  final List<BalanceAuditEntryModel> operations;
  final Set<BalanceChangeType> selectedTypes;
  final DateTimeRange? dateRange;
  OperationsLoaded({required this.operations, required this.selectedTypes, this.dateRange});
}
class OperationsError extends OperationsState {
  final String message;
  OperationsError(this.message);
}
```

**Rationale**: 
- Immutable state with filter values for UI reconstruction
- `Set<BalanceChangeType>` for multi-select
- `DateTimeRange?` for optional date filter

---

### 6. Repository Pattern Integration

**Question**: How to integrate with existing SafeRepository for audit entries?

**Findings**:
- `SafeRepository` interface in `lib/features/safe/data/repositories/safe_repository.dart`
- `SafeRepositoryImpl` in `lib/features/safe/data/repositories/safe_repository_impl.dart`
- Methods: `getAuditEntries({BalanceChangeType? type})`, `watchAuditEntries()`
- Currently supports single type filter, not multi-type or date range
- ObjectBox box accessed via `ObjectBoxServices.balanceAuditEntryBox`

**Decision**: Create `OperationsRepository` that wraps/extends SafeRepository functionality with enhanced queries (multi-type + date range). Keep as separate repository in operations feature for isolation.

**Rationale**: 
- Doesn't modify existing Safe feature
- Operations has different query needs (multi-select, date range)
- Follows feature isolation principle

---

### 7. Performance: 1000+ Entries

**Question**: How to handle large lists without jank?

**Findings**:
- `ListView.builder` with `itemExtent` for fixed-height items
- ObjectBox queries are fast with indexes (~10ms for 1000 entries)
- Avoid `ListView` without builder (loads all at once)
- Consider pagination if >2000 entries (not needed per spec: "up to 1000")

**Decision**: `ListView.builder` with `itemExtent: 80.h` (screenutil), no pagination initially.

**Rationale**: 
- Simple, performs well for 1000 items
- Can add pagination later if needed
- Screenutil ensures consistent sizing

---

## Consolidated Decisions

| Topic | Decision |
|-------|----------|
| Query Strategy | ObjectBox query builder with combined filters, `.find()` on demand |
| Enum Localization | Extension on BalanceChangeType for Arabic labels |
| Date Picker | Custom filter sheet with preset chips + custom range pickers |
| Refresh | RefreshIndicator → Cubit.loadOperations() |
| Cubit State | Initial, Loading, Loaded(operations, types, dateRange), Error |
| Repository | New OperationsRepository wrapping ObjectBox directly for enhanced queries |
| Large Lists | ListView.builder with itemExtent, no pagination initially |

---

## References

- [ObjectBox Query Documentation](https://docs.objectbox.io/queries)
- [Flutter DatePicker RTL](https://api.flutter.dev/flutter/material/showDateRangePicker.html)
- Existing codebase: `lib/features/safe/data/repositories/safe_repository_impl.dart:93`
- Existing codebase: `lib/core/models/balance_change_type.dart`
- Existing codebase: `lib/core/models/balance_audit_entry_model.dart`