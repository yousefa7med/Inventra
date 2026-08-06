# Inventra - Flutter Inventory Management App

## Quick Start
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs  # Required for ObjectBox codegen
flutter run
```

## Architecture
- **State Management**: BLoC (`flutter_bloc`) with `GetIt` for DI
- **Database**: ObjectBox (local, no backend)
- **Routing**: Custom `AppRouter` + `AppNavigation` (not go_router)
- **Locale**: Arabic only (`Locale('ar')`), RTL
- **Theme**: Custom `AppTheme` with light/dark `ColorScheme`

## Key Commands
| Task | Command |
|------|---------|
| Get deps | `flutter pub get` |
| Codegen (ObjectBox) | `dart run build_runner build --delete-conflicting-outputs` |
| Run app | `flutter run` |
| Analyze | `flutter analyze` |

## Project Structure
```
lib/
├── core/                              # Shared utilities, theme, routing, DI
│   ├── config/configrations.dart      # AppRouter + AppRoutes
│   ├── constants/app_strings.dart     # Centralized Arabic strings
│   ├── controller/controllers/app_cubit/  # App-wide state (theme, locale)
│   ├── helper/                        # Cache, dialogs, normalizers, functions
│   │   ├── app_dialog.dart
│   │   ├── arabic_normalizer.dart
│   │   ├── cache_helper.dart          # SharedPreferences + ObjectBox init
│   │   ├── cache_keys.dart
│   │   └── functions.dart             # showSnackBar, navigation helpers
│   ├── models/                        # ObjectBox entities (11 models)
│   │   ├── product_model.dart
│   │   ├── customer_model.dart
│   │   ├── supplier_model.dart
│   │   ├── selling_invoice_model.dart
│   │   ├── buying_invoice_model.dart
│   │   ├── invoice_item_model.dart
│   │   ├── expense_model.dart
│   │   ├── safe_balance_model.dart
│   │   ├── manual_adjustment_model.dart
│   │   ├── transactions_entry.dart
│   │   └── transaction_type.dart
│   ├── navigations/navigations.dart   # AppNavigation helpers
│   ├── transitions/                   # Custom page transitions
│   │   ├── page_route_builder_method.dart
│   │   └── slide_transation_builder.dart
│   ├── utilities/                     # Theme, colors, typography, assets
│   │   ├── app_theme.dart             # Light/dark ThemeData + component themes
│   │   ├── app_colors.dart            # AppColors palette
│   │   ├── app_text_style.dart        # AppTextStyle (Cairo font)
│   │   ├── app_global_keys.dart       # GlobalKeys for navigation/drawer
│   │   └── assets.dart                # Generated asset references
│   ├── utils/                         # Formatters, validators, phone utils
│   │   ├── formatters.dart
│   │   ├── phone_utils.dart
│   │   └── validators.dart
│   └── widgets/                       # Shared UI components
│       ├── app_button.dart            # Full-width button (AppButton)
│       ├── app_drawer.dart            # Side drawer with navigation
│       ├── app_text_field.dart        # Standardized text field (AppTextField)
│       ├── custom_app_bar.dart        # RTL-aware app bar
│       ├── search_field.dart          # Search input with clear
│       ├── quantity_counter.dart      # +/- quantity selector
│       ├── customer_form_view.dart    # Customer create/edit form
│       ├── supplier_form_view.dart    # Supplier create/edit form
│       ├── product_form_view.dart     # Product create/edit form
│       ├── empty_state_widget.dart
│       └── error_state_widget.dart
├── features/                          # Feature-based modules (11 features)
│   ├── buying_invoice/                # Buy invoices (from suppliers)
│   │   ├── controller/cubit/          # BuyInvoiceCubit + state + interface
│   │   ├── data/repositories/         # BuyInvoiceRepository + impl
│   │   ├── presentation/views/        # BuyingInvoiceView, BuyingProductSelectionView
│   │   └── presentation/widgets/      # Invoice items, product cards, supplier dropdown
│   ├── customers/                     # Customer management
│   │   ├── controller/cubit/          # CustomerCubit + state + interface
│   │   ├── data/repositories/         # CustomerRepository + impl
│   │   ├── presentation/views/        # AllCustomersView
│   │   └── presentation/widgets/      # CustomerCard, loading/error widgets
│   ├── dashboard/                     # Analytics dashboard
│   │   ├── presentation/views/        # DashboardView
│   │   └── presentation/widgets/      # Grid cards, list cards, add image
│   ├── inventory/                     # Product management
│   │   ├── controller/cubit/          # ProductCubit + state + interface
│   │   ├── data/repositories/         # ProductRepository + impl
│   │   ├── presentation/views/        # InventoryView
│   │   └── presentation/widgets/      # ProductCard, no search result
│   ├── main/                          # Main shell (bottom nav + drawer)
│   │   └── presentation/views/        # MainView
│   ├── safe/                          # Safe balance + expenses
│   │   ├── controller/cubit/          # SafeCubit + state + interface
│   │   ├── data/repositories/         # SafeRepository + impl
│   │   ├── presentation/views/        # SafeView, AddExpenseView, AdjustBalanceDialog
│   │   └── presentation/widgets/      # BalanceCard, ExpenseCard, SafeLoadedBody, search/filter
│   ├── selling_invoice/               # Sell invoices (to customers)
│   │   ├── controller/cubit/          # SellInvoiceCubit + state + interface
│   │   ├── data/repositories/         # SellInvoiceRepository + impl
│   │   ├── presentation/views/        # SellingInvoiceView, SellingProductSelectionView
│   │   └── presentation/widgets/      # Invoice items, product cards, customer dropdown
│   ├── settings/                      # App settings (placeholder)
│   │   └── presentation/views/        # SettingsView
│   ├── suppliers/                     # Supplier management
│   │   ├── controller/cubit/          # SupplierCubit + state + interface
│   │   ├── data/repositories/         # SupplierRepository + impl
│   │   ├── presentation/views/        # AllSuppliersView
│   │   └── presentation/widgets/      # SupplierCard
│   └── transactions/                  # Unified operations history
│       ├── controller/cubit/          # TransactionsCubit + state + interface
│       ├── data/repositories/         # TransactionsRepository + impl
│       ├── presentation/views/        # TransactionsView, InvoiceDetailsView
│       ├── presentation/widgets/      # TransactionCard, TransactionsLoadedBody, filter
│       └── utils/                     # TransactionTypeExtension
└── main.dart                          # Entry point, DI setup, MaterialApp
```

## Core Business Entities (ObjectBox Models)
| Entity | Key Fields | Purpose |
|--------|-----------|---------|
| `Product` | `id`, `name`, `barcode`, `quantity`, `buyPrice`, `sellPrice`, `wholesalePrice`, `supplierId`, `imgPath` | Inventory item |
| `Customer` | `id`, `name`, `phone`, `address`, `balance` | Sell invoice customer |
| `Supplier` | `id`, `name`, `phone`, `address`, `balance` | Buy invoice supplier |
| `SellInvoice` | `id`, `customerId`, `items[]`, `total`, `date`, `paidAmount` | Sale to customer → inventory↓, safe↑ |
| `BuyInvoice` | `id`, `supplierId`, `items[]`, `total`, `date`, `paidAmount` | Purchase from supplier → inventory↑, safe↓ |
| `ReturnReceipt` | `id`, `sellInvoiceId`, `items[]`, `total`, `date` | Return from customer → inventory↑, safe↓ |
| `Expense` | `id`, `note`, `amount`, `date`, `category` | Business expense tracking |
| `SafeBalance` | `id`, `balance`, `date` | Running safe/cash balance |
| `InvoiceItem` | `id`, `productId`, `quantity`, `price`, `total` | Line item for invoices |
| `ManualAdjustment` | `id`, `amount`, `note`, `date`, `type` | Manual safe balance adjustment |
| `TransactionEntry` | `id`, `type`, `referenceId`, `amount`, `date` | Unified transaction log |

## Business Flow Summary
| Transaction | Inventory | Safe Balance |
|-------------|-----------|--------------|
| **Buy Invoice** (from supplier) | ↑ increases | ↓ decreases |
| **Sell Invoice** (to customer) | ↓ decreases | ↑ increases |
| **Return Receipt** (from customer) | ↑ increases | ↓ decreases |
| **Expense** | — | ↓ decreases |

## Navigation Structure
### Drawer (Side Menu)
- **All Customers** → Customer list screen
- **All Suppliers** → Supplier list screen
- **Settings** → Settings screen
- **Buying Invoices** → Buy invoice list/history
- *(Future features placeholder)*

### Main View - Bottom Navigation (5 tabs)
1. **Dashboard** — Profit/sales/expenses analytics, 4 quick-add cards (Sell Invoice, Customer, Supplier, Product)
2. **Operations** — Full history (sell, buy, returns), filter by category, search by customer/supplier name
3. **Inventory** — Product cards, edit/delete, search by name or barcode
4. **Safe** — Balance card, expenses list, FAB to add expense/adjust balance
5. **Settings** — App settings (placeholder)

## Critical Conventions
- **Import alias**: `package:Inventra/...` (capital I)
- **DI**: Register in `main.dart:configureDependencies()` via `GetIt`
- **Routing**: Use `AppNavigation.pushName()` / `pushReplacementNamed()` / `pushAndRemoveUntil()` — NEVER use `Navigator.of(context)` directly
- **Snackbars**: Use `showSnackBar(context, message)` from `core/helper/functions.dart` — NEVER use `ScaffoldMessenger.of(context).showSnackBar()` directly
- **Theme**: Access via `AppTheme.lightTheme` / `AppTheme.darkTheme`
- **BLoC**: Feature cubits in `features/*/controller/cubit/`
- **Models**: ObjectBox entities in `core/models/*.dart` with `@Entity()`
- **Drawer Navigation**: Use `AppNavigation.pushName(context, AppRoutes.drawerRouteName)`
- **Colors**: NEVER hardcode colors. Use `AppColors` class only. If a color is missing, add it to `AppColors` first, then use it everywhere.
- **TextStyles**: NEVER hardcode `TextStyle()`. Use `AppTextStyle` class only. If a style is missing, add it to `AppTextStyle` first, then use it everywhere.
- **Widget Styles/Decorations**: NEVER hardcode `BoxDecoration`, `InputDecoration`, `ButtonStyle`, `MenuStyle`, or similar in custom widgets. Define reusable styles in `AppTheme` (component themes: `elevatedButtonTheme`, `inputDecorationTheme`, `dropdownMenuTheme`, `cardTheme`, etc.) and access via `Theme.of(context)` or `AppTheme.lightTheme/darkTheme`. If a theme is missing, add it to `AppTheme` first.
- **TextFields**: NEVER use raw `TextFormField`/`TextField`. Use `AppTextField` from `core/widgets/app_text_field.dart` only.
- **Buttons**: NEVER use raw `ElevatedButton` in `SizedBox`. Use `AppButton` from `core/widgets/app_button.dart` for full-width buttons only.
- **Widgets**: NEVER use inline `Widget Function()` builders or `_build*()` methods. Extract into proper widget classes — feature-specific in `features/*/presentation/widgets/`, common in `core/widgets/`.
- **BlocBuilder States**: In `BlocBuilder`, each state body (e.g., `SafeLoading`, `SafeError`, `SafeLoaded`) MUST be a separate widget class (e.g., `SafeLoadingBody`, `SafeErrorBody`, `SafeLoadedBody`).
- **Const Correctness**: ALWAYS use `const` constructors for immutable widgets, literals, and declarations. Prefer `const` everywhere possible — this is enforced by lint rules (`prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, `prefer_const_declarations`). Avoid unnecessary object allocation in build methods.

