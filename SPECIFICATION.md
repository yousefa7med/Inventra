# Inventra — Project Specification

> **Document type:** Self-contained software project specification
> **Product:** Inventra — offline-first, Arabic RTL inventory + POS app (Flutter, Android-first)
> **Status:** Living document — regenerate when project details change
> **Version:** 1.0.0 (aligned with `pubspec.yaml` `version: 1.0.0+1`)
> **Generated from:** full repository scan (`lib/`, `test/`, `specs/`, `.specify/`, `pubspec.yaml`, `README.md`, `PRODUCT.md`, `DESIGN.md`, `AGENTS.md`)
> **Source of truth order:** actual code > `PRODUCT.md` / `DESIGN.md` / `.specify/memory/constitution.md` > `AGENTS.md` / `README.md` (partially stale, see §11)

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture Summary](#2-architecture-summary)
3. [Feature Set](#3-feature-set)
4. [API Contracts and Data Models](#4-api-contracts-and-data-models)
5. [Codebase Layout](#5-codebase-layout)
6. [Non-Functional Requirements](#6-non-functional-requirements)
7. [Roadmap](#7-roadmap)
8. [Testing Strategy](#8-testing-strategy)
9. [Deployment Plan](#9-deployment-plan)
10. [Maintenance and Handoff](#10-maintenance-and-handoff)
11. [Appendix: Known Discrepancies & Open Issues](#11-appendix-known-discrepancies--open-issues)

---

## 1. Project Overview

### 1.1 Goals

**Inventra** is an offline-first, Arabic-only (RTL) inventory + simple POS application for small retailers. There is **no backend, no cloud, no accounts** — all persistence is a local ObjectBox database on the device.

| # | Goal | Measure |
|---|------|---------|
| G1 | Run daily retail operations end-to-end offline | Zero network calls for all core flows |
| G2 | Barcode → sell invoice in under 30 seconds | Manual timing on mid-range Android |
| G3 | Instant, accurate safe/cash balance and profit analytics | Balance correct after every transaction; dashboard renders < 3s |
| G4 | Cohesive Arabic-first design system | Zero hardcoded colors/text styles/decorations in `lib/` |
| G5 | Ship an installable Android release | Signed APK/AAB builds via CI |

### 1.2 Scope

**In scope (v1.x):**
- Product, customer, supplier CRUD (ObjectBox-backed)
- Sell invoices, buy invoices, with automatic inventory + safe-balance reconciliation
- Expenses, manual safe-balance adjustments, unified transaction log
- Operations history (filter/search/drill-down), analytics dashboard (KPIs + charts)
- Arabic RTL-only UI, light/dark themes (dark pending enablement), responsive via ScreenUtil (360×690 baseline)
- Android as primary platform (iOS/Web/Linux/macOS/Windows are secondary/adaptive)

**Out of scope (explicitly decided):**
- Cloud sync / backend API / user accounts / multi-user roles
- Multi-language (Arabic-only is a feature, not a limitation)
- VAT/tax calculation, PDF/Excel export, thermal printer integration (undecided → future)
- Barcode **camera scanning** (current UX: manual/barcode-text search only — see §11)

### 1.3 Success Criteria

| ID | Criterion | Verification |
|----|-----------|--------------|
| SC-1 | `flutter analyze` clean (0 errors) | CI job |
| SC-2 | Test coverage: core ≥ 90%, features ≥ 80% | `flutter test --coverage` (constitution DoD — **not yet met**, see §8) |
| SC-3 | Cold start < 2s on Snapdragon 680 / 4GB RAM | `flutter run --profile --trace-startup` |
| SC-4 | < 5% jank frames on inventory/dashboard scroll | DevTools performance overlay |
| SC-5 | All 5 bottom-nav tabs + drawer routes functional on device | Manual RTL smoke test checklist |
| SC-6 | Invoice → inventory + safe balance reconciliation is atomic | Unit tests on repository impls (§8.4) |
| SC-7 | Signed release APK installs and passes onboarding-free first run | Internal distribution |

### 1.4 Stakeholders

| Role | Responsibility |
|------|----------------|
| Sole maintainer / product owner | Requirements, prioritization, PR approval, releases |
| Contributors (feature branches) | Implement specs from `specs/NNN-<name>/`, open PRs |
| End users | Arabic-speaking shop owners / warehouse managers, one-handed counter use |
| AI agents (opencode + Spec Kit) | Spec generation, code changes, must obey `AGENTS.md` + `.specify/memory/constitution.md` |

**Governance:** `.specify/memory/constitution.md` v1.10.1 supersedes ad-hoc practices. Amendments require PR proposal + 2 approvals (or maintainer + 24h), SemVer bump, and sync of `CHANGELOG.md`, `AGENTS.md`, `.specify/templates/*`.

---

## 2. Architecture Summary

### 2.1 Tech Stack

| Layer | Technology | Version | Notes |
|-------|-----------|---------|-------|
| Framework | Flutter | SDK constraint `^3.12.2` (Dart) | Constitution states Flutter 3.44.x stable — verify (`flutter --version`) |
| Language | Dart | ^3.12.2 | Records/patterns/sealed classes used |
| State management | `flutter_bloc` (Cubit pattern, **not** Bloc) | ^9.1.1 | Sealed state classes |
| Dependency injection | `get_it` | ^9.2.1 | All registrations in `main.dart:configureDependencies()` |
| Database | `objectbox` + `objectbox_flutter_libs` | ^5.3.2 | Local, no sync; codegen via `objectbox_generator` ^5.3.2 |
| Codegen | `build_runner` | ^2.15.0 | Mandatory after model changes |
| Routing | Custom `AppRouter` + `AppNavigation` | — | **No** go_router |
| Navigation bar | `persistent_bottom_nav_bar_v2` | ^6.3.2 | Style8BottomNavBar, 5 tabs |
| Responsive | `flutter_screenutil` | ^5.9.3 | `designSize: Size(360, 690)` |
| Charts | `fl_chart` | ^0.68.0 | Dashboard period charts |
| Loading UX | `shimmer` | ^3.0.0 | Dashboard skeleton |
| Localization | `flutter_localizations` + `intl` | SDK / ^0.20.2 | `Locale('ar')` hardcoded, RTL |
| Media | `image_picker` ^1.2.2, `flutter_svg` ^2.3.0 | — | Product images, vector icons |
| Storage (KV) | `shared_preferences` | ^2.5.5 | `CacheHelper` (settings/flags only) |
| Utils | `equatable`, `gap`, `url_launcher`, `unorm_dart`, `path`, `path_provider` | — | `unorm_dart` powers Arabic normalization |
| Lints | `flutter_lints` + `analysis_options.yaml` | ^6.0.0 | Enables `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, `prefer_const_declarations` |
| Fonts | Cairo (`assets/fonts/Cairo.ttf`) | — | Single font family, non-negotiable |

### 2.2 System Components (textual diagram)

```
┌─────────────────────────────────────────────────────────────────┐
│                              UI LAYER                           │
│  features/*/presentation/views  +  features/*/presentation/     │
│  core/widgets (AppButton, AppTextField, AppDrawer, …)           │
│  AppTheme / AppColors / AppTextStyle  (zero hardcoded styling)  │
└───────────────▲───────────────────────────────▲─────────────────┘
                │ BlocBuilder (buildWhen)       │ AppNavigation.pushName
                │                               │ showSnackBar
┌───────────────┴───────────────┐   ┌───────────┴─────────────────┐
│        STATE LAYER            │   │       NAVIGATION LAYER      │
│  Cubits (sealed states)       │   │  AppRoutes (route names)    │
│  AppCubit (theme/locale)      │   │  AppRouter.generateRoute()  │
│  Product/Customer/Supplier/   │   │  pageRouteBuilderMethod()   │
│  Sell/Buy/Safe/Trans/Dashboard│   │  (custom slide transitions) │
└───────────────▲───────────────┘   └─────────────────────────────┘
                │ calls abstract interface
┌───────────────┴─────────────────────────────────────────────────┐
│                        DATA LAYER                               │
│  Abstract repositories  (ProductRepository, SellInvoiceRepo, …) │
│  Repository impls  (ObjectBox queries, write transactions)      │
│  TransactionChangeNotifier (cross-cubit refresh signal)         │
└───────────────▲─────────────────────────────────────────────────┘
                │ Box<T> read/write (TxMode.write)
┌───────────────┴─────────────────────────────────────────────────┐
│                        PERSISTENCE                              │
│  ObjectBox Store — 10 @Entity boxes (see §4.2)                  │
│  SharedPreferences — CacheHelper (KV flags)                     │
│  NO network layer exists (by design)                            │
└─────────────────────────────────────────────────────────────────┘

DI (GetIt): CacheHelper → ObjectBoxServices → TransactionChangeNotifier
            → Repositories (LazySingleton) → Cubits (LazySingleton)
            [order is mandatory — main.dart:91-183]
```

### 2.3 Data Flows

**A. Sell invoice creation (atomic write transaction):**
```
SellingInvoiceView → SellInvoiceCubit.confirmInvoice()
  → SellInvoiceRepositoryImpl.createSellingInvoice(items, customer, discount)
     TxMode.write:
       1. new SellingInvoiceModel(date=now, discount) + customer.target
       2. per item: product.quantity -= qty; productsBox.put(product)
       3. sellingInvoicesBox.put(invoice)
       4. safeBalance.balance += (Σ lineTotal − discount)
       5. TransactionsEntry(type=sellingInvoice, signedValue=+amount,
                             referenceId=invoice.id, profit=invoice.profit)
       6. TransactionChangeNotifier.notify(sellingInvoice)
  ← DashboardCubit / SafeCubit / TransactionsCubit refresh via notifier
  → showSnackBar('تم الحفظ بنجاح')
```

**B. Buy invoice creation:** same shape, but `product.quantity += qty`, balance `−= total`, guard: **throws if `total > currentBalance`** (insufficient safe funds), `signedValue = −total`.

**C. Expense / adjustment:** `SafeRepositoryImpl.addExpense()` / `adjustBalance()` write `ExpenseModel`/`ManualAdjustmentModel`, update `SafeBalanceModel` (box id 1), append `TransactionsEntry`, notify. ⚠️ Sign conventions are inconsistent — see §11-I2/I3.

**D. Search:** all search inputs are normalized with `.normalizeArabic()` (diacritics/alef variants), then:
- purely numeric query → `barcode.contains(...)`
- otherwise → `name.contains(..., caseSensitive: false)` ordered by name

**E. Dashboard:** `DashboardRepositoryImpl.getDashboardData(period)` caches per-period snapshots (`DashboardModel`), buckets `TransactionsEntry` rows into 8×3h (today) / 7d (week) / Ndays (month) / 12mo (year) `ChartPoint`s, and computes `KpiModel { netProfit, sales, purchases, expenses }`.

### 2.4 High-Level Architecture Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Persistence | ObjectBox local only | Offline-first requirement; no backend exists |
| State | Cubit, not Bloc | Simpler; YAGNI (constitution V) |
| Routing | Named routes + custom transitions | Predictable RTL transitions; no extra dep |
| DI | GetIt manual registration | Explicit order; no code-gen beyond ObjectBox |
| Cross-feature refresh | `TransactionChangeNotifier` | Decouples invoice writes from dashboard/safe/history |
| Styling | Central `AppTheme` component themes | Constitution III/IX — non-negotiable |
| Reactivity | ObjectBox `query().watch()` mandated | No `getAll()` in build methods (constitution IV) |

---

## 3. Feature Set

Prioritization: **P0 = MVP (must ship)**, **P1 = post-MVP within v1.x**, **P2 = future/undecided**.

### 3.1 MVP Features (P0)

#### F1 — Product / Inventory Management
| Field | Value |
|-------|-------|
| Priority | P0 |
| Location | `features/inventory/`, `core/widgets/product_form_view.dart` |
| User story | *As a shop owner, I add a product with barcode, prices and photo so that I can sell it and track stock.* |

Acceptance criteria:
- [x] Create/edit/delete product with `name`, `barcode` (unique), `imgPath`, `quantity`, `buyingPrice`, `sellingPrice`, `wholesalePrice`
- [x] Barcode uniqueness enforced (`ProductRepository.isBarcodeTaken`, `ProductBarcodeTakenException`)
- [x] Search by name (Arabic-normalized, case-insensitive) or numeric barcode
- [x] Product card shows quantity badge (success/error color for in/zero stock)
- [ ] Barcode **camera scanning** (P1 — not implemented)

#### F2 — Sell Invoice
| Field | Value |
|-------|-------|
| Priority | P0 |
| Location | `features/selling_invoice/` |
| User story | *As a cashier, I select a customer, add products with quantity counters, apply a discount and confirm — so that stock and cash update instantly.* |

Acceptance criteria:
- [x] Customer dropdown with search; product selection view with counters
- [x] `subtotal`, `discount`, `totalAfterDiscount` computed in cubit
- [x] Confirmation runs one ObjectBox write transaction: stock ↓, safe ↑, invoice persisted, audit entry written
- [x] Invoice profit computed as `Σ(lineTotal − unitCost×qty) − discount`
- [ ] Partial payment / `paidAmount` (not in current model — see §11-I5)

#### F3 — Buy Invoice
| Field | Value |
|-------|-------|
| Priority | P0 |
| Location | `features/buying_invoice/` |
| User story | *As a shop owner, I record a purchase from a supplier so that stock increases and cash decreases automatically.* |

Acceptance criteria:
- [x] Supplier dropdown, product selection with counters, per-line price override dialog
- [x] Atomic write: stock ↑, safe ↓, invoice + audit entry
- [x] Blocked when `total > safe balance` (throws Arabic error message)
- [ ] Supplier running balance (not in model — §11-I5)

#### F4 — Safe Balance & Expenses
| Field | Value |
|-------|-------|
| Priority | P0 |
| Location | `features/safe/` |
| User story | *As a shop owner, I see my current cash balance, log expenses, and correct the balance with a note.* |

Acceptance criteria:
- [x] Balance card with `SafeBalanceModel` (singleton box id 1)
- [x] Add expense (`note`, `value`, `date`) → expense list grouped by date with search
- [x] Manual balance adjustment creates `ManualAdjustmentModel` (prev → new + note)
- [ ] ⚠️ Expense sign convention must be corrected/confirmed (§11-I2)

#### F5 — Operations / Transaction History
| Field | Value |
|-------|-------|
| Priority | P0 |
| Location | `features/transactions/` |
| User story | *As a shop owner, I review all money movements in one list, filter by type/date, and open invoice details.* |

Acceptance criteria:
- [x] Unified list from `TransactionsEntry` (date headers with count/total)
- [x] Filter by `TransactionType` and `DateTimeRange`; clear filters
- [x] Drill-down: `InvoiceDetailsView` for sell/buy invoices and manual adjustments
- [x] Search by reference name (customer/supplier description)

#### F6 — Dashboard Analytics
| Field | Value |
|-------|-------|
| Priority | P0 |
| Location | `features/dashboard/` |
| User story | *As a shop owner, I open the app and immediately see profit, sales, purchases, expenses and safe balance for today/week/month/year.* |

Acceptance criteria:
- [x] KPI cards (`KpiModel`) + period selector (today/week/month/year)
- [x] Chart metric switch (netProfit/sales/purchases/expenses) with `fl_chart`
- [x] Loading skeleton (shimmer) and empty state with CTA
- [x] 4 quick-add cards (sell invoice, customer, supplier, product)
- [x] Snapshot caching per period; invalidated by `TransactionChangeNotifier`

#### F7 — Customer & Supplier Management
| Field | Value |
|-------|-------|
| Priority | P0 |
| Location | `features/customers/`, `features/suppliers/`, `core/widgets/*_form_view.dart` |
| User story | *As a shop owner, I maintain a directory of customers and suppliers with phone/address so invoices can reference them.* |

Acceptance criteria:
- [x] CRUD forms with validation (`core/utils/validators.dart`, `phone_utils.dart`)
- [x] Lists with Arabic-normalized search
- [x] Reachable from drawer and dashboard quick-add

#### F8 — App Shell, Navigation & Theming
| Field | Value |
|-------|-------|
| Priority | P0 |
| Location | `features/main/`, `core/config/`, `core/navigations/`, `core/utilities/` |
| User story | *As a user, I move between Dashboard/Operations/Inventory/Safe/Settings via bottom nav and open secondary screens via the drawer — always in Arabic RTL.* |

Acceptance criteria:
- [x] 5-tab `persistent_bottom_nav_bar_v2` (Style8) + drawer (Customers, Suppliers, Settings, Buying Invoices)
- [x] All navigation through `AppNavigation` (never raw `Navigator`)
- [x] All feedback through `showSnackBar` (never `ScaffoldMessenger`)
- [x] Light theme active; dark theme defined but `themeMode: ThemeMode.light` hardcoded (`main.dart:80`)
- [x] Centralized Arabic strings (`core/constants/app_strings.dart`)

### 3.2 Post-MVP (P1)

| ID | Feature | Notes |
|----|---------|-------|
| F9 | Theme toggle wired to `AppCubit` | One-line `themeMode` change + settings UI |
| F10 | Barcode camera scanning | `mobile_scanner` or `flutter_barcode_scanner`; decision pending in `PRODUCT.md` |
| F11 | Return receipts | `TransactionType.returnReceipt` exists; no model/UI/repo yet |
| F12 | Export reports (CSV/PDF) | Undecided format |
| F13 | Thermal printer / receipt sharing | Bluetooth ESC/POS undecided |
| F14 | Settings screen (currently placeholder `SettingsView`) | Theme, data reset, about |
| F15 | Customer/supplier running balance ledger | Requires schema addition |

### 3.3 Future / Undecided (P2)

VAT/tax calculation · multi-user/roles · cloud backup/sync (explicitly out of scope) · other locales · tablet/desktop layouts.

---

## 4. API Contracts and Data Models

> **There is no HTTP/REST API.** The app is offline-only; the "API surface" is the **repository interface layer** (abstract classes), the **cubit contracts**, and the **ObjectBox entity schema**. Contracts mirror the format used in `specs/*/contracts/*.md`.

### 4.1 Repository Contracts (Local API)

#### `ProductRepository`
```dart
abstract class ProductRepository {
  List<ProductModel> getAllProducts();
  void insertProduct(ProductModel product);
  void deleteProduct(int id);
  List<ProductModel> searchProduct(String query);
  bool isBarcodeTaken(String barcode, {int? excludeProductId});
}
```

| Method | Preconditions | Postconditions | Errors |
|--------|---------------|----------------|--------|
| `getAllProducts()` | Store opened | All products ordered by name | — |
| `insertProduct(p)` | name/prices valid | Product upserted; barcode unique | throws `ProductBarcodeTakenException` |
| `deleteProduct(id)` | `id > 0` | Product removed | — |
| `searchProduct(q)` | — | Arabic-normalized; numeric ⇒ barcode match, else name match | returns `[]` |
| `isBarcodeTaken(b, excludeProductId:)` | — | `true` if another product holds barcode | — |

#### `SellInvoiceRepository`
```dart
abstract class SellInvoiceRepository {
  List<CustomerModel> getAllCustomers();
  List<ProductModel> getAllProducts();
  List<ProductModel> searchProducts(String query);
  void createSellingInvoice({
    required List<InvoiceItemModel> items,
    required CustomerModel customer,
    required double discount,   // impl signature: double? discount
  });
}
```

| Method | Preconditions | Postconditions | Errors |
|--------|---------------|----------------|--------|
| `createSellingInvoice` | `items` non-empty, every `product.target != null`, qty > 0 | Invoice + items persisted; each product qty `−= item.quantity`; safe `+= ΣlineTotal − discount`; `TransactionsEntry(sellingInvoice, +amount, profit)`; notifier fired | ObjectBox tx error aborts whole transaction (rollback) |

#### `BuyInvoiceRepository`
```dart
abstract class BuyInvoiceRepository {
  List<SupplierModel> getAllSuppliers();
  List<ProductModel> searchProducts(String query);
  void insertProduct(ProductModel product);
  void createBuyingInvoice({
    required List<InvoiceItemModel> items,
    required SupplierModel supplier,
  });
}
```

| Method | Preconditions | Postconditions | Errors |
|--------|---------------|----------------|--------|
| `createBuyingInvoice` | items valid **and** `ΣlineTotal ≤ safeBalance` | Invoice persisted; product qty `+= qty`; safe `−= total`; `TransactionsEntry(buyingInvoice, −total)`; notifier fired | throws String «الرصيد غير كافٍ…» when funds insufficient (⚠️ should be a typed exception — §11-I4) |
| `insertProduct` | barcode unique (unless updating same id) | Product upserted | `ProductBarcodeTakenException` |

#### `SafeRepository`
```dart
abstract class SafeRepository {
  SafeBalanceModel getBalance();
  void adjustBalance({required double newAmount, String? newNote});
  List<ExpenseModel> loadExpenses(String searchQuery);
  void addExpense(ExpenseModel expense);
}
```

#### `CustomerRepository` / `SupplierRepository`
```dart
abstract class CustomerRepository {
  List<CustomerModel> getAllCustomers();
  void insertCustomer(CustomerModel customer);
  List<CustomerModel> searchCustomers(String search);
}
abstract class SupplierRepository {
  List<SupplierModel> getAllSuppliers();
  List<SupplierModel> searchSuppliers(String query);
  void insertSupplier(SupplierModel supplier);
}
```

#### `TransactionsRepository`
```dart
abstract class TransactionsRepository {
  List<TransactionsEntry> getTransactions({TransactionType? type, DateTimeRange? dateRange});
  BuyingInvoiceModel getBuyingInvoice(int id);
  SellingInvoiceModel getSellingInvoice(int id);
  ManualAdjustmentModel getManualAdjustment(int id);
}
```

#### `DashboardRepository`
```dart
abstract class DashboardRepository {
  late DashboardModel cachedDashboardSnapshot;
  void clearCachedDashboardSnapshot();
  DashboardPeriodSnapshot getDashboardData({required DashboardPeriod period});
  DashboardPeriodSnapshot getDashboardSnapshot({required DashboardPeriod period});
  DateTimeRange getTimeRange(DashboardPeriod period);
  List<TransactionsEntry> getEntries(DashboardPeriod period);
  double getBalance();
}
```

### 4.2 Data Models (ObjectBox Entities — 10)

| Entity | File | Key fields | Indexes / relations |
|--------|------|-----------|---------------------|
| `ProductModel` | `product_model.dart` | `id`, `name`, `barcode?`, `imgPath?`, `quantity`, `buyingPrice`, `sellingPrice`, `wholesalePrice` | `@Index name`, `@Index @Unique barcode` |
| `CustomerModel` | `customer_model.dart` | `id`, `name`, `address?`, `phoneNum` | `@Index name`; `@Backlink ToMany<SellingInvoiceModel> invoices` |
| `SupplierModel` | `supplier_model.dart` | `id`, `name`, `storeAdd?`, `storeName`, `phoneNum` | `@Index name` |
| `SellingInvoiceModel` | `selling_invoice_model.dart` | `id`, `date`, `discount?` | `@Index date`; `ToMany<InvoiceItemModel> items`; `ToOne<CustomerModel> customer`; getter `profit` |
| `BuyingInvoiceModel` | `buying_invoice_model.dart` | `id`, `date` | `@Index date`; `ToMany<InvoiceItemModel> items`; `ToOne<SupplierModel> supplier`; total computed ad hoc by callers (no `total` getter defined) |
| `InvoiceItemModel` | `invoice_item_model.dart` | `id`, `quantity`, `unitPrice`, `unitCost?`, `lineTotal`, `name` | `ToOne<ProductModel> product` |
| `ExpenseModel` | `expense_model.dart` | `id`, `date`, `value`, `note` | `@Index date` |
| `SafeBalanceModel` | `safe_balance_model.dart` | `id`, `currentBalance`, `lastUpdated`, `note?` | singleton (box id 1) |
| `ManualAdjustmentModel` | `manual_adjustment_model.dart` | `id`, `date`, `prevBalanceValue`, `newBalanceValue`, `note?` | `@Index date` |
| `TransactionsEntry` | `transactions_entry.dart` | `id`, `typeIndex`, `createdAt`, `signedValue`, `referenceId`, `profit?`, `description?` | `@Index typeIndex`, `@Index createdAt` |

Supporting enums/models (non-entity): `TransactionType { sellingInvoice, buyingInvoice, expense, returnReceipt, manualAdjustment }`, `DashboardPeriod { today, week, month, year }`, `DashboardMetric { netProfit, sales, purchases, expenses }`, `KpiModel`, `ChartPoint`, `DashboardPeriodSnapshot`, `DashboardModel`, `ListItemModel { HeaderItem, TransactionItem }`, `ExpenseListItem { ExpenseHeaderItem, ExpenseItem }`, `InvoiceDetailsModel`.

#### Example payloads (canonical JSON projection)

**Product**
```json
{
  "id": 12,
  "name": "شاي ليبتون 100 كيس",
  "barcode": "6221031954017",
  "imgPath": "/data/user/0/com.example.inventra/cache/img_01.jpg",
  "quantity": 48,
  "buyingPrice": 18.50,
  "sellingPrice": 25.00,
  "wholesalePrice": 22.00
}
```

**Sell invoice (with items)**
```json
{
  "id": 101,
  "date": "2026-09-27T13:45:00.000",
  "discount": 5.00,
  "customer": { "id": 3, "name": "أحمد محمد", "address": "الرياض", "phoneNum": "0555123456" },
  "items": [
    { "id": 900, "name": "شاي ليبتون", "quantity": 2, "unitPrice": 25.00,
      "unitCost": 18.50, "lineTotal": 50.00, "productId": 12 }
  ],
  "computed": { "subtotal": 50.00, "total": 45.00, "profit": 13.00 }
}
```

**Transaction audit entry**
```json
{
  "id": 5001,
  "typeIndex": 0,
  "type": "sellingInvoice",
  "createdAt": "2026-09-27T13:45:00.000",
  "signedValue": 45.00,
  "referenceId": 101,
  "profit": 13.00,
  "description": "أحمد محمد"
}
```

**Safe balance**
```json
{ "id": 1, "currentBalance": 3250.75, "lastUpdated": "2026-09-27T18:02:11.000", "note": "تسوية نهاية اليوم" }
```

### 4.3 Cubit Contracts (State API)

| Cubit | Interface file | Key operations | States (sealed) |
|-------|----------------|----------------|-----------------|
| `AppCubit` | `core/.../app_cubit.dart` | `init()`, theme getter | `AppInitialState`, `ThemeChangesState` |
| `ProductCubit` | `product_cubit_interface.dart` | `loadProducts`, `searchProducts`, `add/update/deleteProduct` | Initial, Loading, `ProductsLoadingSuccessed`, `ProductInsertedSuccessed`, `ProductInsertError`, `ProductErrorState` |
| `CustomerCubit` | `customer_cubit_interface.dart` | `loadCustomers`, `searchCustomers`, `insertCustomer` | Initial, Loading, `CustomerLoadingSuccessed`, `CustomerLoadingError`, `CustomerUpdated` |
| `SupplierCubit` | `supplier_cubit_interface.dart` | `loadSuppliers`, `searchSuppliers`, `insertSupplier` | (mirrors customer) |
| `SellInvoiceCubit` | `sell_invoice_cubit_interface.dart` | `loadCustomers/loadProducts`, `selectCustomer`, `addProductItemLine`, `updateItemQuantity`, `removeItem`, `setDiscount`, `validateSellInvoice`, `confirmInvoice` | Initial, Loading, DiscountChanged, Confirmed, AddProductItem, UpdateProductQuantity, RemoveProduct, ProductLoading/Successed/Error, Error |
| `BuyInvoiceCubit` | `buy_invoice_cubit_interface.dart` | `loadSuppliers/loadProducts`, `selectSupplier`, `addProductItem`, `updateItemQuantity`, `removeItem`, `validateBuyInvoice`, `confirmInvoice` | Initial, Loading, ProductsLoaded, ProductLoading/ Error, AddProductItem, UpdateProductQuantity, RemoveProduct, Confirmed, Error |
| `SafeCubit` | `safe_cubit_interface.dart` | `addExpense`, `searchForExpenses`, `clearSearchFilter`, `adjustBalance` | Initial, Loading, `SafeLoaded{safeBalance, expenseListItem}`, Error |
| `TransactionsCubit` | `transactions_cubit_interface.dart` | `loadTransactions(type?, dateRange?)`, `clearFiltersAndGetTransactions`, `getInvoiceDetails`, `generateListItems` | Initial, Loading, `Loaded{listItems}`, Error |
| `DashboardCubit` | `dashboard_cubit_interface.dart` | `init`, `loadDashboard`, `changePeriod`, `changeChartMetric`, `refresh` | Initial, Loading, `Loaded{snapshot, metric, period, safeBalance}`, Error |

**Rules (constitution IV/VIII):** every `BlocBuilder` must declare `buildWhen`; every `BlocListener` must declare `listenWhen`; each state body (Loading/Error/Loaded) is a separate widget class (`SafeLoadingBody`, `SafeErrorBody`, `SafeLoadedBody`).

### 4.4 Route Contract

| Route constant | Path | Arguments | Screen |
|----------------|------|-----------|--------|
| `mainView` | `/` | — | `MainView` (shell) |
| `productFormView` | `/addProductView` | `ProductDetailsArguments? {product, isQuantitiyEditable}` | `ProductFormView` (returns `ProductModel?`) |
| `supplierFormView` | `/edit-supplier` | `SupplierModel?` | `SupplierFormView` |
| `customerFormView` | `/customerFormView` | `CustomerModel?` | `CustomerFormView` |
| `addExpenseView` | `/addExpenseView` | — | `AddExpenseView` |
| `sellingInvoiceView` | `/selling-invoice` | — | `SellingInvoiceView` (cubit `..loadCustomers()`) |
| `addProductToInvoice` | `/add-product-to-invoice` | — | `SellingProductSelectionView` |
| `buyingInvoiceView` | `/buying-invoice` | — | `BuyingInvoiceView` (cubit `..loadSuppliers()`) |
| `productSelectionView` | `/product-selection` | — | `BuyingProductSelectionView` |
| `allCustomers` | `/all-customers` | — | `AllCustomersView` |
| `allSuppliers` | `/all-suppliers` | — | `AllSuppliersView` |
| `settings` | `/settings` | — | `SettingsView` (placeholder) |
| `invoiceDetailsView` | `/invoice-details` | `InvoiceDetailsModel` (required) | `InvoiceDetailsView` |
| default | any other | — | empty `Scaffold` fallback |

Navigation API (only these are permitted):
```dart
AppNavigation.pushName(context: context, route: AppRoutes.x, argument: a, rootNavigator: false);
AppNavigation.pushWithReplacement(context: context, route: AppRoutes.x);
AppNavigation.pushAndRemoveUntil(context: context, route: AppRoutes.x);
AppNavigation.pop(context, result);
showSnackBar(context, 'تم الحفظ بنجاح');           // color: AppColors.error on failure
```

---

## 5. Codebase Layout

```
E:\inventra\
├── lib/                         # 148 Dart files, ~11,900 lines
│   ├── main.dart                # entry point, DI (configureDependencies), MaterialApp
│   ├── objectbox.g.dart         # GENERATED — never hand-edit
│   ├── objectbox-model.json     # GENERATED — schema fingerprint
│   ├── core/                    # cross-feature foundation (no feature→core→feature cycles)
│   │   ├── config/              # AppRouter + AppRoutes + route arguments
│   │   ├── constants/           # app_strings.dart (centralized Arabic copy)
│   │   ├── controller/          # AppCubit (theme/locale app-wide state)
│   │   ├── exceptions/          # ProductBarcodeTakenException
│   │   ├── helper/              # CacheHelper/ObjectBoxServices, dialogs, arabic_normalizer, showSnackBar
│   │   ├── models/              # ObjectBox @Entity classes (single source of schema truth)
│   │   ├── navigations/         # AppNavigation (sole Navigator wrapper)
│   │   ├── observer.dart        # AppBlocObserver (debug logging)
│   │   ├── services/            # TransactionChangeNotifier
│   │   ├── transitions/         # pageRouteBuilderMethod + slide transition
│   │   ├── utilities/           # AppTheme, AppColors, AppTextStyle, assets.dart (generated), GlobalKeys
│   │   ├── utils/               # formatters, validators, phone_utils
│   │   └── widgets/             # shared UI: AppButton, AppTextField, AppDrawer, CustomAppBar,
│   │                            # search_field, quantity_counter, *_form_view, empty/error states, add_image
│   ├── features/                # 10 feature modules (vertical slices)
│   │   └── <feature>/
│   │       ├── controller/cubit/     # Cubit + sealed state + abstract interface
│   │       ├── data/repositories/    # abstract repo + ObjectBox impl
│   │       ├── data/models|enums/    # feature-local DTOs (dashboard, transactions, safe)
│   │       ├── presentation/views/   # screens (one widget class per file)
│   │       ├── presentation/widgets/ # extracted UI pieces (state bodies, cards, filters)
│   │       └── utils/                # e.g. transaction_type_extension
│   ├── buying_invoice/ customers/ dashboard/ inventory/ main/ safe/
│   ├── selling_invoice/ settings/ suppliers/ transactions/
├── test/                        # currently 1 smoke test (widget_test.dart)
├── specs/                       # Spec Kit feature specs (001–005) + checklists/contracts
├── .specify/                    # Spec Kit constitution, templates, PowerShell scripts
├── assets/                      # fonts/Cairo.ttf, images/, screenshots/
├── android/ ios/ web/ windows/ linux/   # platform shells
├── AGENTS.md                    # runtime guidance for AI agents
├── PRODUCT.md                   # product context (users, purpose, constraints)
├── DESIGN.md                    # design system tokens + rules
├── README.md                    # public-facing overview
└── SPECIFICATION.md             # this document
```

**Rationale**
- *Feature-first slices:* each feature owns cubit/repo/UI so it can be built, tested and reviewed independently on its own `feature/<spec-name>` branch.
- *`core/` holds only cross-cutting assets:* models, theme, navigation, shared widgets — features never duplicate them (constitution I forbids copy-paste reuse).
- *Abstract repo + impl pair per feature:* enables fake repos in unit tests without ObjectBox.
- *Interfaces for cubits:* contract documents double as test seams and Spec Kit `contracts/*.md` artifacts.
- *Generated code isolated:* `objectbox.g.dart` / `assets.dart` are machine-owned.

---

## 6. Non-Functional Requirements

### 6.1 Performance
| ID | Requirement | Target | Verification |
|----|-------------|--------|--------------|
| NFR-P1 | Cold start | < 2s (Snapdragon 680 / 4GB) | `flutter run --profile --trace-startup` |
| NFR-P2 | Jank frames on scroll-heavy screens | < 5% | DevTools timeline |
| NFR-P3 | Dashboard first paint | < 3s (cached snapshots make repeat visits near-instant) | manual + profile |
| NFR-P4 | ObjectBox queries | indexed fields only; `query().watch()` for reactivity; **no `getAll()` in build methods** | code review |
| NFR-P5 | Bloc rebuild control | `buildWhen` / `listenWhen` on every builder/listener | code review + lint |
| NFR-P6 | Image handling | `image_picker` with `maxWidth: 800` compression; SVG for icons | code review |
| NFR-P7 | Code health | files ≤ 300 LOC, cyclomatic complexity ≤ 10, `flutter analyze` clean | CI |

### 6.2 Security
| ID | Requirement | Notes |
|----|-------------|-------|
| NFR-S1 | Data-at-rest | ObjectBox store lives in app sandbox; no encryption today — evaluate `objectbox encryption` if device-loss risk materializes (P2) |
| NFR-S2 | No secrets in repo | No API keys exist (no backend); keep it that way |
| NFR-S3 | Input validation | Forms use `core/utils/validators.dart` + phone utils; barcode uniqueness DB-enforced |
| NFR-S4 | Safe-balance integrity | All mutations inside `store.runInTransaction(TxMode.write, …)` so partial writes are impossible |
| NFR-S5 | No network permissions | Android manifest must not request internet for core flows (verify before release) |
| NFR-S6 | Financial guard rails | Buy invoices reject insufficient funds; typed exception required (§11-I4) |

### 6.3 Accessibility & Localization
| ID | Requirement |
|----|-------------|
| NFR-A1 | Arabic-only RTL: `Locale('ar')`, `supportedLocales: [Locale('ar')]`, `flutter_localizations` delegates; never hardcode `textDirection: ltr` |
| NFR-A2 | Cairo font only, `.sp` scaling for dynamic text |
| NFR-A3 | Touch targets ≥ 48dp (Material baseline); one-handed counter use |
| NFR-A4 | Color contrast: `AppColors` pairs must meet WCAG AA in light **and** dark themes (audit pending for dark) |
| NFR-A5 | Arabic screen-reader labels via `Semantics` (TalkBack) — **not yet established**, P1 |
| NFR-A6 | Arabic normalization for all search inputs (`normalizeArabic()`) |

### 6.4 Compliance & Process
- **Constitution DoD (per PR):** `flutter analyze` clean · `flutter test --coverage` thresholds · `flutter build apk --debug` compiles · manual RTL smoke test · no new jank · `CHANGELOG.md` entry under `## [Unreleased]`.
- **Git:** only `feature/<spec-name>` branches; PR review required; **no direct pushes to main/master**; no force-push; **never push unless the user explicitly asks**.
- **Licensing:** private project, no public distribution.
- **Dependency policy:** every new dependency justified in PR description (constitution V).

---

## 7. Roadmap

> App is feature-complete for MVP; roadmap phases describe stabilization → release. Durations assume 1 contributor + AI agent support. Calendar anchored to 2026-09-27.

### Phase 0 — Audit & Stabilize (W1–W2, 2026-09-28 → 2026-10-11)
| Milestone | Work | Dependencies |
|-----------|------|--------------|
| M0.1 Document truth-up | Fix stale claims in `AGENTS.md`/`README.md`/`PRODUCT.md` (analysis_options exists; entity list; theme line number) | — |
| M0.2 Financial correctness review | Confirm & fix expense sign, manual-adjustment `signedValue`, dashboard expense→profit sign (§11-I2/I3) | M0.1 |
| M0.3 Error handling | Replace raw `String` throw in buy invoice with typed exception + `showSnackBar` mapping | M0.2 |
| M0.4 Baseline green | `flutter analyze` 0 issues; smoke test passes; `flutter build apk --debug` succeeds | M0.2, M0.3 |

### Phase 1 — Test Foundation (W3–W4, 2026-10-12 → 2026-10-25)
| Milestone | Work | Dependencies |
|-----------|------|--------------|
| M1.1 Unit harness | Fake repos + cubit tests for all 9 cubits | M0.4 |
| M1.2 Repository tests | ObjectBox test store: invoice reconciliation, barcode uniqueness, search normalization | M1.1 |
| M1.3 Coverage gate | core ≥ 90%, features ≥ 80% wired into CI | M1.2 |

### Phase 2 — MVP Feature Gaps (W5–W7, 2026-10-26 → 2026-11-15)
| Milestone | Work | Dependencies |
|-----------|------|--------------|
| M2.1 Settings screen | Real settings: theme toggle (wire `AppCubit` at `main.dart:80`), data info | M0.4 |
| M2.2 Theme enablement | Dark theme audit (contrast) + toggle | M2.1 |
| M2.3 Return receipts (P1) | `ReturnReceiptModel` + repo + UI; stock ↑, safe ↓ | M1.2 |
| M2.4 Barcode scanning (P1) | Choose camera-scanner package; scan → search field | M2.3 (independent, can parallel) |

### Phase 3 — Release Engineering (W8–W9, 2026-11-16 → 2026-11-29)
| Milestone | Work | Dependencies |
|-----------|------|--------------|
| M3.1 CI/CD | GitHub Actions: analyze → test → build APK/AAB (see §9) | M1.3 |
| M3.2 App identity | Replace `com.example.inventra` applicationId with real id; icon/splash; versioning | M0.4 |
| M3.3 Store assets | Screenshots (`assets/screenshots/`), Arabic listing copy | M2.x complete |
| M3.4 v1.0.0 release | Signed AAB, `CHANGELOG.md` 1.0.0, tag | M3.1–M3.3 |

### Phase 4 — Post-v1 (P1 backlog)
Export/report formats · thermal printing · customer/supplier ledgers · VAT · accessibility (TalkBack labels, dynamic type) · ObjectBox encryption evaluation.

**Dependency graph:** `M0.x → M1.x → M3.1`; `M0.4 → M2.x`; `M2.x + M3.1–3.3 → M3.4`.

---

## 8. Testing Strategy

**Current state:** 1 smoke test (`test/widget_test.dart`); no repository/cubit tests; no integration tests; no CI. Constitution DoD thresholds (core 90% / features 80%) are **not met** — Phase 1 exists to close this.

### 8.1 Test Pyramid

| Level | Tool | Scope | Target |
|-------|------|-------|--------|
| Unit | `flutter_test` | cubits (with fake repos), repository impls (temp ObjectBox store), normalizer, formatters, validators, dashboard bucketing | ≥ 80% of LOC |
| Widget | `flutter_test` + `mocktail` (optional) | state-body widgets, forms, cards, `buildWhen` behavior | all P0 screens |
| Integration | `integration_test` | sell/buy/expense end-to-end flows on emulator | 5 critical journeys |
| Manual | checklist | RTL rendering, Arabic copy, dark/light, one-handed flow | every release |

### 8.2 Test Layout (planned)
```
test/
├── unit/
│   ├── core/ (arabic_normalizer_test.dart, validators_test.dart, formatters_test.dart)
│   ├── features/inventory/product_cubit_test.dart, product_repository_test.dart
│   ├── features/selling_invoice/sell_invoice_repository_test.dart
│   ├── features/buying_invoice/buy_invoice_repository_test.dart
│   ├── features/safe/safe_repository_test.dart
│   ├── features/dashboard/dashboard_repository_test.dart
│   └── features/transactions/transactions_cubit_test.dart
├── widget/  (product_form_view_test.dart, safe_loaded_body_test.dart, …)
├── integration/ (sell_invoice_flow_test.dart, …)
└── widget_test.dart  (existing smoke test)
```

### 8.3 Sample Test Cases

**Unit — Arabic search normalization**
```dart
test('searchProducts matches diacritic-insensitive Arabic name', () {
  final repo = ProductRepositoryImpl(testObjectBox);
  repo.insertProduct(ProductModel(name: 'شاي ليبتون', quantity: 1,
      buyingPrice: 1, sellingPrice: 2, wholesalePrice: 1.5));
  expect(repo.searchProduct('ليبتونٌ').length, 1);      // with tanween
  expect(repo.searchProduct('622103').length, 0);        // no barcode match
});
```

**Unit — sell invoice reconciliation (atomicity)**
```dart
test('createSellingInvoice decrements stock and increments safe balance', () {
  final product = …; // quantity 10, lineTotal 50, discount 5
  sellRepo.createSellingInvoice(items: [item], customer: customer, discount: 5);
  expect(productRepo.getAllProducts().single.quantity, 9);
  expect(safeRepo.getBalance().currentBalance, initialBalance + 45);
  final entry = transactionsRepo.getTransactions(type: TransactionType.sellingInvoice);
  expect(entry.single.signedValue, 45);
});
```

**Unit — buy invoice insufficient funds**
```dart
test('createBuyingInvoice throws when total exceeds safe balance', () {
  safeRepo.adjustBalance(newAmount: 10, newNote: 'seed');
  expect(() => buyRepo.createBuyingInvoice(items: [item50], supplier: supplier),
      throwsA(isA<InsufficientBalanceException>()));
  expect(buyRepo.getAllBuyInvoices(), isEmpty);   // rolled back
});
```

**Unit — barcode uniqueness**
```dart
test('duplicate barcode rejected except self-update', () {
  expect(() => productRepo.insertProduct(dup), throwsA(isA<ProductBarcodeTakenException>()));
  expect(() => productRepo.insertProduct(sameProductUpdated), returnsNormally);
});
```

**Widget — state body selection**
```dart
testWidgets('SafeView renders SafeLoadingBody then SafeLoadedBody', (tester) async {
  await tester.pumpWidget(appWith(safeCubit emitting SafeLoaded(...)));
  expect(find.byType(SafeLoadedBody), findsOneWidget);
});
```

**Widget — nav/snackbar conventions**
```dart
testWidgets('save button shows snackbar via helper, not ScaffoldMessenger', …);
```

**Integration — critical journey (30s target)**
1. Launch → Inventory → add product with barcode → back
2. Dashboard → quick-add Sell Invoice → pick customer → pick product ×2 → confirm
3. Safe tab → balance increased by line total → Transactions tab → entry present with drill-down

### 8.4 Coverage & Quality Gates
```bash
flutter analyze                      # 0 errors
flutter test --coverage              # core ≥90%, features ≥80%
genhtml coverage/lcov.info -o coverage/html   # report
flutter build apk --debug            # compile gate
```
Gates block merge (constitution §X). Coverage measured per-directory, not global.

---

## 9. Deployment Plan

### 9.1 Environments

| Env | Purpose | Data | Platform |
|-----|---------|------|----------|
| **dev** | `flutter run` on connected device/emulator | disposable ObjectBox store (uninstall clears) | any |
| **staging** | Internal QA builds, manual checklist | test data seeded manually | Android APK (unsigned/debug-signed) |
| **prod** | End-user release | device-local production store | Android AAB (Play) / direct APK |

> No server environments exist — offline-only product.

### 9.2 Build Commands
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after ANY model change
flutter analyze
flutter test --coverage
flutter build apk --debug          # staging smoke
flutter build appbundle --release  # production (Play)
flutter build apk --release        # sideload distribution
```

### 9.3 CI/CD (to be created — `.github/workflows/ci.yml`)

```yaml
name: CI
on:
  pull_request: { branches: [main] }
  push: { branches: [main] }
jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { channel: stable, cache: true }
      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: flutter analyze
      - run: flutter test --coverage
      # coverage thresholds: fail build under core 90% / features 80%
      - uses: actions/upload-artifact@v4
        with: { name: coverage, path: coverage/lcov.info }
  build:
    needs: quality
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { channel: stable, cache: true }
      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: flutter build appbundle --release
      - uses: actions/upload-artifact@v4
        with: { name: app-release-aab, path: build/app/outputs/bundle/release/app-release.aab }
```

**Pipeline order (PR):** checkout → Flutter setup → `pub get` → ObjectBox codegen → analyze → test+coverage → (main only) build AAB → upload artifact.

**Release flow:** merge PR to `main` → tag `vX.Y.Z` → CI builds signed AAB (signing keys via GitHub Secrets, **never committed**) → internal testing track → staged rollout.

### 9.4 Versioning & Release Numbering
- `pubspec.yaml version: MAJOR.MINOR.PATCH+BUILD` — bump PATCH for fixes, MINOR for features, MAJOR for schema-breaking ObjectBox changes (requires data migration plan).
- Git tags `vX.Y.Z`; `CHANGELOG.md` keeps `## [Unreleased]` + released sections (convention: `feat:`, `fix:`, `perf:`, `refactor:`).
- Android `versionCode` = build number, monotonic.

### 9.5 Rollback Procedures

| Scenario | Action |
|----------|--------|
| CI fails post-merge | Revert PR commit on `main` (`git revert <sha>`), re-run pipeline — never force-push |
| Bad release reaches staging | Re-promote previous known-good artifact (keep last 5 AAB artifacts in CI storage) |
| Bad release on Play | Use Play Console **staged rollout halt** + promote previous release to 100% |
| ObjectBox schema regression (crash on open) | Ship forward-fix with schema bump + migration; keep pre-upgrade store backup instructions for testers (`adb pull` of `objectbox/` dir); never downgrade schema silently |
| Regressive UI bug | Feature-flag not available (no flags by design) → hotfix branch `hotfix/<issue>` off `main`, full DoD, expedited review |

### 9.6 Pre-Release Checklist
- [ ] applicationId changed from `com.example.inventra` → production id (§11-I8)
- [ ] Version bumped in `pubspec.yaml` + `CHANGELOG.md`
- [ ] `flutter analyze` clean, coverage gates green
- [ ] RTL manual smoke test (Arabic copy, mirrored nav, forms, snackbar)
- [ ] Real-device pass: sell, buy, expense, adjustment, filter, drill-down
- [ ] App icon, splash, Arabic store listing, screenshots
- [ ] Release keystore stored securely + documented

---

## 10. Maintenance and Handoff

### 10.1 Contributor Guidelines

**Setup**
```bash
git clone <repo> && cd inventra
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

**Workflow (mandatory)**
1. Read `.specify/memory/constitution.md` (v1.10.1) and `AGENTS.md`.
2. Spec first for non-trivial work: `specs/NNN-<kebab-name>/spec.md` (templates in `.specify/templates/`).
3. Branch: `git checkout -b feature/<spec-name>` — **never** commit to `main`/`master`.
4. Implement, commit frequently with conventional messages (`feat:`, `fix:`, `refactor:`, `perf:`, `test:`).
5. Self-review against DoD; open PR; wait for review/merge.
6. **Push only when the user explicitly requests it.**

**Hard conventions (violations block PR)**
| Area | Rule |
|------|------|
| Imports | `package:Inventra/...` (capital I) |
| Navigation | `AppNavigation.*` only — no `Navigator.of(context)` |
| Snackbars | `showSnackBar(context, msg)` only — no `ScaffoldMessenger` |
| Colors / text styles | `AppColors` / `AppTextStyle` only — add missing tokens there first |
| Decorations / themes | Define in `AppTheme` component themes — never inline `BoxDecoration`, `InputDecoration`, `ButtonStyle`, `MenuStyle` |
| Inputs / buttons | `AppTextField` / `AppButton` only |
| Widget structure | No inline `Widget Function()` builders or `_build*()` — extract to classes; one public widget per file |
| BlocBuilder/Listener | `buildWhen` / `listenWhen` required; each state body = separate widget class |
| Const | Use `const` everywhere possible (lint-enforced) |
| Sizing | `.w`, `.h`, `.sp` (ScreenUtil 360×690) |
| Data layer | Abstract repo + impl; ObjectBox tx for multi-write ops; indexed queries; no `getAll()` in build |
| DI | Register in `main.dart:configureDependencies()` preserving order |
| DB changes | Always rerun `build_runner`; commit generated files |

**Common tasks** (see `AGENTS.md` for full steps): add entity · add feature screen · add drawer item · modify theme · add dependency (`flutter pub add <pkg>` + PR justification).

### 10.2 Documentation Standards

| Doc | Purpose | Update trigger |
|-----|---------|----------------|
| `SPECIFICATION.md` (this file) | Authoritative, self-contained project spec | Any change to scope/architecture/features/NFR/roadmap — **regenerate** |
| `AGENTS.md` | Runtime guidance for AI agents | Any convention/command/structure change (keep in sync with constitution) |
| `PRODUCT.md` | Product context: users, purpose, constraints | Product/scope decisions |
| `DESIGN.md` | Design tokens + component rules | Token/palette/typography/component changes |
| `README.md` | Public overview, quick start | Feature set / stack / screenshots change |
| `.specify/memory/constitution.md` | Governance principles | Formal amendment process only (SemVer + changelog) |
| `specs/NNN-*/` | Per-feature spec, plan, tasks, contracts, checklists | During feature development |
| `CHANGELOG.md` | Release history (to be created) | Every PR (Unreleased section) |

Doc rules: Arabic UI strings quoted verbatim in examples; file references use `path:line`; never document features that don't exist (Absences list in `PRODUCT.md` must stay honest); keep tables in sync with code — a discrepancy is a bug (see §11).

### 10.3 Versioning Summary
- **Code/package:** SemVer via `pubspec.yaml version` (+build).
- **Constitution:** SemVer (MAJOR = principle removal, MINOR = new principle, PATCH = clarification), with Sync Impact Report comment.
- **Database:** ObjectBox schema version bumps require migration notes in `CHANGELOG.md`.
- **Branches:** `feature/<spec-name>`, `hotfix/<issue>`; release tags `vX.Y.Z`.

### 10.4 Handoff Package (what a new maintainer receives)
1. This `SPECIFICATION.md` (system map + contracts + roadmap)
2. `PRODUCT.md` (why) · `DESIGN.md` (look) · `AGENTS.md` (how to work)
3. Constitution (rules) · `specs/` (feature history) · git history/PRs
4. Credentials/handoff checklist: Android keystore + passwords (secure channel, never in repo), Play Console access, GitHub secrets, Flutter SDK path (`E:\flutter`), repo `github.com/yousefa7med/Inventra`
5. Known-issues register: §11 below

---

## 11. Appendix: Known Discrepancies & Open Issues

> Found during full-repo scan (2026-09-27). Severity: **P0** = correctness, **P1** = release blocker, **P2** = tech debt.

| ID | Sev | Issue | Evidence | Action |
|----|-----|-------|----------|--------|
| I1 | P0 | **Docs stale:** `AGENTS.md`/`PRODUCT.md` claim "no `analysis_options.yaml`" — it exists with const lints; entity list claims `ReturnReceipt` (model absent); theme line refs off | `analysis_options.yaml`; `lib/core/models/` (10 entities) | Truth-up pass (M0.1) |
| I2 | P0 | **Expense sign inconsistency:** `SafeRepositoryImpl.addExpense()` does `balance + expense.value` (increases safe) while business flow table says expenses **decrease** safe; `signedValue` stored positive; dashboard then **adds** expense to `netProfit` (`entryProfit += entry.signedValue`) | `safe_repository_impl.dart`, `dashboard_repository_impl.dart` | Confirm intent, fix signs, add regression tests |
| I3 | P1 | **ManualAdjustment semantics:** `signedValue` set to *absolute new balance* instead of delta; dashboard ignores adjustment entries (`default: break`) so KPI history can silently diverge from safe balance | `safe_repository_impl.dart`, `dashboard_repository_impl.dart` | Store delta; decide whether adjustments affect net profit |
| I4 | P1 | **Raw `String` thrown** for insufficient buy-invoice funds (no typed exception, fragile mapping to UI) | `buy_invoice_repository_impl.dart` | Introduce `InsufficientBalanceException` + snackbar mapping |
| I5 | P2 | **AGENTS table vs code:** `SellInvoice/BuyInvoice` have no `paidAmount`; `Customer/Supplier` have no `balance`; `Supplier` uses `storeName/storeAdd` — "partial payments" and "running balance" in README not implemented | model files | Update docs; move to P1 backlog (F15) if still wanted |
| I6 | P2 | `SellingInvoiceModel.profit` uses `item.unitCost!` — null assertion crash risk when `unitCost` is null | `selling_invoice_model.dart` | Default cost to `buyingPrice` or guard |
| I7 | P2 | `InvoiceDetailsModel.fromBuyingInvoice` hardcodes `discount: 0` (TODO in code) | `invoice_details_model.dart` | Implement or remove discount row for buy invoices |
| I8 | P1 | Application id is placeholder `com.example.inventra` | `android/app/build.gradle*` | Rename before any release (M3.2) |
| I9 | P1 | **No CI/CD**, **no `CHANGELOG.md`** (constitution requires both) | `.github` missing; root | Phase 1/3 deliverables |
| I10 | P1 | **Test coverage ~0%** (1 smoke test) vs DoD 90/80 | `test/widget_test.dart` | Phase 1 |
| I11 | P2 | `themeMode: ThemeMode.light` hardcoded; `AppCubit` theme state ignored | `main.dart:80` | Wire in M2.1 |
| I12 | P2 | ProductCubit pulled directly from GetIt inside router + `..loadX()` side effects in route builders | `configrations.dart:48-148` | Move loading to view `initState`/cubit `onCreate` |
| I13 | P2 | Dashboard `today` buckets are 3-hour steps with fixed `bucketCount = 8` — edge cases around DST/midnight boundaries untested | `dashboard_repository_impl.dart` | Unit tests for bucketing |
| I14 | P2 | `ReturnReceipt` enum value exists with no model/UI — dead enum member | `transaction_type.dart` | Implement (F11) or remove |
| I15 | P2 | Flutter/Dart version claims differ (README "3.12+", constitution "3.44.x", pubspec `sdk: ^3.12.2`) | multiple docs | Standardize on `flutter --version` output |
| I16 | P2 | Dark theme unaudited (contrast) while `darkTheme` is already wired | `app_theme.dart` | WCAG AA audit before enabling |

---

*End of specification. Regenerate this document whenever scope, architecture, features, NFRs, roadmap, or deployment details change.*
