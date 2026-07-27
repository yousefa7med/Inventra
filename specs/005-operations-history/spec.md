# Operations History Feature Specification

## Overview

The Operations History feature provides users with a comprehensive view of all financial operations recorded in the system. Users can view, filter, and search through all balance audit entries (BalanceAuditEntryModel) by operation type and time period. This feature builds upon the existing Safe Balance Tracking system which already records all balance changes as audit entries.

## User Scenarios & Testing

### Primary User Stories

**US-001: View All Operations History**
- As a business owner, I want to see a complete chronological list of all operations (sales, purchases, returns, expenses, manual adjustments) so I can review the full financial activity of my business.
- Acceptance: Opening the Operations screen displays a list of all BalanceAuditEntryModel entries sorted by timestamp (newest first).

**US-002: Filter Operations by Type**
- As a business owner, I want to filter the operations list by type (Sell Invoice, Buy Invoice, Return Receipt, Expense, Manual Adjustment) so I can focus on specific transaction categories.
- Acceptance: A dropdown filter allows selecting one or more BalanceChangeType values; the list updates to show only matching entries.

**US-003: Filter Operations by Time Period**
- As a business owner, I want to filter operations by a date range (start date to end date) so I can review activity for a specific period (day, week, month, custom range).
- Acceptance: Date range picker allows selecting start and end dates; the list shows only entries within the range (inclusive).

**US-004: Combine Type and Date Filters**
- As a business owner, I want to apply both type filter and date range filter simultaneously so I can find specific operations (e.g., "all expenses in January 2025").
- Acceptance: Both filters work together; clearing either resets that filter while preserving the other.

**US-005: View Operation Details**
- As a business owner, I want to tap an operation to see its details (type, amount, reference ID, timestamp, note) so I can verify specific transactions.
- Acceptance: Tapping a list item shows a detail view/dialog with all BalanceAuditEntryModel fields displayed in Arabic RTL format.

### Edge Cases
- Empty state: No operations recorded yet → show empty state message in Arabic
- Filter yields no results → show "No operations found" message with option to clear filters
- Large dataset (1000+ entries) → pagination or lazy loading for performance
- Date range with future end date → clamp to today
- Invalid date range (start > end) → show validation error or auto-swap

## Functional Requirements

### FR-001: Display Operations List
The system SHALL display a list of all BalanceAuditEntryModel entries retrieved from ObjectBox, sorted by timestamp descending (newest first). Each list item SHALL show:
- Operation type (localized Arabic label from BalanceChangeType)
- Amount (formatted as currency with sign: + for increase, - for decrease)
- Reference ID (for linking to source entity)
- Timestamp (date and time in Arabic locale)
- Note (if present)

### FR-002: Filter by Operation Type
The system SHALL provide a dropdown/menu filter allowing users to select one or more BalanceChangeType values:
- sellInvoice (مبيعات)
- buyInvoice (مشتريات)
- returnReceipt (مرتجعات)
- expense (مصروفات)
- manualAdjustment (تعديل يدوي)

Selecting a type SHALL filter the list to show only entries matching the selected type(s). Default: all types shown.

### FR-003: Filter by Date Range
The system SHALL provide a date range picker allowing users to select:
- Start date (inclusive)
- End date (inclusive)

The list SHALL show only entries where timestamp falls within the range. Default: no date filter (all dates).

### FR-004: Combined Filtering
The system SHALL support applying both type filter and date range filter simultaneously. The result set SHALL be the intersection of both filters.

### FR-005: Clear Filters
The system SHALL provide a "Clear Filters" action that resets both type and date filters to their defaults (all types, all dates).

### FR-006: Operation Detail View
The system SHALL allow viewing full details of a selected operation including all BalanceAuditEntryModel fields in a readable Arabic RTL format.

### FR-007: Search by Note (Optional Enhancement)
The system MAY provide a text search field to filter operations by note content (case-insensitive, partial match).

### FR-008: Performance
The system SHALL load and display the initial list (with default filters) within 1 second for up to 1000 entries. Filtering operations SHALL complete within 500ms.

### FR-009: RTL and Arabic Support
All UI text SHALL be in Arabic. Layout SHALL follow RTL direction. Dates SHALL use Arabic locale formatting. Numbers SHALL use Western digits with Arabic currency symbol.

### FR-010: Navigation
The Operations screen SHALL be accessible from the main bottom navigation (Operations tab) and use the standard AppRouter/AppNavigation patterns.

## Key Entities

### BalanceAuditEntryModel (Existing)
| Field | Type | Description |
|-------|------|-------------|
| id | int | Primary key (ObjectBox @Id) |
| type | int | BalanceChangeType enum value (indexed) |
| amount | double | Signed amount (+ increase, - decrease) |
| referenceId | int | Reference to source entity (invoice ID, expense ID, etc.) |
| timestamp | DateTime | When the operation occurred (indexed) |
| note | String? | Optional description |

### BalanceChangeType (Existing Enum)
```
enum BalanceChangeType {
  expense,          // 0 - مصروفات
  buyInvoice,       // 1 - مشتريات
  sellInvoice,      // 2 - مبيعات
  returnReceipt,    // 3 - مرتجعات
  manualAdjustment, // 4 - تعديل يدوي
}
```

## Success Criteria

### Measurable Outcomes
- **SC-001**: Operations list loads within 1 second for 1000 entries
- **SC-002**: Type filter applies within 300ms
- **SC-003**: Date range filter applies within 300ms
- **SC-004**: Combined filters apply within 500ms
- **SC-005**: 100% Arabic RTL compliance
- **SC-006**: Zero errors from `flutter analyze` on new code
- **SC-007**: 80%+ unit test coverage on cubit/controller layer

## Assumptions
- BalanceAuditEntryModel and BalanceChangeType already exist and are populated by existing features (Safe, Sell Invoice, Buy Invoice, Expenses)
- ObjectBox indexes on `type` and `timestamp` already exist (defined in model)
- The Operations feature already has a placeholder screen in the bottom navigation
- No new database entities needed - this is a read-only view of existing data
- Filter state persists for the app session (survives navigation, resets on app restart)

## Clarifications

### Session 2026-07-23

- Q: Should the type filter be single-select or multi-select? → A: Multi-select (checkbox dropdown) for flexibility
- Q: Should date range have presets (Today, This Week, This Month)? → A: Yes, include preset buttons plus custom range
- Q: Should referenceId be clickable to navigate to source entity? → A: Not in scope for this feature (future enhancement)
- Q: How many entries should load initially? → A: Load all (up to 1000), with pagination if performance requires
- Q: Should the filter UI be in the app bar or a separate filter sheet? → A: Filter button in app bar opening a bottom sheet with both filters
- Q: Should the Operations list auto-refresh in real-time when other features add audit entries? → A: No - manual refresh only. List loads once on screen entry; user must pull-to-refresh or revisit to see new entries (read-only history view)
- Q: Should filtered results show aggregate totals (sum, count, net impact)? → A: No - just the list, no summary numbers
- Q: Should users be able to change sort order (oldest first, by amount, by type)? → A: No - fixed newest-first (timestamp descending)