# Quickstart Validation Guide: Safe Balance Tracking

This guide provides runnable validation scenarios to verify the Safe Balance Tracking feature works end-to-end.

## Prerequisites

```bash
# 1. Get dependencies
flutter pub get

# 2. Run ObjectBox codegen (required after model changes)
dart run build_runner build --delete-conflicting-outputs

# 3. Run app
flutter run
```

## Validation Scenarios

### Scenario 1: Initial State - Empty Safe
**Goal**: Verify fresh app shows balance = 0 and empty expense list

**Steps**:
1. Launch app (first run or after clearing data)
2. Navigate to Safe tab (bottom nav index 2 - Inventory? Verify routing)
3. Observe balance display

**Expected**:
- Balance shows "0.00" (or configured currency format)
- Expense list is empty
- FAB visible for adding expense
- Adjust Balance button visible

---

### Scenario 2: Add First Expense
**Goal**: Verify expense creation decreases balance and appears in list

**Steps**:
1. From Safe screen, tap FAB (+)
2. Enter value: `150.50`
3. Enter note: `مصاريف نقل`
4. Tap Save
5. Observe balance and list

**Expected**:
- Balance shows `-150.50` (negative, highlighted in red per theme)
- Expense list shows one entry: date=today, value=150.50, note="مصاريف نقل"
- Audit entry created (type=expense, amount=-150.50)

---

### Scenario 3: Multiple Expenses - Balance Calculation
**Goal**: Verify balance = sum of all expenses (negative)

**Steps**:
1. Add expense: `200.00`, note: `إيجار`
2. Add expense: `75.25`, note: `كهرباء`
3. Add expense: `300.00`, note: `رواتب`

**Expected**:
- Balance = `-725.75` (150.50 + 200 + 75.25 + 300)
- List shows 4 expenses, newest first
- All audit entries present

---

### Scenario 4: Date Range Filter
**Goal**: Verify filtering expenses by date range

**Setup**: Have expenses across multiple days (add some, change device date, add more)

**Steps**:
1. Tap filter icon/button
2. Set "From" date to 2 days ago
3. Set "To" date to today
4. Apply filter

**Expected**:
- Only expenses within date range shown
- Balance still shows TOTAL (all time) - not filtered
- Filter chips/indicators visible

---

### Scenario 5: Note Search
**Goal**: Verify text search on expense notes

**Steps**:
1. In search field, type: `نقل`
2. Observe list

**Expected**:
- Only expenses with "نقل" in note shown (case-insensitive)
- Search works with partial match
- Clear search (X button) restores full list

---

### Scenario 6: Combined Filter + Search
**Goal**: Verify both filters work together

**Steps**:
1. Set date range: last 7 days
2. Search for: `كهرباء`
3. Observe list

**Expected**:
- Only expenses matching BOTH criteria shown

---

### Scenario 7: Manual Balance Adjustment
**Goal**: Verify user can set balance to specific value

**Steps**:
1. Tap "Adjust Balance" button
2. Enter: `5000.00`
3. Optional note: `رصيد افتتاحي`
4. Confirm

**Expected**:
- Balance immediately shows `5000.00`
- Audit entry created: type=manualAdjustment, amount=+5725.75 (delta from -725.75)
- Note saved with audit entry
- Previous expenses unchanged

---

### Scenario 8: Negative Balance Visual
**Goal**: Verify negative balance highlighted

**Steps**:
1. Ensure balance is negative (add expenses > income)
2. Observe balance display

**Expected**:
- Balance text color = AppColors.error (red) or similar per theme
- RTL layout maintained

---

### Scenario 9: Persistence Across Restart
**Goal**: Verify data survives app termination

**Steps**:
1. Add several expenses, adjust balance
2. Fully close app (swipe away from recent apps)
3. Reopen app
4. Navigate to Safe

**Expected**:
- Balance matches last state
- All expenses present
- Filters reset (session-only)
- Audit trail complete

---

### Scenario 10: Integration Contract Test (Future)
**Goal**: Verify SafeCubit interface for invoice integration

**Setup**: Mock or create test invoices in other features

**Steps**:
1. Call `safeCubit.adjustBalanceForTransaction(amount: -1000, type: buyInvoice, referenceId: 1, note: 'test')`
2. Verify balance decreases by 1000
3. Call `safeCubit.adjustBalanceForTransaction(amount: 2500, type: sellInvoice, referenceId: 2, note: 'test')`
4. Verify balance increases by 2500
5. Call `safeCubit.adjustBalanceForTransaction(amount: -300, type: returnReceipt, referenceId: 3, note: 'test')`
6. Verify balance decreases by 300

**Expected**:
- Each call updates balance correctly per type
- Audit entries created with correct type, amount, referenceId
- Balance stream emits new values

---

### Scenario 11: Validation Errors
**Goal**: Verify input validation prevents invalid data

**Test Cases**:
| Input | Expected Error |
|-------|----------------|
| Value = 0 | "قيمة المصروف يجب أن تكون موجبة" |
| Value = -50 | "قيمة المصروف يجب أن تكون موجبة" |
| Value = "abc" | "قيمة غير صالحة" |
| Note = "" | "ملاحظة المصروف مطلوبة" |
| Adjust balance = "xyz" | "رصيد غير صالح" |

**Expected**: Error message shown, no state change, no audit entry

---

### Scenario 12: Arabic RTL Layout
**Goal**: Verify full RTL compliance

**Checks**:
- [ ] Balance label right-aligned, value left-aligned
- [ ] Expense list: date right, value left, note right
- [ ] FAB positioned bottom-left (RTL)
- [ ] Filter/search icons mirrored
- [ ] Date picker RTL calendar
- [ ] Text direction never hardcoded to LTR
- [ ] AppColors/AppTextStyle used throughout

---

### Scenario 13: Performance
**Goal**: Verify performance targets

**Test**: Add 500 expenses, then:
- Open Safe screen → balance + list renders < 1s
- Apply date filter → results < 500ms
- Search text → results < 500ms
- Scroll list → 60fps, no jank

**Tools**: `flutter run --profile --trace-startup`, DevTools performance tab

---

## Test Commands

```bash
# Unit tests (Cubit, Repository)
flutter test test/features/safe/

# Integration tests (full flow)
flutter test test/integration/safe_test.dart

# Coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Analyze
flutter analyze

# Build verification
flutter build apk --debug
```

## Definition of Done Checklist

- [ ] All 13 scenarios pass manually
- [ ] Unit tests: 90%+ coverage on Cubit/Repository
- [ ] Integration tests: all user stories covered
- [ ] `flutter analyze` = 0 errors, 0 warnings
- [ ] RTL smoke test on device/emulator
- [ ] Performance: no jank frames in profile build
- [ ] CHANGELOG.md updated under `## [Unreleased]`
- [ ] ObjectBox models generated (`build_runner` run)