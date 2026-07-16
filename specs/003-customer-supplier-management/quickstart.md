# Quickstart: Customer Supplier Management

**Feature**: 003-customer-supplier-management
**Date**: 2026-07-16

## Prerequisites

1. Flutter SDK 3.12.2+
2. Dart 3.x
3. Android Studio / VS Code with Flutter extensions
4. Physical device or emulator for testing `url_launcher` (phone dialer)

## Setup

```bash
# 1. Navigate to project
cd E:\inventra

# 2. Add url_launcher dependency (REQUIRED for call feature)
flutter pub add url_launcher

# 3. Get dependencies
flutter pub get

# 4. Run code generation for ObjectBox (if models changed)
dart run build_runner build --delete-conflicting-outputs

# 5. Run the app
flutter run
```

## Manual Test Scenarios

### Test 1: AllCustomersView - Search Customers

**Steps**:
1. Launch app
2. Open drawer (hamburger menu or swipe from right - RTL)
3. Tap "جميع العملاء" (All Customers)
4. Verify screen shows list of customers (or empty state)
5. Type in search bar (e.g., "أحمد")
6. Verify list filters in real-time (300ms debounce)
7. Clear search → verify all customers shown again
8. Search non-existent name → verify "لا يوجد عملاء" message

**Expected**: Smooth search with Arabic RTL layout, case-insensitive matching

---

### Test 2: AllCustomersView - Customer Card Display

**Steps**:
1. Navigate to AllCustomersView
2. Verify each card shows:
   - Customer name (bold)
   - Address (or "لا يوجد عنوان" if null)
   - Phone number (or "لا يوجد هاتف" if null)
   - Call button (phone icon)
   - Edit button (edit icon)
3. Verify RTL layout (text right-aligned, icons on correct sides)

**Expected**: Cards display all fields correctly with Arabic placeholders for nulls

---

### Test 3: AllCustomersView - Call Customer

**Steps**:
1. Navigate to AllCustomersView
2. Find a customer with a phone number
3. Tap call button (phone icon) on their card
4. Verify device dialer opens with the number pre-filled
5. **DO NOT** place actual call - cancel dialer
6. Find a customer WITHOUT phone number
7. Tap call button
8. Verify snackbar shows: "لا يوجد رقم هاتف لهذا العميل"

**Expected**: url_launcher opens dialer correctly; error snackbar for missing phone

---

### Test 4: EditCustomerView - Edit Customer

**Steps**:
1. Navigate to AllCustomersView
2. Tap edit button on any customer card
2. Verify navigation to EditCustomerView
3. Verify form is pre-filled with customer's current data
4. Modify name (ensure ≥3 chars)
5. Modify phone (valid format)
6. Modify address
7. Tap "تعديل العميل" (Save button)
8. Verify snackbar: "تم تعديل العميل بنجاح"
9. Verify return to AllCustomersView
10. Verify updated data shows in list

**Negative Tests**:
- Clear name → tap save → verify inline error "الاسم يجب أن يكون 3 أحرف على الأقل"
- Invalid phone (e.g., "abc") → tap save → verify error "برجاء إدخال رقم هاتف صحيح"
- Clear address → tap save → verify error "برجاء إدخال العنوان"
- Tap back/cancel → verify return to list WITHOUT saving

---

### Test 5: AllSuppliersView - Search Suppliers

**Steps**:
1. Open drawer → Tap "جميع الموردين" (All Suppliers)
2. Verify supplier list loads
3. Search by contact person name
4. Verify real-time filtering
5. Clear → verify all shown
6. Non-existent search → verify empty state

**Expected**: Same search behavior as customers

---

### Test 6: AllSuppliersView - Supplier Card Display

**Steps**:
1. Navigate to AllSuppliersView
2. Verify each card shows:
   - Contact name (name field)
   - Store name (storeName field)
   - Store address (storeAdd or "لا يوجد عنوان")
   - Phone number (or "لا يوجد هاتف")
   - Call button
   - Edit button
3. Verify RTL layout

**Expected**: 4-field display matching SupplierModel structure

---

### Test 7: AllSuppliersView - Call Supplier

**Steps**:
1. Tap call on supplier with phone → verify dialer opens
2. Tap call on supplier without phone → verify snackbar: "لا يوجد رقم هاتف لهذا المورد"

**Expected**: Same call behavior as customers

---

### Test 8: EditSupplierView - Edit Supplier

