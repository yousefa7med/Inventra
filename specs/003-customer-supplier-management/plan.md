# Implementation Plan: Customer Supplier Management

**Branch**: `003-customer-supplier-management` | **Date**: 2026-07-16 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/003-customer-supplier-management/spec.md`

## Summary

This feature implements Customer and Supplier management screens with search, call, and edit functionality. The feature adds two new screens (AllCustomersView, AllSuppliersView) accessible from the AppDrawer, each with a search bar, customer/supplier cards displaying name/address/phone, call buttons using `url_launcher`, and edit buttons navigating to pre-filled edit forms. Edit forms reuse the exact validation logic from existing AddCustomerView and AddSupplierView forms. State management uses BLoC/Cubit pattern with CustomerCubit and SupplierCubit. The feature requires adding `url_launcher` dependency.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x (SDK ^3.12.2)

**Primary Dependencies**: 
- flutter_bloc ^9.1.1 (state management)
- get_it ^9.2.1 (dependency injection)
- objectbox ^5.3.2 + objectbox_flutter_libs ^5.3.2 (local database)
- flutter_screenutil ^5.9.3 (responsive design)
- persistent_bottom_nav_bar_v2 ^6.3.2 (navigation)
- flutter_svg ^2.3.0 (icons)
- image_picker ^1.2.2 (images)
- shared_preferences ^2.5.5 (caching)
- **NEW**: url_launcher ^6.x (phone dialer integration - MUST ADD)

**Storage**: ObjectBox (local embedded database, no backend)

**Testing**: flutter_test (widget/integration tests), flutter_lints ^6.0.0 (analysis)

**Target Platform**: Android, iOS (mobile app)

**Project Type**: Mobile app (Flutter)

**Performance Goals**: 
- Search results within 300ms (debounced)
- Smooth 60fps scrolling in lists
- App startup < 3 seconds

**Constraints**: 
- Arabic-only locale (RTL), Locale('ar')
- ThemeMode hardcoded to light (dark theme exists but not toggled)
- No network dependency - fully offline
- Must follow existing code conventions: AppNavigation, showSnackBar, AppTextField, AppButton, AppTheme/AppColors/AppTextStyle

**Scale/Scope**: 
- 4 new screens (AllCustomersView, EditCustomerView, AllSuppliersView, EditSupplierView)
- 2 new Cubits (CustomerCubit, SupplierCubit)
- 4 new feature-specific widgets (customer_card, customer_search_bar, supplier_card, supplier_search_bar)
- 2 shared utilities (validators.dart, phone_utils.dart)
- New feature folders: features/customers/, features/suppliers/

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Project follows feature-based architecture (features/*)
- BLoC/Cubit pattern with GetIt DI ✓
- Custom routing (AppRouter/AppNavigation) - no go_router ✓
- Arabic-only RTL with Locale('ar') ✓
- ObjectBox for local storage ✓
- AppTheme/AppColors/AppTextStyle for styling (no hardcoded values) ✓
- AppTextField/AppButton for forms ✓
- No raw Navigator.of(context) / ScaffoldMessenger.of(context) ✓
- url_launcher dependency needs to be added
- **Component themes** (cardTheme, inputDecorationTheme, elevatedButtonTheme) defined in AppTheme and accessed via Theme.of(context) ✓
- **Accessibility**: Arabic semantic labels, 4.5:1 contrast via AppColors, touch targets ≥48dp ✓

## Project Structure

### Documentation (this feature)

```text
specs/003-customer-supplier-management/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (if needed)
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
# Feature-based structure (existing pattern)
lib/
├── core/
│   ├── config/configrations.dart      # AppRouter + AppRoutes (add edit routes)
│   ├── navigations/navigations.dart   # AppNavigation helpers
│   ├── utilities/app_theme.dart       # AppTheme, AppColors, AppTextStyle
│   ├── helper/functions.dart          # showSnackBar helper
│   ├── widgets/
│   │   ├── app_text_field.dart        # AppTextField (existing)
│   │   ├── app_button.dart            # AppButton (existing)
│   │   ├── custom_app_bar.dart        # CustomAppBar (existing)
│   │   └── app_drawer.dart            # AppDrawer (existing - has menu items)
│   ├── models/                        # ObjectBox entities (CustomerModel, SupplierModel exist)
│   └── utils/
│       ├── validators.dart            # NEW - shared validation logic
│       └── phone_utils.dart           # NEW - phone URL launcher helper
├── features/
│   ├── customers/                     # NEW feature folder
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
│   ├── suppliers/                     # NEW feature folder
│   │   ├── controller/cubit/
│   │   │   ├── supplier_state.dart
│   │   │   └── supplier_cubit.dart
│   │   └── presentation/
│   │       ├── views/
│   │       │   ├── all_suppliers_view.dart
│   │       │   └── edit_supplier_view.dart
│   │       └── widgets/
│   │           ├── supplier_card.dart
│   │           └── supplier_search_bar.dart
│   ├── dashboard/                     # EXISTING - has AddCustomerView, AddSupplierView
│   ├── inventory/                     # EXISTING - has ProductCubit, EditProductView pattern
│   ├── selling_invoice/               # EXISTING
│   ├── safe/                          # EXISTING - SafeCubit pattern
│   ├── operations/                    # EXISTING
│   ├── expenses/                      # EXISTING
│   ├── settings/                      # EXISTING
│   └── main/                          # EXISTING - MainView
└── main.dart                          # Entry point, DI setup
```

**Structure Decision**: Following existing feature-based architecture. New features get dedicated folders under `features/` with controller/cubit and presentation/views/widgets subdirectories, mirroring `features/inventory/` and `features/safe/` patterns.

### Architecture Decisions

**Cubit Separation**: CustomerCubit and SupplierCubit are separate (not sharing a base class) because:
- Different model types (CustomerModel vs SupplierModel)
- Different query fields (Customer searches by `name`, Supplier searches by `name` (contact person))
- Different form field counts (3 vs 4 fields)
- YAGNI principle (Constitution V) - abstraction not justified for current complexity

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None - all patterns follow existing conventions | N/A | N/A |
