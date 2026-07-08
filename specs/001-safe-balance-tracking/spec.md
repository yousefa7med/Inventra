# Feature Specification: Safe Balance Tracking

**Feature Branch**: `[001-safe-balance-tracking]`

**Created**: 2026-07-07

**Status**: Draft

**Input**: User description: "lets work on a new feature, the safe (our balance), our work in safe feature folder e:\inventra\lib\features\safe, it will show our balance that change when we make expenses and the expenses is a new entity has following attributes (date, value, note) when we make it the balance will decrease (balance - expenses.value) and also has filter to expenses by date and search by note, we can add new expenses from the floating action buttom that open AddExpensesView that contain the form who take the value and note and after add it the balance will decrease ,balance change also when make a buying/selling invoices and returned recipt (future feature), make also a buttom to modify the balance"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Safe Balance and Expense History (Priority: P1)

The user opens the Safe feature and sees the current balance prominently displayed along with a list of all expenses. The balance reflects the net effect of all recorded transactions.

**Why this priority**: This is the core view - users need to see their current financial position at a glance. Without this, the feature provides no value.

**Independent Test**: Can be fully tested by opening the Safe screen and verifying the balance displays correctly and the expense list shows all recorded expenses with date, value, and note.

**Acceptance Scenarios**:

1. **Given** the user has no expenses recorded, **When** they open the Safe screen, **Then** the balance shows zero and the expense list is empty
2. **Given** the user has recorded multiple expenses, **When** they open the Safe screen, **Then** the balance shows the initial amount minus the sum of all expense values, and the expense list displays all expenses with date, value, and note
3. **Given** the user has both expenses and income from invoices, **When** they open the Safe screen, **Then** the balance reflects the net calculation (initial + invoice income - expenses)

---

### User Story 2 - Add New Expense (Priority: P1)

The user taps the floating action button, enters an expense value and note, confirms, and the expense is recorded while the balance decreases accordingly.

**Why this priority**: Adding expenses is the primary action users will perform. The balance must update immediately to reflect the new expense.

**Independent Test**: Can be fully tested by tapping FAB, entering valid value and note, submitting, and verifying the expense appears in the list and balance decreases by the entered value.

**Acceptance Scenarios**:

1. **Given** the user is on the Safe screen, **When** they tap the FAB, **Then** the Add Expense view opens with fields for value (numeric) and note (text)
2. **Given** the Add Expense view is open, **When** the user enters a valid positive value and note then taps save, **Then** the expense is saved with current date, the view closes, the expense appears in the list, and the balance decreases by the entered value
3. **Given** the Add Expense view is open, **When** the user enters an invalid value (zero, negative, or non-numeric), **Then** validation prevents submission and shows an error message
4. **Given** the Add Expense view is open, **When** the user cancels or navigates back, **Then** no expense is created and the balance remains unchanged

---

### User Story 3 - Filter and Search Expenses (Priority: P2)

The user can filter the expense list by date range and search by note text to find specific expenses quickly.

**Why this priority**: As the expense list grows, users need efficient ways to locate specific entries without scrolling through all records.

**Independent Test**: Can be fully tested by applying a date filter and verifying only expenses within that range appear, and by entering search text and verifying only matching expenses appear.

**Acceptance Scenarios**:

1. **Given** the user has expenses across multiple dates, **When** they apply a date range filter (from/to), **Then** only expenses within that date range are displayed
2. **Given** the user has expenses with various notes, **When** they enter search text in the search field, **Then** only expenses whose notes contain the search text (case-insensitive) are displayed
3. **Given** both a date filter and search text are active, **When** the user views the list, **Then** only expenses matching both criteria are displayed
4. **Given** filters are active, **When** the user clears filters, **Then** all expenses are displayed again

---

### User Story 4 - Manually Adjust Balance (Priority: P2)

The user can tap a button to manually modify the balance (e.g., to correct discrepancies or record opening balance).

**Why this priority**: Real-world cash management requires occasional manual adjustments for corrections, opening balances, or cash deposits/withdrawals not tied to expenses.

**Independent Test**: Can be fully tested by tapping the adjust balance button, entering a new balance value, confirming, and verifying the balance updates to the entered value.

**Acceptance Scenarios**:

1. **Given** the user is on the Safe screen, **When** they tap the "Adjust Balance" button, **Then** a dialog opens allowing entry of a new balance amount
2. **Given** the adjust balance dialog is open, **When** the user enters a valid numeric value and confirms, **Then** the balance updates to the entered value and an audit entry is recorded (type: manual adjustment)
3. **Given** the adjust balance dialog is open, **When** the user cancels, **Then** the balance remains unchanged