**Steps**:
1. Navigate to AllSuppliersView
2. Tap edit on supplier card
3. Verify form pre-filled with: name, storeName, storeAdd, phoneNum
4. Modify all fields
5. Tap "تعديل المورد" (Save)
6. Verify success snackbar and return to list
7. Verify updated data in list

**Negative Tests**:
- Empty name → "الاسم يجب أن يكون 3 أحرف على الأقل"
- Empty storeName → "برجاء إدخال اسم المتجر"
- Empty storeAdd → "برجاء إدخال عنوان المتجر"
- Invalid phone → "برجاء إدخال رقم هاتف صحيح"
- Cancel → return without saving

---

### Test 9: Empty States

**Steps**:
1. If database empty (fresh install), navigate to AllCustomersView
2. Verify message: "لا يوجد عملاء"
3. Verify "إضافة عميل" button navigates to AddCustomerView
4. Repeat for AllSuppliersView → "لا يوجد موردين" + "إضافة مورد"

**Expected**: Helpful empty states with action buttons

---

### Test 10: RTL & Constitution Compliance

**Steps**:
1. Verify all text is Arabic
2. Verify RTL layout (Drawer from right, text right-aligned)
3. Verify no hardcoded colors (use AppColors)
4. Verify no hardcoded TextStyles (use AppTextStyle)
5. Verify AppTextField used for all inputs
6. Verify AppButton used for save buttons
7. Verify AppNavigation.pushName for all navigation
8. Verify showSnackBar helper for all snackbars
9. Verify custom widgets use Theme.of(context).cardTheme, inputDecorationTheme, elevatedButtonTheme
10. Verify BlocBuilder uses buildWhen, BlocListener uses listenWhen
11. Verify const constructors used for immutable widgets
12. Verify flutter analyze shows zero errors/warnings
13. Verify flutter build apk --debug compiles without warnings

**Expected**: Full compliance with project conventions and Constitution Principles I-X

---

## Automated Verification Commands

```bash
# Static analysis
flutter analyze

# Run tests (if any exist for this feature)
flutter test

# Build verification
flutter build apk --debug
```

## Expected File Structure After Implementation

```
lib/
├── core/
│   └── utils/
│       ├── validators.dart          # NEW - shared validation
│       └── phone_utils.dart         # NEW - dialer helper
├── features/
│   ├── customers/
│   │   ├── controller/cubit/
│   │   │   ├── customer_state.dart
│   │   │   └── customer_cubit.dart
│   │   └── presentation/
│   │       ├── views/
│   │       │   ├── all_customers_view.dart
│   │       │   └── edit_customer_view.dart
│   │       └── widgets/
│   │           ├── customer_card.dart
│   │           └── customer_search_bar.dart
│   └── suppliers/
│       ├── controller/cubit/
│       │   ├── supplier_state.dart
│       │   └── supplier_cubit.dart
│       └── presentation/
│           ├── views/
│           │   ├── all_suppliers_view.dart
│           │   └── edit_supplier_view.dart
│           └── widgets/
│               ├── supplier_card.dart
│               └── supplier_search_bar.dart
```

## Key Integration Points

1. **AppRoutes** (core/config/configrations.dart):
   - Add `editCustomerView` and `editSupplierView` constants (camelCase)
   - Add cases in `AppRouter.generateRoute()` with model arguments

2. **GetIt Registration** (main.dart):
   - Register `CustomerCubit` and `SupplierCubit` as `LazySingleton`

3. **AppDrawer** (core/widgets/app_drawer.dart):
   - Already has "جميع العملاء" and "جميع الموردين" items pointing to correct routes

4. **Pubspec.yaml**:
   - Add `url_launcher: ^6.2.0` (or latest compatible)

---

## Success Criteria Checklist

- [ ] `url_launcher` added to pubspec.yaml
- [ ] `flutter pub get` runs without errors
- [ ] `dart run build_runner build --delete-conflicting-outputs` succeeds
- [ ] All 8 manual test scenarios pass
- [ ] `flutter analyze` shows no new errors
- [ ] RTL layout correct on all new screens
- [ ] No hardcoded colors/styles in new files
- [ ] AppNavigation/showSnackBar/AppTextField/AppButton used throughout
- [ ] Search debounces at 300ms
- [ ] Edit forms pre-fill correctly from route arguments
- [ ] Validation matches AddCustomerView/AddSupplierView exactly