# Quickstart: Operations History Feature

## Overview

Validate the Operations History feature end-to-end by running the app and verifying the Operations tab displays audit entries with filtering and detail view.

---

## Prerequisites

- Flutter SDK 3.22.x (via FVM: `fvm use`)
- Android emulator/device or iOS simulator
- ObjectBox codegen already run (`dart run build_runner build --delete-conflicting-outputs`)
- Dependencies fetched: `flutter pub get`

---

## Setup

```bash
# 1. Ensure you're on the feature branch
git checkout 005-operations-history

# 2. Get dependencies
flutter pub get

# 3. Run codegen (if model changes)
dart run build_runner build --delete-conflicting-outputs

# 4. Run app
flutter run
```

---

## Validation Scenarios

### Scenario 1: Empty State (No Audit Entries)

**Prerequisites**: Fresh app install or cleared ObjectBox data

**Steps**:
1. Launch app
2. Tap **Operations** tab (bottom nav, 3rd icon)
3. Observe empty state

**Expected**:
- Screen shows Arabic message: "لا توجد عمليات مسجلة بعد" (No operations recorded yet)
- Filter button in app bar is visible but disabled/empty
- Pull-to-refresh indicator works (spins, then shows same empty state)

---

### Scenario 2: View All Operations (Default)

**Prerequisites**: Existing data from Safe/Expenses/Sell Invoice/Buy Invoice features

**Steps**:
1. Ensure other features have created audit entries (add expense, create sell invoice, etc.)
2. Open Operations tab
3. Observe list

**Expected**:
- List loads within 1 second
- Entries sorted newest-first (timestamp descending)
- Each item shows: type (Arabic), signed amount (+/−), reference ID, timestamp (Arabic locale), note
- Arabic RTL layout throughout
- Scrolling is smooth (<5% frame drops)

---

### Scenario 3: Filter by Operation Type (Multi-Select)

**Steps**:
1. Tap filter button in app bar (icon: filter_list)
2. Bottom sheet opens with type checkboxes:
   - [ ] مبيعات (Sell Invoice)
   - [ ] مشتريات (Buy Invoice)
   - [ ] مرتجعات (Return Receipt)
   - [ ] مصروفات (Expense)
   - [ ] تعديل يدوي (Manual Adjustment)
3. Select **مصروفات** and **مبيعات**
4. Tap "تطبيق" (Apply) or auto-close on selection
5. Observe filtered list

**Expected**:
- Only Expense and Sell Invoice entries shown
- Filter button shows active count badge (e.g., "2")
- Other types hidden
- List updates within 300ms

---

### Scenario 4: Filter by Date Range (Presets)

**Steps**:
1. Open filter sheet
2. Tap preset: "هذا الأسبوع" (This Week)
3. Apply
4. Verify list shows only entries from current week (Mon–Sun)
5. Change to "هذا الشهر" (This Month)
6. Verify entries from current month
7. Tap "مخصص" (Custom) → pick start/end dates
8. Apply custom range

**Expected**:
- Presets calculate correct date boundaries
- Custom picker shows Arabic Hijri/Gregorian calendar (Material default)
- Future dates clamped to today
- Invalid range (start > end) shows error or auto-swaps

---

### Scenario 5: Combined Filters

**Steps**:
1. Select type: **مشتريات** (Buy Invoice)
2. Select date range: **هذا الشهر** (This Month)
3. Apply

**Expected**:
- Only Buy Invoices from current month shown
- Both filters active simultaneously (intersection)
- Filter badge shows both active (e.g., "1 نوع، هذا الشهر")

---

### Scenario 6: Clear Filters

**Steps**:
1. With active filters, tap "مسح الفلاتر" (Clear Filters) in filter sheet
2. Or tap filter badge in app bar → "مسح الكل"

**Expected**:
- All filters reset (all types, all dates)
- Full list restored
- Badge disappears

---

### Scenario 7: View Operation Detail

**Steps**:
1. Tap any list item
2. Detail dialog opens

**Expected**:
- Dialog/modal shows all fields in Arabic RTL:
  - المعرف (ID)
  - نوع العملية (Type)
  - المبلغ (Amount with sign)
  - معرف المرجع (Reference ID)
  - التاريخ والوقت (Timestamp)
  - الملاحظة (Note or "—")
- Amount shows correct sign/color (green for +, red for −)
- Dialog dismisses on backdrop tap or close button

---

### Scenario 8: Pull-to-Refresh

**Steps**:
1. With data loaded, pull down on list
2. Release to trigger refresh

**Expected**:
- Refresh indicator appears
- Cubit re-queries ObjectBox
- List updates with any new entries from other features
- Indicator dismisses on completion

---

### Scenario 9: Filter Yields No Results

**Steps**:
1. Apply filter that matches no entries (e.g., future date range)
2. Observe list

**Expected**:
- Empty state: "لا توجد عمليات مطابقة للفلاتر" (No operations match filters)
- "مسح الفلاتر" button visible
- Pull-to-refresh still works

---

### Scenario 10: RTL & Arabic Compliance

**Verify throughout all scenarios**:
- [ ] All text in Arabic (no English labels)
- [ ] Layout flows RTL (back button left, icons mirrored)
- [ ] Numbers use Western digits (0-9) with Arabic currency symbol (ر.س)
- [ ] Dates formatted in Arabic locale (yyyy/MM/dd hh:mm a)
- [ ] No hardcoded colors — all via AppColors
- [ ] No hardcoded TextStyles — all via AppTextStyle
- [ ] `flutter analyze` reports zero errors/warnings on new code

---

## Performance Benchmarks (Manual)

| Metric | Target | How to Verify |
|--------|--------|---------------|
| Initial list load (1000 entries) | ≤1s | Stopwatch on first frame after tab tap |
| Type filter apply | ≤300ms | Stopwatch on filter apply tap |
| Date filter apply | ≤300ms | Stopwatch on date apply tap |
| Combined filters | ≤500ms | Stopwatch on combined apply |
| Scroll 1000 items | <5% jank | `flutter run --profile` + DevTools performance tab |

---

## Test Commands

```bash
# Run unit tests (Cubit, Repository)
flutter test test/features/operations/

# Run widget tests
flutter test test/features/operations/presentation/

# Full test suite with coverage
flutter test --coverage

# Analyze
flutter analyze

# Build debug APK
flutter build apk --debug
```

---

## Known Limitations (Per Spec)

- ❌ No real-time updates (manual refresh only)
- ❌ No aggregate totals (sum/count/net) in filtered view
- ❌ No sort order change (fixed newest-first)
- ❌ referenceId not clickable (no navigation to source)
- ❌ No search by note (FR-007 optional, not implemented)

---

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| List empty but data exists | Filter active | Clear filters |
| Arabic text shows squares | Font not loaded | Ensure `flutter_localizations` delegates include Arabic |
| Filter sheet doesn't close | State not updated | Ensure Cubit emits new Loaded state |
| Amount sign wrong | Data entry bug | Check source feature (Safe/Invoices) audit entry creation |
| `flutter analyze` errors | Missing imports/const | Run `dart fix --apply` or fix manually |

---

## Next Steps After Validation

1. If all scenarios pass → ready for `/speckit.tasks` to generate task breakdown
2. If issues found → fix in implementation, re-validate
3. Update CHANGELOG.md under `## [Unreleased]`