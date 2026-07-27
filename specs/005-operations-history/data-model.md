# Data Model: Operations History

## Entities

### BalanceAuditEntryModel (Existing — Read Only)

**Source**: `lib/core/models/balance_audit_entry_model.dart`

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | int | @Id, auto-assign | Primary key |
| type | int | @Index, required | BalanceChangeType enum value (0-4) |
| amount | double | required | Signed amount: + for increase, - for decrease |
| referenceId | int | required | Source entity ID (invoice, expense, etc.) |
| timestamp | DateTime | @Index, required | Operation occurrence time |
| note | String? | optional | User-provided description |

**Indexes** (already defined in model):
- `type` — for filtering by operation type
- `timestamp` — for date range queries and default sorting

**Relationships**: None (standalone audit log entity). `referenceId` is a logical reference only, not an ObjectBox relation.

---

### BalanceChangeType (Existing Enum)

**Source**: `lib/core/models/balance_change_type.dart`

```dart
enum BalanceChangeType {
  expense,          // 0 - مصروفات
  buyInvoice,       // 1 - مشتريات
  sellInvoice,      // 2 - مبيعات
  returnReceipt,    // 3 - مرتجعات
  manualAdjustment, // 4 - تعديل يدوي
}
```

**Arabic Labels** (extension for UI):

| Enum Value | Arabic Label | English |
|------------|--------------|---------|
| expense | مصروفات | Expense |
| buyInvoice | مشتريات | Buy Invoice |
| sellInvoice | مبيعات | Sell Invoice |
| returnReceipt | مرتجعات | Return Receipt |
| manualAdjustment | تعديل يدوي | Manual Adjustment |

---

## View State (Cubit)

### OperationsState (Sealed Class Hierarchy)

```dart
sealed class OperationsState {}

class OperationsInitial extends OperationsState {}

class OperationsLoading extends OperationsState {}

class OperationsLoaded extends OperationsState {
  final List<BalanceAuditEntryModel> operations;
  final Set<BalanceChangeType> selectedTypes;      // active type filter
  final DateTimeRange? dateRange;                   // active date filter
  OperationsLoaded({
    required this.operations,
    required this.selectedTypes,
    this.dateRange,
  });
}

class OperationsError extends OperationsState {
  final String message;
  OperationsError(this.message);
}
```

### Filter State Persistence

- **Scope**: App session (survives navigation, resets on app restart)
- **Storage**: In-memory in Cubit (no persistence needed per spec)

---

## Query Patterns

### Default Query (All Operations)
```dart
box<BalanceAuditEntryModel>()
  .query()
  .order(BalanceAuditEntryModel_.timestamp, flags: Order.descending)
  .find()
```

### Filtered by Type(s)
```dart
box<BalanceAuditEntryModel>()
  .query()
  .inInt32(BalanceAuditEntryModel_.type, selectedTypes.map((e) => e.index).toList())
  .order(BalanceAuditEntryModel_.timestamp, flags: Order.descending)
  .find()
```

### Filtered by Date Range
```dart
box<BalanceAuditEntryModel>()
  .query()
  .between(BalanceAuditEntryModel_.timestamp, start, end)
  .order(BalanceAuditEntryModel_.timestamp, flags: Order.descending)
  .find()
```

### Combined (Type + Date)
```dart
box<BalanceAuditEntryModel>()
  .query()
  .inInt32(BalanceAuditEntryModel_.type, typeIndices)
  .between(BalanceAuditEntryModel_.timestamp, start, end)
  .order(BalanceAuditEntryModel_.timestamp, flags: Order.descending)
  .find()
```

---

## UI Data Mapping

### OperationListItem (Display Model)

| Source Field | Display Format |
|--------------|----------------|
| type | Arabic label via `BalanceChangeType.arabicLabel` |
| amount | `formatCurrency(amount)` with +/− prefix (e.g., "+ ١٬٢٥٠.٠٠ ر.س" / "− ٣٠٠.٠٠ ر.س") |
| referenceId | `#${referenceId}` (or "—" if 0) |
| timestamp | `formatDate(timestamp, locale: 'ar')` → "٢٠٢٥/٠١/١٥ ٠٣:٤٥ م" |
| note | As-is (or "—" if null/empty) |

### OperationDetailDialog (Full Fields)

| Field | Label (Arabic) |
|-------|----------------|
| id | المعرف |
| type | نوع العملية |
| amount | المبلغ |
| referenceId | معرف المرجع |
| timestamp | التاريخ والوقت |
| note | الملاحظة |

---

## No New Entities Required

This feature is a **read-only view** of existing `BalanceAuditEntryModel` data. No ObjectBox model changes, no `build_runner` invocation needed.

---

## Validation Rules (UI-Level)

| Field | Rule |
|-------|------|
| type filter | At least one type must be selected if filter is active |
| date range | start ≤ end; end ≤ today (clamped) |
| amount display | Always show sign (+/−), 2 decimal places, Arabic locale formatting |

---

## References

- Entity definition: `lib/core/models/balance_audit_entry_model.dart`
- Enum definition: `lib/core/models/balance_change_type.dart`
- Existing repository: `lib/features/safe/data/repositories/safe_repository_impl.dart` (lines 93, 105, 110)
- ObjectBox generated: `lib/objectbox.g.dart` (query fields)