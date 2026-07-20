# Quickstart: Buying Invoice Feature

**Date**: 2026-07-20 | **Spec**: [spec.md](spec.md)

## Prerequisites

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs  # If models changed
flutter run
```

## Manual Validation Scenarios

### 1. Create Buying Invoice (Happy Path)

**Steps**:
1. Open app → side drawer → tap **"فواتير المشتريات"**
2. Verify navigation to Buying Invoice form
3. Tap supplier dropdown → search/select existing supplier (e.g., "مورد الاختبار")
4. Tap FAB (floating action button) → opens Product Selection view
5. Search for existing product → tap to add (qty=0 initially)
6. Use quantity counter to set qty > 0 (e.g., 5)
7. Tap FAB in Product Selection → create new product (name, barcode, prices)
8. Return to Product Selection → new product appears, set qty
9. Tap back/confirm → back to Buying Invoice form with items listed
10. Verify totals card shows correct subtotal
11. Tap **"تأكيد الفاتورة"** (Confirm Invoice)
12. Verify success snackbar: "تم اضافة الفاتورة بنجاح"
13. Verify form resets (supplier cleared, items cleared)
14. Open Inventory → verify product quantities increased by invoice quantities
15. Open Safe (خزنة) → verify balance decreased by invoice total

**Expected**: Invoice created, inventory↑, safe↓, form reset.

---

### 2. Restock with Price Change

**Steps**:
1. Start new buying invoice, select supplier
2. Open Product Selection → pick existing product (e.g., "منتج أ" with buyingPrice=10)
3. In invoice, item shows unitPrice=10 (current buyingPrice)
4. Manually change unit price in item to 12 (or via edit flow)
5. Or: Product Selection shows different price → triggers dialog
6. Verify dialog: "السعر تغير. تحديث سعر الشراء للمنتج؟" with current vs new
7. Tap **"تحديث السعر"** → product.buyingPrice updated to 12 in inventory
8. Complete invoice
9. Open Inventory → verify product buyingPrice = 12

**Expected**: Price change confirmed → product buyingPrice updated.

---

### 3. Cancel Price Change

**Steps**:
1. Same as above but tap **"الاحتفاظ بالسعر الحالي"** in dialog
2. Complete invoice
3. Open Inventory → verify product buyingPrice unchanged (still 10)

**Expected**: Price change rejected → product keeps original price.

---

### 4. Validation Errors

| Test | Steps | Expected Error |
|------|-------|----------------|
| No supplier | Skip step 3 above, tap confirm | "يرجى اختيار مورد" |
| No items with qty > 0 | Select supplier, don't add items, confirm | "يرجى إضافة منتج واحد على الأقل بكمية أكبر من صفر" |
| Insufficient safe balance | Create invoice with total > safe balance | "رصيد الخزنة غير كافٍ" |

---

### 5. Supplier Dropdown Search

**Steps**:
1. Open Buying Invoice form
2. Tap supplier dropdown
3. Type Arabic name (with/without diacritics, e.g., "مورد" vs "مُوَرِّد")
4. Verify matching supplier appears
5. Type non-matching text → verify selection clears

**Expected**: Arabic-normalized search works, clears on no match.

---

### 6. Product Selection Search

**Steps**:
1. Tap FAB → Product Selection view
2. Search by product name (Arabic)
3. Search by barcode
4. Clear search → all products shown
5. Verify quantity counters default to 0
6. Increment counter → item added to invoice on return

**Expected**: Search works, qty default 0, only qty>0 items added.

---

## Automated Tests (Run Commands)

```bash
# Unit tests
flutter test test/features/buying_invoice/

# Widget tests
flutter test test/features/buying_invoice/

# Integration test (if added)
flutter test integration_test/buying_invoice_test.dart

# Analyze
flutter analyze

# Build
flutter build apk --debug
```

## Related Files

- [spec.md](spec.md) — Feature specification
- [data-model.md](data-model.md) — Entity definitions
- [contracts/buy_invoice_repository.md](contracts/buy_invoice_repository.md) — Repository contract
- [contracts/buy_invoice_cubit_interface.md](contracts/buy_invoice_cubit_interface.md) — Cubit contract