---

### User Story 5 - Balance Updates from Invoices and Returns (Priority: P3 - Future Integration)

When buy invoices, sell invoices, or return receipts are created in other features, the safe balance updates automatically (buy/sell invoices affect balance per business rules).

**Why this priority**: This integrates the Safe with core business operations. Marked as P3 since the user noted these are "future features" - the spec should define the interface/contract for this integration.

**Independent Test**: Can be tested by creating an invoice/return in their respective features and verifying the Safe balance reflects the change per business rules.

**Acceptance Scenarios**:

1. **Given** a buy invoice is created (purchase from supplier), **When** the invoice is saved, **Then** the safe balance decreases by the invoice total (per business flow: buy invoice → safe↓)
2. **Given** a sell invoice is created (sale to customer), **When** the invoice is saved, **Then** the safe balance increases by the invoice total (per business flow: sell invoice → safe↑)
3. **Given** a return receipt is created (return from customer), **When** the receipt is saved, **Then** the safe balance decreases by the return total (per business flow: return receipt → safe↓)

---

### Edge Cases

- What happens when the balance would go negative after an expense? → Allow negative balance but highlight it visually (red color per theme)
- What happens when user enters extremely large values? → Validate maximum 999,999,999.99
- What happens if the same expense is added twice? → Allow duplicates (each is a separate record) but show confirmation for identical value+note within 5 seconds
- How does the system handle concurrent modifications? → ObjectBox transactions ensure consistency; last-write-wins for manual balance adjustments
- What happens to filter state when navigating away and back? → Preserve filter state within the session (survives backgrounding, reset on fresh launch)
- How are expenses ordered in the list? → Default: newest first (by date descending)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display the current safe balance prominently on the Safe screen
- **FR-002**: System MUST display a chronological list of all expenses with date, value, and note (newest-first, descending date)
- **FR-003**: System MUST calculate balance as: initial balance + invoice income - expense total - return totals + manual adjustments
- **FR-004**: System MUST allow users to add a new expense via a floating action button opening an input form
- **FR-005**: The expense input form MUST capture: value (required, positive number), note (required, text), and automatically record the current date
- **FR-006**: System MUST validate expense value is a positive number before saving
- **FR-007**: Upon saving an expense, System MUST decrease the balance by the expense value and add the expense to the list
- **FR-007a**: Expenses are immutable once created; System MUST NOT provide edit or delete actions for expenses (corrections via manual balance adjustment)
- **FR-008**: System MUST provide date range filtering for the expense list (from date, to date)
- **FR-009**: System MUST provide text search on expense notes (case-insensitive, partial match, Unicode NFC normalized, diacritic-insensitive for Arabic)
- **FR-010**: System MUST allow combining date filter and text search simultaneously
- **FR-011**: System MUST provide a button to manually adjust the balance to a specific value
- **FR-012**: All balance changes MUST be recorded as audit entries with type (expense, buy_invoice, sell_invoice, return_receipt, manual_adjustment) and a signed amount (negative for decreases, positive for increases; for manual_adjustment: amount = newBalance - oldBalance)
- **FR-013**: System MUST expose two public methods on SafeCubit for other features (invoices, returns) to notify balance changes directly via GetIt:
  - `adjustBalance({required double newBalance, String? note})` — for manual balance adjustments (replaces current balance)
  - `adjustBalanceForTransaction({required double amount, required BalanceChangeType type, required int referenceId, String? note})` — for invoice/return integration (signed amount: negative=decrease, positive=increase)
- **FR-013a**: The integration method `adjustBalanceForTransaction` MUST accept a signed amount (negative=decrease, positive=increase), a type enum (expense, buyInvoice, sellInvoice, returnReceipt, manualAdjustment), and a referenceId linking to the source entity; it MUST be called within the same transaction as the source entity save
- **FR-013b**: Valid type values for integration: expense, buyInvoice, sellInvoice, returnReceipt, manualAdjustment
- **FR-013c**: The complete SafeCubit public interface contract is defined in `contracts/safe_cubit_interface.md` and MUST be implemented by SafeCubit
- **FR-014**: System MUST persist all data using ObjectBox (offline-first, local storage)
- **FR-015**: UI MUST follow Arabic RTL layout with `flutter_screenutil` responsive sizing
- **FR-016**: All colors MUST use `AppColors` and all text styles MUST use `AppTextStyle`
- **FR-017**: Navigation MUST use custom `AppRouter` and `AppNavigation` helpers

### Key Entities

