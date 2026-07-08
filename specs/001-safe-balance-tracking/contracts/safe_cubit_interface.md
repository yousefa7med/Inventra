# SafeCubit Public Contract

This document defines the public interface that other features (Invoices, Returns) will use to integrate with the Safe balance system.

## Interface: SafeCubitInterface

```dart
// lib/features/safe/controller/cubit/safe_cubit_interface.dart

abstract class SafeCubitInterface {
  /// Current balance as reactive stream for UI binding
  Stream<double> get balanceStream;
  
  /// Current balance value (synchronous access)
  double get currentBalance;
  
  /// All expenses as reactive stream
  Stream<List<Expense>> get expensesStream;
  
  /// Current filtered expenses (synchronous)
  List<Expense> get filteredExpenses;
  
  /// Current filter state
  DateTime? get filterFromDate;
  DateTime? get filterToDate;
  String? get searchText;
  
  /// Load initial data (balance + expenses)
  Future<Result<void>> load();
  
  /// Add a new expense
  /// Returns Success(void) or Failure(ValidationError)
  Future<Result<void>> addExpense({
    required double value,
    required String note,
  });
  
  /// Set date range filter (null = no filter)
  void setDateFilter({DateTime? from, DateTime? to});
  
  /// Set search text filter (null/empty = no filter)
  void setSearchFilter(String? text);
  
  /// Clear all filters
  void clearFilters();
  
  /// Manually adjust balance to a specific value
  /// Returns Success(void) or Failure(ValidationError)
  Future<Result<void>> adjustBalance({
    required double newBalance,
    String? note,
  });
  
  /// INTERNAL: Called by other features via GetIt to notify balance changes
  /// from invoices, returns, etc.
  /// 
  /// Parameters:
  /// - amount: The change amount (positive for increase, negative for decrease)
  ///   For manualAdjustment, this is ignored (newBalance is used instead)
  /// - type: The type of transaction causing the change
  /// - referenceId: ID of the source entity (Invoice.id, ReturnReceipt.id, etc.)
  /// - note: Optional description
  Future<Result<void>> adjustBalanceForTransaction({
    required double amount,
    required BalanceChangeType type,
    required int referenceId,
    String? note,
  });
}

/// Type of balance change for audit trail
enum BalanceChangeType {
  expense,           // User added expense
  buyInvoice,        // Buy invoice created (pay supplier)
  sellInvoice,       // Sell invoice created (receive from customer)
  returnReceipt,     // Return receipt created (refund customer)
  manualAdjustment,  // User manually set balance
}
```

## Result Type (for error handling)

```dart
// core/utils/result.dart (existing pattern in project)

sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class Failure<T> extends Result<T> {
  final String message;
  final FailureCode code;
  const Failure(this.message, {this.code = FailureCode.unknown});
}

enum FailureCode {
  validationError,
  notFound,
  databaseError,
  unknown,
}
```

## Integration Usage (for Invoice/Return features)

```dart
// In BuyInvoice feature when saving:
final safeCubit = GetIt.instance<SafeCubit>();
await safeCubit.adjustBalanceForTransaction(
  amount: -invoice.total,  // Negative = decreases balance
  type: BalanceChangeType.buyInvoice,
  referenceId: buyInvoice.id,
  note: 'فاتورة شراء من ${supplier.name}',
);

// In SellInvoice feature when saving:
await safeCubit.adjustBalanceForTransaction(
  amount: invoice.total,  // Positive = increases balance
  type: BalanceChangeType.sellInvoice,
  referenceId: sellInvoice.id,
  note: 'فاتورة بيع لـ ${customer.name}',
);

// In ReturnReceipt feature when saving:
await safeCubit.adjustBalanceForTransaction(
  amount: -receipt.total,  // Negative = decreases balance
  type: BalanceChangeType.returnReceipt,
  referenceId: returnReceipt.id,
  note: 'مرتجع من ${customer.name}',
);
```

## Expected Behavior

| Method | Balance Effect | Audit Entry Created |
|--------|----------------|---------------------|
| `addExpense(value, note)` | balance -= value | type=expense, amount=-value |
| `adjustBalance(newBalance, note)` | balance = newBalance | type=manualAdjustment, amount=delta |
| `adjustBalanceForTransaction(amount, buyInvoice, id, note)` | balance += amount | type=buyInvoice, amount=amount |
| `adjustBalanceForTransaction(amount, sellInvoice, id, note)` | balance += amount | type=sellInvoice, amount=amount |
| `adjustBalanceForTransaction(amount, returnReceipt, id, note)` | balance += amount | type=returnReceipt, amount=amount |

## Error Cases

| Scenario | Return |
|----------|--------|
| Expense value <= 0 | Failure(validationError, "قيمة المصروف يجب أن تكون موجبة") |
| Expense note empty | Failure(validationError, "ملاحظة المصروف مطلوبة") |
| Adjust balance with invalid number | Failure(validationError, "رصيد غير صالح") |
| Database error | Failure(databaseError, "فشل في حفظ البيانات") |
| Reference entity not found (future) | Failure(notFound, "المرجع غير موجود") |