## State Management Details
- Uses `flutter_bloc` ^9.1.1 with Cubit pattern (not Bloc)
- `AppCubit` for app-wide state (theme, locale) in `core/controller/controllers/app_cubit/`
- Feature cubits (all LazySingleton in GetIt):
  - `ProductCubit` in `features/inventory/controller/cubit/`
  - `CustomerCubit` in `features/customers/controller/cubit/`
  - `SupplierCubit` in `features/suppliers/controller/cubit/`
  - `SellInvoiceCubit` in `features/selling_invoice/controller/cubit/`
  - `BuyInvoiceCubit` in `features/buying_invoice/controller/cubit/`
  - `SafeCubit` in `features/safe/controller/cubit/`
  - `TransactionsCubit` in `features/transactions/controller/cubit/`

## Database (ObjectBox)
- Entities in `core/models/` annotated with `@Entity()` (11 models)
- Run `dart run build_runner build --delete-conflicting-outputs` after model changes
- Generated files: `lib/objectbox.g.dart`, `lib/objectbox-model.json`
- Store initialized in `ObjectBoxServices.init()` (`cache_helper.dart:47`)
- Boxes accessed via `GetIt.instance<ObjectBoxServices>().productsBox` etc.
- Use indexes on `barcode`, `name`, `date` fields for query performance

