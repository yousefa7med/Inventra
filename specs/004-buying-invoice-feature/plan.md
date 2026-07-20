# Implementation Plan: Buying Invoice Feature

**Branch**: `feature/buying-invoice-feature` | **Date**: 2026-07-20 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/004-buying-invoice-feature/spec.md`

## Summary

Implement buying invoice functionality for purchasing products from suppliers. Mirrors the existing selling invoice feature but with inverse business logic: inventory increases and safe balance decreases. Includes supplier selection dropdown (like CustomerDropdownMenu), product selection view with quantity counters (default 0), FAB to add new products, and price change confirmation dialog when restocking existing products.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.22.x (pinned in `.fvm/fvm_config.json`)

**Primary Dependencies**: 
- `flutter_bloc` ^9.1.1 (Cubit pattern)
- `objectbox` ^5.3.2 + `objectbox_generator` (dev)
- `get_it` ^9.2.1 (DI)
- `flutter_screenutil` ^5.9.3 (responsive)
- `persistent_bottom_nav_bar_v2` ^6.3.2 (navigation)

**Storage**: ObjectBox (local embedded database, no backend)

**Testing**: `flutter_test` (unit/widget), `integration_test` (integration)

**Target Platform**: Android (primary), iOS (secondary) — mobile app

**Project Type**: Mobile app (Flutter)

**Performance Goals**: 
- App startup ≤ 2s cold on mid-range Android (Snapdragon 680 / 4GB RAM)
- Frame drops < 5% during scroll-heavy screens (inventory lists)
- Supplier dropdown search < 500ms

**Constraints**: 
- Arabic-only (RTL, `Locale('ar')`)
- Custom `AppRouter` + `AppNavigation` (no go_router)
- All navigation via `AppNavigation` helpers
- All snackbars via `showSnackBar` from `core/helper/functions.dart`
- All text fields via `AppTextField`, buttons via `AppButton`
- Component themes in `AppTheme` only (no hardcoded styles)
- ObjectBox codegen required after model changes (`build_runner`)
- BLoC Cubits with `buildWhen`/`listenWhen` optimization

**Scale/Scope**: 
- ~5 new files in `features/buying_invoice/` (cubit, state, interface, repository, view)
- 1 new ObjectBox entity (`BuyingInvoiceModel`)
- Reuses existing `InvoiceItemModel` (shared with selling)
- 1 new drawer item (already placeholder in `AppDrawer`)
- 1 new route (`AppRoutes.buyingInvoiceView`)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **I. Code Quality**: Feature as self-contained module in `features/buying_invoice/`, GetIt DI, Result/Either patterns, `flutter analyze` clean
- [x] **II. UX Consistency**: Arabic RTL, `AppTheme`, `flutter_screenutil`, `PersistentBottomNavBarV2`, custom transitions via `AppRouter`
- [x] **III. Visual Consistency**: Colors via `AppColors`, text via `AppTextStyle`, component themes in `AppTheme`
- [x] **IV. Performance**: ObjectBox indexes on `date`, `supplier`; `buildWhen`/`listenWhen` on all BlocBuilders/Listeners
- [x] **V. Architectural Simplicity**: Cubit over Bloc, feature folders, GetIt singletons, no backend, ObjectBox only
- [x] **VI. Navigation/UI Utils**: `AppNavigation` only, `showSnackBar` only
- [x] **VII. Shared Widgets**: `AppTextField`, `AppButton` only
- [x] **VIII. Custom Widget Architecture**: Extracted widget classes in `presentation/widgets/`, BlocBuilder states as separate widgets
- [x] **IX. Component Theme Consistency**: All decorations in `AppTheme`
- [x] **X. Quality Gates**: `flutter analyze`, `flutter test --coverage`, `flutter build apk --debug`, RTL smoke test, perf profile, CHANGELOG entry

## Project Structure

### Documentation (this feature)

```text
specs/004-buying-invoice-feature/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (cubit interfaces)
└── tasks.md             # Phase 2 output (NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── models/
│   │   ├── buying_invoice_model.dart      # NEW: BuyingInvoiceModel entity
│   │   └── invoice_item_model.dart        # EXISTING: reused for buying items
│   ├── config/configrations.dart          # ADD: AppRoutes.buyingInvoiceView, route case
│   ├── navigations/navigations.dart       # No changes needed
│   └── widgets/
│       ├── app_button.dart                # EXISTING
│       └── app_text_field.dart            # EXISTING
├── features/
│   ├── buying_invoice/                    # NEW FEATURE MODULE
│   │   ├── controller/cubit/
│   │   │   ├── buy_invoice_cubit.dart
│   │   │   ├── buy_invoice_state.dart
│   │   │   └── buy_invoice_cubit_interface.dart
│   │   ├── data/repositories/
│   │   │   ├── buy_invoice_repository.dart
│   │   │   └── buy_invoice_repository_impl.dart
│   │   └── presentation/
│   │       ├── views/
│   │       │   └── buying_invoice_view.dart
│   │       └── widgets/
│   │           ├── supplier_dropdown_menu.dart
│   │           ├── invoice_item_tile.dart
│   │           ├── invoice_product_list.dart
│   │           ├── invoice_totals_card.dart
│   │           └── product_selection_view.dart  # NEW: for product selection with qty counter
│   ├── suppliers/                         # EXISTING: SupplierCubit, SupplierFormView, AllSuppliersView
│   └── inventory/                         # EXISTING: ProductCubit, ProductFormView
└── main.dart                              # ADD: BuyInvoiceCubit registration in configureDependencies()
```

**Structure Decision**: Feature-based module under `features/buying_invoice/` following existing pattern (mirrors `features/selling_invoice/`). Reuses existing `InvoiceItemModel` and `SupplierModel`. New `BuyingInvoiceModel` in `core/models/`.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| (none) | All gates pass | N/A |