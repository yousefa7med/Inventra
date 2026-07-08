# Data Model: Safe Balance Tracking

## Entities

### 1. Expense

**Purpose**: Represents a single expense entry that decreases the safe balance.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `int` | Auto (ObjectBox) | Unique identifier, auto-assigned |
| `date` | `DateTime` | Yes | Date of expense (calendar date, time ignored) |
| `value` | `double` | Yes | Expense amount (positive, 2 decimal places) |
| `note` | `String` | Yes | Description/reason for expense |

**ObjectBox Annotations**:
```dart
@Entity()
class Expense {
  @Id()
  int id = 0;
  
  @Index()
  DateTime date;
  
  double value;
  
  String note;
  
  Expense({required this.date, required this.value, required this.note});
}
```

**Indexes**: `date` (for date range filtering)

**Validation Rules**:
- `value > 0` (positive only)
- `value` precision: 2 decimal places (currency)
- `note` not empty
- `date` not in future (optional business rule)

**Relationships**: Standalone entity. Referenced by `BalanceAuditEntry.referenceId` when type = `expense`.

**Lifecycle**: CREATE only (immutable per FR-007a). No UPDATE/DELETE.

---

### 2. SafeBalance

**Purpose**: Represents the current safe/cash balance. Single-row entity (singleton pattern).

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `int` | Auto | Always 1 (singleton) |
| `currentAmount` | `double` | Yes | Current balance (can be negative) |
| `lastUpdated` | `DateTime` | Yes | Timestamp of last change |

**ObjectBox Annotations**:
```dart
@Entity()
class SafeBalance {
  @Id()
  int id = 1; // Singleton: always id=1
  
  double currentAmount;
  
  DateTime lastUpdated;
  
  SafeBalance({required this.currentAmount, required this.lastUpdated});
}
```

**Validation Rules**:
- Only one record exists (id=1)
- `currentAmount` can be negative (highlighted in UI)
- `lastUpdated` auto-set on every change

**Relationships**: Referenced by `BalanceAuditEntry` implicitly (balance changes)

**Lifecycle**: 
- CREATE on first app run (initial amount = 0)
- UPDATE on every balance change (expense, invoice, return, manual)
- Never DELETE

---

### 3. BalanceAuditEntry

**Purpose**: Immutable audit trail of all balance changes for traceability.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `int` | Auto (ObjectBox) | Unique identifier |
| `type` | `BalanceChangeType` | Yes | Category of change |
| `amount` | `double` | Yes | Change amount (positive for increase, negative for decrease) |
| `referenceId` | `int` | Yes | Links to source entity (Expense.id, Invoice.id, etc.) |
| `timestamp` | `DateTime` | Yes | When change occurred |
| `note` | `String` | Optional | Additional context |

**ObjectBox Annotations**:
```dart
@Entity()
class BalanceAuditEntry {
  @Id()
  int id = 0;
  
  @Index()
  int type; // Enum as int: 0=expense, 1=buyInvoice, 2=sellInvoice, 3=returnReceipt, 4=manualAdjustment
  
  double amount;
  
  int referenceId;
  
  @Index()
  DateTime timestamp;
  
  String? note;
  
  BalanceAuditEntry({
    required this.type,
    required this.amount,
    required this.referenceId,
    required this.timestamp,
    this.note,
  });
}
```

**Indexes**: `type` (for filtering audit by type), `timestamp` (for chronological sorting)

**Validation Rules**:
- `amount != 0`
- `referenceId > 0` (valid reference to source entity)
- `timestamp` not in future
- `type` valid enum value

**Relationships**: 
- `referenceId` → `Expense.id` when type = expense
- `referenceId` → `BuyInvoice.id` when type = buyInvoice
- `referenceId` → `SellInvoice.id` when type = sellInvoice
- `referenceId` → `ReturnReceipt.id` when type = returnReceipt
- `referenceId` = 0 or special when type = manualAdjustment (self-referencing)

**Lifecycle**: CREATE only (immutable audit trail). Never UPDATE/DELETE.

---

## Enum: BalanceChangeType

```dart
enum BalanceChangeType {
  expense,           // - decreases balance
  buyInvoice,        // - decreases balance (pay supplier)
  sellInvoice,       // + increases balance (receive payment)
  returnReceipt,     // - decreases balance (refund customer)
  manualAdjustment,  // = sets balance to specific value
}
```

**Balance Impact**:
| Type | Balance Effect | Amount Sign |
|------|----------------|-------------|
| expense | Decrease | Negative |
| buyInvoice | Decrease | Negative |
| sellInvoice | Increase | Positive |
| returnReceipt | Decrease | Negative |
| manualAdjustment | Set to value | N/A (absolute) |