## Routing (Custom)
- Named routes in `AppRoutes` abstract class (`configrations.dart:71`)
- Route generation in `AppRouter.generateRoute()` with custom page transitions
- Arguments passed via `settings.arguments` (cast in route handler)
- Initial route: `AppRoutes.mainView` ('/')
- Navigation helpers in `AppNavigation` class (`navigations.dart`)
- Drawer routes use same `AppRouter.generateRoute()` pattern
- **Snackbar helper**: `showSnackBar(context, message, {color})` in `core/helper/functions.dart`

## Theming
- Light/dark themes in `AppTheme` class (`app_theme.dart`)
- Uses custom `ColorScheme` with `AppColors`
- Component themes: `elevatedButtonTheme`, `appBarTheme`
- **Gotcha**: `themeMode: ThemeMode.light` hardcoded in `main.dart:54` - dark theme exists but not toggled

## Localization
- Hardcoded Arabic locale: `Locale('ar')` (`main.dart:40`)
- RTL support via `flutter_localizations` delegates
- Only Arabic supported currently

## Responsive Design
- `flutter_screenutil` initialized in `main.dart:30` with `designSize: Size(360, 690)`
- Use `.w`, `.h`, `.sp` extensions for sizing

## Dependencies of Note
- `flutter_bloc` ^9.1.1
- `objectbox` ^5.3.2 + `objectbox_generator` (dev)
- `get_it` ^9.2.1
- `flutter_screenutil` ^5.9.3
- `persistent_bottom_nav_bar_v2` ^6.3.2
- `flutter_svg` ^2.3.0
- `image_picker` ^1.2.2
- `shared_preferences` ^2.5.5

