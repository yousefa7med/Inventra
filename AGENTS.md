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
| Run tests | `flutter test` |
| Analyze | `flutter analyze` |

## Project Structure
```
lib/
├── core/                    # Shared utilities, theme, routing, DI
│   ├── config/configrations.dart   # AppRouter + AppRoutes
│   ├── navigations/navigations.dart # AppNavigation helpers
│   ├── utilities/app_theme.dart    # Light/dark ThemeData
│   ├── controller/controllers/app_cubit/  # App-wide state
│   └── models/               # ObjectBox entities (Product, Customer, Supplier, SellInvoice, BuyInvoice, ReturnReceipt, Expense)
├── features/                # Feature-based modules
│   ├── inventory/           # Products CRUD + search by name/barcode, edit/delete cards
│   ├── dashboard/           # Analytics (profit, expenses, sales), 4 quick-add cards
│   ├── operations/          # History of all operations (sell, buy, return) with filter/search
│   ├── expenses/            # Expenses CRUD + search by note, FAB to add
│   ├── settings/            # App settings (placeholder)
│   └── main/                # MainView (bottom nav + drawer)
└── main.dart                # Entry point, DI setup, MaterialApp
```

## Core Business Entities (ObjectBox Models)
| Entity | Key Fields | Purpose |
|--------|-----------|---------|
| `Product` | `id`, `name`, `barcode`, `quantity`, `buyPrice`, `sellPrice`, `supplierId` | Inventory item |
| `Customer` | `id`, `name`, `phone`, `address`, `balance` | Sell invoice customer |
| `Supplier` | `id`, `name`, `phone`, `address`, `balance` | Buy invoice supplier |
| `SellInvoice` | `id`, `customerId`, `items[]`, `total`, `date`, `paidAmount` | Sale to customer → inventory↓, safe↑ |
| `BuyInvoice` | `id`, `supplierId`, `items[]`, `total`, `date`, `paidAmount` | Purchase from supplier → inventory↑, safe↓ |
| `ReturnReceipt` | `id`, `sellInvoiceId`, `items[]`, `total`, `date` | Return from customer → inventory↑, safe↓ |
| `Expense` | `id`, `note`, `amount`, `date`, `category` | Business expense tracking |

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

### Main View - Bottom Navigation (4 tabs)
1. **Dashboard** — Profit/sales/expenses analytics, 4 quick-add cards (Sell Invoice, Customer, Supplier, Product)
2. **Operations** — Full history (sell, buy, returns), filter by category, search by customer/supplier name
3. **Inventory** — Product cards, edit/delete, search by name or barcode
4. **Expenses** — List with note search, FAB to add new expense

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
- **TextFields**: NEVER use raw `TextFormField`/`TextField`. Use `AppTextField` from `core/widgets/app_text_field.dart` only.
- **Buttons**: NEVER use raw `ElevatedButton` in `SizedBox`. Use `AppButton` from `core/widgets/app_button.dart` for full-width buttons only.
- **Widgets**: NEVER use inline `Widget Function()` builders or `_build*()` methods. Extract into proper widget classes — feature-specific in `features/*/presentation/widgets/`, common in `core/widgets/`.
- **BlocBuilder States**: In `BlocBuilder`, each state body (e.g., `SafeLoading`, `SafeError`, `SafeLoaded`) MUST be a separate widget class (e.g., `SafeLoadingBody`, `SafeErrorBody`, `SafeLoadedBody`).

## State Management Details
- Uses `flutter_bloc` ^9.1.1 with Cubit pattern (not Bloc)
- `AppCubit` for app-wide state (theme, locale) in `core/controller/controllers/app_cubit/`
- `ProductCubit` for inventory feature in `features/inventory/controller/cubit/`
- Future cubits: `CustomerCubit`, `SupplierCubit`, `SellInvoiceCubit`, `BuyInvoiceCubit`, `ReturnReceiptCubit`, `ExpenseCubit`, `DashboardCubit`, `OperationsCubit`
- Cubits registered as `LazySingleton` in GetIt (`main.dart:75`)

## Database (ObjectBox)
- Entities in `core/models/` annotated with `@Entity()`
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
2. **Test file broken** - `test/widget_test.dart` imports `package:inventra/main.dart` (should be `Inventra`)
3. **No analysis_options.yaml** - uses defaults only
4. **ThemeMode hardcoded to light** - `main.dart:54` ignores `AppCubit` theme state
5. **Arabic-only** - no localization delegates for other locales
6. **DI order matters** - CacheHelper must init before ObjectBoxServices (`main.dart:67-74`)
7. **ProductCubit** - Registered as lazy singleton but `GetIt.instance<ProductCubit>()` used directly in router (`configrations.dart:56`)

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

## Spec Kit Rules
Before executing any Spec Kit command:
- Verify the `.specify` directory exists.
- Read all required templates before making assumptions.
- Never assume a file is missing after a single glob.
- If a glob returns no results, try direct file reads and recursive listing.