# Inventra - Inventory Management App 📦

**Inventra** is a comprehensive Flutter inventory management application designed for small to medium businesses. Built with offline-first architecture using ObjectBox, it provides complete inventory control, invoice management, customer/supplier tracking, and financial reporting — all in Arabic with full RTL support.

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.12+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter Version">
  <img src="https://img.shields.io/badge/Dart-3.12+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart Version">
  <img src="https://img.shields.io/badge/ObjectBox-5.3+-FF6B35?style=for-the-badge&logo=database&logoColor=white" alt="ObjectBox">
  <img src="https://img.shields.io/badge/Bloc-9.1+-1E1E1E?style=for-the-badge&logo=bloc&logoColor=white" alt="Bloc">
  <img src="https://img.shields.io/badge/RTL-Arabic-FF6F00?style=for-the-badge&logo=google-translate&logoColor=white" alt="Arabic RTL">
  <img src="https://img.shields.io/badge/Theme-Light%20%7C%20Dark-757575?style=for-the-badge&logo=material-design&logoColor=white" alt="Theme Support">
</p>

---

## 💡 Core Idea

Inventra acts as a complete business management companion by:
- **Inventory Control** — Track products with barcode support, multiple price tiers (buy/sell/wholesale), and real-time stock levels
- **Invoice Management** — Create sales & purchase invoices with automatic inventory deduction/addition
- **Financial Tracking** — Unified transaction history, safe/cash balance, expense categorization
- **Relationship Management** — Customer & supplier databases with balance tracking
- **Offline-First** — All data stored locally via ObjectBox, no internet required

---

## 📱 App Overview

| Dashboard & Analytics | Inventory Management |
|:---:|:---:|
| <img src="assets/screenshots/dashboard.png" width="450" alt="Dashboard"> | <img src="assets/screenshots/inventory.png" width="450" alt="Inventory"> |
| *Profit/Sales/Expenses Overview + Quick Actions* | *Product Cards with Search & Barcode Support* |

| Sales Invoice Flow | Purchase Invoice Flow |
|:---:|:---:|
| <img src="assets/screenshots/selling_invoice.png" width="450" alt="Selling Invoice"> | <img src="assets/screenshots/buying_invoice.png" width="450" alt="Buying Invoice"> |
| *Customer Selection → Product Selection → Invoice Summary* | *Supplier Selection → Product Selection → Invoice Summary* |

| Safe & Expenses | Transaction History |
|:---:|:---:|
| <img src="assets/screenshots/safe.png" width="450" alt="Safe Management"> | <img src="assets/screenshots/transactions.png" width="450" alt="Transactions"> |
| *Balance Card + Expense List + Manual Adjustments* | *Unified History with Filters & Search* |

---

## ✨ Key Features

### 1. Complete Inventory Management
- **Product CRUD** — Add, edit, delete products with image support
- **Multi-tier Pricing** — Buy price, sell price, wholesale price per product
- **Barcode Support** — Scan/search products by barcode
- **Stock Tracking** — Real-time quantity updates from invoices
- **Supplier Linking** — Associate products with suppliers

### 2. Invoice System (Sales & Purchases)
- **Sales Invoices** — Select customer → add products → auto-calculate totals
- **Purchase Invoices** — Select supplier → add products → auto-calculate totals
- **Automatic Inventory Sync** — Sell = stock↓/safe↑, Buy = stock↑/safe↓
- **Partial Payments** — Track paid vs remaining amounts
- **Invoice Items** — Quantity counters, price override, line totals

### 3. Customer & Supplier Management
- **Full CRUD** — Name, phone, address, balance tracking
- **Balance History** — Automatic updates from invoices/payments
- **Search & Filter** — Quick lookup by name or phone
- **Arabic Normalization** — Smart search handles diacritics

### 4. Financial & Safe Management
- **Safe Balance** — Running cash balance with date tracking
- **Expense Tracking** — Categorized expenses (rent, utilities, salaries, etc.)
- **Manual Adjustments** — Add/remove cash with notes (type: in/out)
- **Unified Transactions** — Single view of all money movements

### 5. Transaction History & Reporting
- **Unified Log** — Sales, purchases, returns, expenses, adjustments
- **Advanced Filtering** — By type, date range, customer/supplier
- **Search** — By reference name, amount, notes
- **Invoice Details** — Drill-down into any transaction

### 6. Dashboard Analytics
- **KPI Cards** — Total profit, sales, purchases, expenses
- **Quick Actions** — One-tap to create invoice, add customer, etc.
- **Visual Summary** — Clean grid layout for at-a-glance insights

### 7. Technical Excellence
- **Offline-First** — ObjectBox local database, zero backend dependency
- **Arabic RTL** — Full RTL layout, Cairo font, Arabic strings centralized
- **Light/Dark Themes** — Material 3 theming with custom ColorScheme
- **Clean Architecture** — Feature-based modules, BLoC/Cubit, GetIt DI
- **Custom Routing** — Named routes with slide transitions
- **Responsive** — flutter_screenutil for consistent sizing across devices