## Gotchas
1. **ObjectBox requires codegen** - run `build_runner` after model changes
2. **No analysis_options.yaml** - uses defaults only
3. **ThemeMode hardcoded to light** - `main.dart:54` ignores `AppCubit` theme state
4. **Arabic-only** - no localization delegates for other locales
5. **DI order matters** - CacheHelper must init before ObjectBoxServices (`main.dart:67-74`)
6. **ProductCubit** - Registered as lazy singleton but `GetIt.instance<ProductCubit>()` used directly in router (`configrations.dart:56`)

## Common Tasks

### Add New Entity
1. Create model in `lib/core/models/` with `@Entity` annotation
2. Run `dart run build_runner build --delete-conflicting-outputs`
3. Add box to `ObjectBoxServices` (`cache_helper.dart:42`)
4. Register in `configureDependencies()` if needed

### Add New Feature Screen
1. Create feature folder under `features/<name>/presentation/views/`
2. Add route constant to `AppRoutes` (`configrations.dart`)
3. Add case to `AppRouter.generateRoute()`
4. Navigate via `AppNavigation.pushName(context, AppRoutes.newRoute)`

### Add Drawer Menu Item
1. Add route constant to `AppRoutes` (`configrations.dart`)
2. Add case to `AppRouter.generateRoute()`
3. Add drawer item in `MainView` drawer list
4. Navigate via `AppNavigation.pushName(context, AppRoutes.drawerRouteName)`

### Modify Theme
- Edit `AppTheme.lightTheme` / `darkTheme` (`app_theme.dart`)
- Colors in `AppColors` (`app_colors.dart`)
- To enable theme toggle: change `themeMode` in `main.dart:54` to use `AppCubit`

### Add Dependency
```bash
flutter pub add <package>
# For dev:
flutter pub add dev:<package>
```

## Git & Push Policy

**NEVER push to main/master directly.** All feature work must be on a `feature/<spec-name>` branch.

- Create feature branch: `git checkout -b feature/buying-invoice-feature`
- Commit frequently with descriptive messages
- Push to origin: `git push -u origin feature/<branch-name>`
- Only merge via Pull Request after review
- Never force-push to shared branches


## Spec Kit Rules
Before executing any Spec Kit command:
- Verify the `.specify` directory exists.
- Read all required templates before making assumptions.
- Never assume a file is missing after a single glob.
- If a glob returns no results, try direct file reads and recursive listing.

## File Search Convention
- Use PowerShell commands (`Get-ChildItem`, `Select-String`) for file search and content search on this Windows environment.
- Example: `Get-ChildItem -Recurse -Filter "*.dart" lib/core/models`
- Example: `Select-String -Pattern "AppColors" -Path "lib\**\*.dart"`
- Avoid `ls`, `grep`, `find`, `rg` (ripgrep) — they may not work as expected in PowerShell.