- **Expense**: Represents a single expense entry. Attributes: date (DateTime), value (decimal), note (string). Related to balance calculation (subtracts from balance).
- **Safe Balance**: Represents the current safe/cash balance. Attributes: current amount (decimal), last updated timestamp. Modified by: expenses (decrease), invoices (increase/decrease per type), returns (decrease), manual adjustments (set to value).
- **Balance Audit Entry**: Represents a record of balance changes for traceability. Attributes: type (expense, buy_invoice, sell_invoice, return_receipt, manual_adjustment), amount (decimal, positive or negative), reference ID (link to source entity), timestamp, note.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can view current balance and expense history within 1 second of opening the Safe screen
- **SC-002**: Users can add a new expense and see the updated balance within 2 seconds of tapping save
- **SC-003**: Users can filter 100+ expenses by date range and see results within 500ms
- **SC-004**: Users can search expenses by note and see filtered results within 500ms
- **SC-005**: Manual balance adjustment takes effect immediately and persists across app restarts
- **SC-006**: Balance correctly reflects all transaction types per business rules (verified via integration tests)
- **SC-007**: Zero data loss - all expenses and balance changes persist after app termination
- **SC-008**: 100% RTL layout compliance with Arabic text rendering correctly
- **SC-009**: Feature achieves 90% unit test coverage on controller/cubit layer, 80% on presentation layer
- **SC-010**: `flutter analyze` reports zero errors/warnings for all new code

## Assumptions

- Initial safe balance defaults to 0 (zero) unless a manual adjustment sets it otherwise (always zero on first app launch)
- Expense values are stored as decimal with 2 decimal places precision (currency)
- Date filtering uses calendar date (ignores time component) for simplicity
- Search is case-insensitive, partial match (contains), Unicode NFC normalized, diacritic-insensitive for Arabic
- The "future features" (buy/sell invoices, return receipts) will integrate via direct method calls to SafeCubit: `adjustBalance({newBalance, note})` for manual adjustments, `adjustBalanceForTransaction({amount, type, referenceId, note})` for invoice/return integration with signed amount, called within the same transaction
- Manual balance adjustment replaces the current balance (not additive) - user enters the new total
- Expenses are immutable once created; no edit or delete - corrections made via manual balance adjustment
- ALL balance changes create audit entries (expenses, invoices, returns, manual adjustments) for full traceability with signed amounts (negative=decrease, positive=increase)
- Date range and search filters persist for the app process lifetime (survives backgrounding; reset on fresh app launch)
- All user-facing text will use Arabic localization keys (no hardcoded strings)
- The feature follows existing project patterns: Cubit for state, ObjectBox for persistence, GetIt for DI
- No multi-user or cloud sync - single device, local-only storage
- Performance targets: cold start ≤2s, frame drops <5% (per Constitution)

## Clarifications

### Session 2026-07-07

- Q: When user taps "Adjust Balance", should they enter the NEW TOTAL (replace current balance) or a DELTA (add/subtract from current)? → A: Replace (set to new total)
- Q: How should the initial balance be set when user first opens the app (no prior data)? → A: Always zero
- Q: Can users EDIT or DELETE expenses after creation? → A: No edit/delete
- Q: The spec mentions "callback/event interface in the Safe cubit" for invoice/return integration (P3). What contract style? → A: Direct method call
- Q: FR-012 requires audit entry for manual adjustments. Should ALL balance changes create audit entries (expenses, invoices, returns too)? → A: All changes audited

### Session 2026-07-07 (continued)

- Q: How should the initial safe balance be set when user first opens the app (no prior data)? US1-AS1 says 'configurable default or zero' but Assumptions say 'defaults to 0 unless manual adjustment sets it otherwise'. These conflict. → A: Always zero
- Q: FR-012 requires audit entries for ALL balance changes. Should the audit entry 'amount' field be SIGNED (negative=decrease, positive=increase) or ABSOLUTE with type indicating direction? Data model says 'positive or negative' but FR-014/015/016 use 'decrease by'/'increase by' language. → A: Signed amounts
- Q: FR-013 says SafeCubit exposes `adjustBalance(amount, type, referenceId)` for invoice/return integration. What is the exact contract? Is amount signed or absolute? Is it called within the invoice's transaction? What are valid type values? → A: Signed amount, transactional
- Q: Edge case says 'Preserve filter state within the session' but FR-008/009/010 don't specify. Should filters reset on screen revisit, persist for session, or persist across restarts? → A: Session persistence
- Q: No FR specifies currency formatting for Arabic RTL. Should values use Arabic-Indic digits, Western digits, or device locale? Where does currency symbol go (left/right)? What about decimal/thousand separators? → A: Western digits, Arabic symbol