---

## 🛠 Tech Stack

| Layer | Technology | Version |
|-------|------------|---------|
| **Framework** | Flutter | ^3.12.2 |
| **Language** | Dart | ^3.12.2 |
| **State Management** | flutter_bloc (Cubit) | ^9.1.1 |
| **Database** | ObjectBox | ^5.3.2 |
| **DI** | get_it | ^9.2.1 |
| **Routing** | Custom AppRouter | — |
| **Localization** | Arabic (RTL) | Locale('ar') |
| **Responsive** | flutter_screenutil | ^5.9.3 |
| **Code Gen** | build_runner + objectbox_generator | ^2.15.0 / ^5.3.2 |
| **Utilities** | intl, path, path_provider, shared_preferences | latest |
| **Media** | image_picker, flutter_svg | ^1.2.2 / ^2.3.0 |
| **Navigation** | persistent_bottom_nav_bar_v2 | ^6.3.2 |

---

## 🏗️ Architecture

```
lib/
├── core/                              # Shared foundation
│   ├── config/                        # AppRouter + AppRoutes
│   ├── constants/                     # AppStrings (centralized Arabic)
│   ├── controller/                    # AppCubit (theme, locale)
│   ├── helper/                        # Cache, dialogs, normalizers
│   ├── models/                        # 11 ObjectBox @Entity models
│   ├── navigations/                   # AppNavigation helpers
│   ├── transitions/                   # Custom page transitions
│   ├── utilities/                     # Theme, colors, typography, assets
│   ├── utils/                         # Formatters, validators, phone
│   └── widgets/                       # Shared UI (AppButton, AppTextField, etc.)
├── features/                          # 11 feature modules
│   ├── buying_invoice/                # Purchase invoices
│   ├── customers/                     # Customer management
│   ├── dashboard/                     # Analytics dashboard
│   ├── inventory/                     # Product management
│   ├── main/                          # Shell (bottom nav + drawer)
│   ├── safe/                          # Safe balance + expenses
│   ├── selling_invoice/               # Sales invoices
│   ├── settings/                      # App settings
│   ├── suppliers/                     # Supplier management
│   └── transactions/                  # Unified history
└── main.dart                          # Entry point, DI, MaterialApp
```

---

## 📦 Core Business Entities

| Entity | Key Fields | Business Purpose |
|--------|-----------|------------------|
| `Product` | `id`, `name`, `barcode`, `quantity`, `buyPrice`, `sellPrice`, `wholesalePrice`, `supplierId`, `imgPath` | Inventory item |
| `Customer` | `id`, `name`, `phone`, `address`, `balance` | Sales invoices |
| `Supplier` | `id`, `name`, `phone`, `address`, `balance` | Purchase invoices |
| `SellInvoice` | `id`, `customerId`, `items[]`, `total`, `date`, `paidAmount` | Sale → stock↓, safe↑ |
| `BuyInvoice` | `id`, `supplierId`, `items[]`, `total`, `date`, `paidAmount` | Purchase → stock↑, safe↓ |
| `ReturnReceipt` | `id`, `sellInvoiceId`, `items[]`, `total`, `date` | Return → stock↑, safe↓ |
| `Expense` | `id`, `note`, `amount`, `date`, `category` | Business expenses |
| `SafeBalance` | `id`, `balance`, `date` | Running cash balance |
| `InvoiceItem` | `id`, `productId`, `quantity`, `price`, `total` | Invoice line item |
| `ManualAdjustment` | `id`, `amount`, `note`, `date`, `type` | Manual safe adjustment |
| `TransactionEntry` | `id`, `type`, `referenceId`, `amount`, `date` | Unified transaction log |

---

## 🔄 Business Flow Summary

| Transaction | Inventory | Safe Balance |
|-------------|-----------|--------------|
| **Buy Invoice** (from supplier) | ↑ increases | ↓ decreases |
| **Sell Invoice** (to customer) | ↓ decreases | ↑ increases |
| **Return Receipt** (from customer) | ↑ increases | ↓ decreases |
| **Expense** | — | ↓ decreases |

---

## 🧭 Navigation Structure

### Drawer (Side Menu)
- **All Customers** → Customer list with search
- **All Suppliers** → Supplier list with search
- **Settings** → App settings
- **Buying Invoices** → Purchase history

### Main View — Bottom Navigation (5 tabs)
1. **Dashboard** — KPIs + 4 quick-action cards
2. **Operations** — Full transaction history with filters
3. **Inventory** — Product grid with search/barcode
4. **Safe** — Balance card, expenses, adjustment FAB
5. **Settings** — Placeholder

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ^3.12.2
- Dart SDK ^3.12.2
- Android Studio / VS Code with Flutter extensions

### Installation

```bash
# 1. Clone the repository
git clone <repository-url>
cd inventra

# 2. Get dependencies
flutter pub get

# 3. Generate ObjectBox code (required!)
dart run build_runner build --delete-conflicting-outputs

# 4. Run the app
flutter run
```

### Available Commands