---

## Repository Contracts

### SafeRepository Interface

```dart
abstract class SafeRepository {
  // Balance
  Future<SafeBalance> getBalance();
  Future<void> updateBalance(double newAmount);
  Future<void> initializeBalance(double initialAmount);
  
  // Expenses
  Future<List<Expense>> getAllExpenses();
  Future<List<Expense>> getExpensesFiltered({
    DateTime? fromDate,
    DateTime? toDate,
    String? searchText,
  });
  Future<void> addExpense(Expense expense);
  Stream<List<Expense>> watchExpenses(); // Reactive query
  
  // Audit
  Future<List<BalanceAuditEntry>> getAuditEntries({BalanceChangeType? type});
  Future<void> addAuditEntry(BalanceAuditEntry entry);
  Stream<List<BalanceAuditEntry>> watchAuditEntries();
}
```

### ObjectBox Implementation Notes

- Use `query().watch()` for reactive streams (not `getAll()` in build)
- Indexes on `Expense.date`, `BalanceAuditEntry.type`, `BalanceAuditEntry.timestamp`
- Transactions for atomic balance update + expense insert + audit entry
- Singleton SafeBalance: `box.get(1) ?? SafeBalance(currentAmount: 0, lastUpdated: DateTime.now())`

---

## State Transitions

### SafeCubit State

```dart
sealed class SafeState {}

class SafeInitial extends SafeState {}

class SafeLoading extends SafeState {}

class SafeLoaded extends SafeState {
  final double balance;
  final List<Expense> expenses;
  final List<Expense> filteredExpenses;
  final DateTime? filterFrom;
  final DateTime? filterTo;
  final String? searchText;
  final bool isNegativeBalance;
  
  SafeLoaded({
    required this.balance,
    required this.expenses,
    required this.filteredExpenses,
    this.filterFrom,
    this.filterTo,
    this.searchText,
    required this.isNegativeBalance,
  });
}

class SafeError extends SafeState {
  final String message;
  SafeError(this.message);
}

class SafeExpenseAdding extends SafeState {
  final SafeLoaded previousState;
  SafeExpenseAdding(this.previousState);
}

class SafeBalanceAdjusting extends SafeState {
  final SafeLoaded previousState;
  SafeBalanceAdjusting(this.previousState);
}
```

### State Transitions

```
SafeInitial → SafeLoading → SafeLoaded
                    ↓
              SafeError (on failure)

SafeLoaded → SafeExpenseAdding → SafeLoaded (on success)
                    ↓
              SafeError (on validation failure)

SafeLoaded → SafeBalanceAdjusting → SafeLoaded (on success)
                    ↓
              SafeError (on failure)
```

### Events (Cubit Methods)

| Method | Trigger | State Transition |
|--------|---------|------------------|
| `load()` | Screen init, pull-to-refresh | SafeLoading → SafeLoaded / SafeError |
| `addExpense(value, note)` | FAB save | SafeExpenseAdding → SafeLoaded / SafeError |
| `setFilter(from, to, search)` | Filter UI change | SafeLoaded → SafeLoaded (rebuild filtered list) |
| `clearFilter()` | Clear button | SafeLoaded → SafeLoaded (show all) |
| `adjustBalance(newBalance, note)` | Adjust button confirm | SafeBalanceAdjusting → SafeLoaded / SafeError |
| `adjustBalanceForTransaction(...)` | Other features (invoice/return) | Background update → SafeLoaded |

---

## Integration Points

### For Invoice/Return Features (Future)

Other features call via GetIt:
```dart
final safeCubit = GetIt.instance<SafeCubit>();

// Buy Invoice created
await safeCubit.adjustBalanceForTransaction(
  amount: invoiceTotal,
  type: BalanceChangeType.buyInvoice,
  referenceId: buyInvoiceId,
  note: 'شراء من مورد: ${supplierName}',
);

// Sell Invoice created
await safeCubit.adjustBalanceForTransaction(
  amount: invoiceTotal,
  type: BalanceChangeType.sellInvoice,
  referenceId: sellInvoiceId,
  note: 'بيع لعميل: ${customerName}',
);

// Return Receipt created
await safeCubit.adjustBalanceForTransaction(
  amount: returnTotal,
  type: BalanceChangeType.returnReceipt,
  referenceId: returnReceiptId,
  note: 'مرتجع من عميل: ${customerName}',
);
```

Each call:
1. Updates SafeBalance.currentAmount (atomic)
2. Creates BalanceAuditEntry
3. Emits new SafeLoaded state