| Task | Command |
|------|---------|
| Get dependencies | `flutter pub get` |
| **Code generation (required)** | `dart run build_runner build --delete-conflicting-outputs` |
| Run app | `flutter run` |
| Analyze code | `flutter analyze` |
| Run tests | `flutter test` |

---

## 🎨 Design System Conventions

### Colors — Use `AppColors` Only
```dart
// ✅ Correct
AppColors.primary
AppColors.surfaceContainer
AppColors.error

// ❌ Never hardcode
Colors.blue, Color(0xFF123456)
```

### Typography — Use `AppTextStyle` Only
```dart
// ✅ Correct
AppTextStyle.heading1
AppTextStyle.bodyMedium
AppTextStyle.labelLarge

// ❌ Never hardcode
TextStyle(fontSize: 16), const TextStyle()
```

### Components — Use Standardized Widgets
```dart
// ✅ Correct
AppButton(onPressed: () {}, text: 'حفظ')
AppTextField(hintText: 'اسم المنتج')
CustomAppBar(title: 'الفواتير')

// ❌ Never use raw widgets
ElevatedButton(...), TextFormField(...), AppBar(...)
```

---

## 🔧 Development Guidelines

### State Management
- **Cubit pattern** (not Bloc) via `flutter_bloc`
- Feature cubits: `features/*/controller/cubit/`
- App-wide: `core/controller/controllers/app_cubit/`

### Routing — Use `AppNavigation`
```dart
AppNavigation.pushName(context, AppRoutes.inventoryView)
AppNavigation.pushReplacementNamed(context, AppRoutes.mainView)
AppNavigation.pushAndRemoveUntil(context, AppRoutes.mainView)
// ❌ Never: Navigator.of(context).push(...)
```

### Snackbars — Use Helper
```dart
showSnackBar(context, 'تم الحفظ بنجاح')
showSnackBar(context, 'حدث خطأ', color: AppColors.error)
// ❌ Never: ScaffoldMessenger.of(context).showSnackBar(...)
```

### Dependency Injection — `GetIt` in `main.dart`
```dart
// Feature cubits as LazySingleton
getIt.registerLazySingleton<ProductCubit>(() => ProductCubit(repo));
```

### Database — ObjectBox
- Entities: `core/models/*.dart` with `@Entity()`
- **Always run codegen after model changes:**
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```
- Boxes: `GetIt.instance<ObjectBoxServices>().productsBox`

---

## 📋 Common Development Tasks

### Add New Entity
1. Create model in `lib/core/models/` with `@Entity()`
2. Run `dart run build_runner build --delete-conflicting-outputs`
3. Add box to `ObjectBoxServices` (`cache_helper.dart`)
4. Register repository/cubit in `configureDependencies()` if needed

### Add New Feature Screen
1. Create `features/<name>/presentation/views/`
2. Add route to `AppRoutes` (`configrations.dart`)
3. Add case to `AppRouter.generateRoute()`
4. Navigate: `AppNavigation.pushName(context, AppRoutes.newRoute)`

### Add Drawer Menu Item
1. Add route to `AppRoutes`
2. Add case to `AppRouter.generateRoute()`
3. Add item in `MainView` drawer list
4. Navigate: `AppNavigation.pushName(context, AppRoutes.drawerRouteName)`

### Modify Theme
- Edit `AppTheme.lightTheme` / `darkTheme` (`app_theme.dart`)
- Colors: `AppColors` (`app_colors.dart`)
- Enable theme toggle: update `themeMode` in `main.dart` to use `AppCubit`

---

## ⚠️ Known Gotchas

| Issue | Details |
|-------|---------|
| **ObjectBox codegen required** | Run `build_runner` after any model change |
| **No analysis_options.yaml** | Uses Flutter defaults only |
| **ThemeMode hardcoded** | `main.dart:54` ignores `AppCubit` theme state |
| **Arabic-only locale** | No delegates for other languages |
| **DI initialization order** | `CacheHelper` must init before `ObjectBoxServices` |
| **ProductCubit in router** | Accessed directly in `configrations.dart:56` |

---

## 🧪 Testing

```bash
# Unit & widget tests
flutter test

# Integration tests (when available)
flutter test integration_test/
```

---

## 📄 License

This project is private and not licensed for public distribution.

---

## 🤝 Contributing

1. **Create feature branch:** `git checkout -b feature/feature-name`
2. **Commit frequently** with descriptive messages
3. **Push to origin:** `git push -u origin feature/feature-name`
4. **Open Pull Request** for review
5. **Never push directly** to main/master

---

## 📬 Connect

<div align="center">

**Built with Flutter • Powered by ObjectBox • Designed for Arabic RTL**

<br><br>

<a href="https://www.linkedin.com/in/1youssef-ahmed/" target="_blank">
  <img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn">
</a>
&nbsp;&nbsp;&nbsp;&nbsp;
<a href="mailto:youssefahmedserag@gmail.com">
  <img src="https://img.shields.io/badge/Gmail-D14836?style=for-the-badge&logo=gmail&logoColor=white" alt="Gmail">
</a>
</div>
