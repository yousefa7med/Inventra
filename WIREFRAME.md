# Inventra — UI Wireframes & Interaction Map

> **Scope**: Documentation of the *current* Flutter implementation only. Every screen, widget, string, state and route below was read from source on 2026-10-03 (post-`36ac143`, transactions feature merged into Safe). Nothing here is a redesign proposal — where the code is a placeholder, unreachable, or inconsistent, it is marked as such and collected in **§11 Implementation Discrepancies**.
>
> **Conventions used in this document**
> - Screens are listed with a stable ID (`S1`…`S18`), dialogs with `D1`…`D5` (+ D6 removed).
> - `Implemented` = reachable and functional · `Placeholder` = reachable but stub · `Unreachable` = implemented but never referenced · `Missing` = referenced but no implementation found.
> - ASCII wireframes are **low-fidelity**. The app is **Arabic-only, RTL**: the leading (right) edge is the "start" side; all titles in the diagrams are the exact Arabic strings from `lib/core/constants/app_strings.dart` and inline literals.
> - Colors/styles are referenced by name only (`AppColors.*`, `AppTextStyle.*`), never invented.

---

## 1. App Overview

| Property | Value (from code) |
|---|---|
| App name | Inventra — «نظام إدارة المخزون» (`app_drawer.dart`) |
| Type | Offline inventory management, **local ObjectBox DB, no backend/API** |
| Locale / direction | Arabic only: `const Locale('ar')`, RTL delegates (`main.dart`) |
| Design base | `flutter_screenutil`, design size `360 × 690` |
| Entry | `main.dart` → `AppRoutes.mainView` (`'/'`) → `MainView` |
| Splash / onboarding / auth | **None exist** |
| Shell | `MainView`: `PersistentTabView` (package `persistent_bottom_nav_bar_v2`), `Style8BottomNavBar`, **3 tabs** (Dashboard, Inventory, Safe), bar height `58`, white, `handleAndroidBackButtonPress: true`, plus a `Drawer` on `AppGlobalKeys.mainScaffold` |
| State | `flutter_bloc` Cubits, one per feature, injected via `GetIt` |
| Dialogs | `showDialog` only — **there is no `showModalBottomSheet` anywhere in `lib/`** |
| Feedback | `showSnackBar(context, message, {color})` — floating, 2 s, rounded, from `core/helper/functions.dart` |

**Primary business objects surfaced in the UI**: products, customers, suppliers, sell invoices, buy invoices, expenses, safe (cash) balance, manual balance adjustments, transaction log entries, (return receipts are *displayed* but have no creation UI — see §11-X16).

---

## 2. Screen Inventory

| ID | Screen | File | Reachable from | Status |
|----|--------|------|----------------|--------|
| S1 | Main shell (tabs + drawer) | `features/main/presentation/views/main_view.dart` | initial route `/` | Implemented |
| S2 | Drawer | `core/widgets/app_drawer.dart` | menu button on S3/S5/S6 | Implemented |
| S3 | Dashboard (tab 0) | `features/dashboard/.../dashboard_view.dart` | tab «لوحة التحكم» | Implemented |
| S4 | Operations / Transactions | — | **Removed** — merged into S6 (`SafeView`), feature folder deleted | — |
| S5 | Inventory (tab 1) | `features/inventory/.../inventory_view.dart` | tab «المخزن» | Implemented |
| S6 | Safe (tab 2) | `features/safe/.../safe_view.dart` | tab «الخزنة» | Implemented — now also hosts the old S4 transaction history/filter |
| S7 | Settings | `features/settings/.../settings_view.dart` | — | **Removed** (route, tab, drawer item and folder deleted) |
| S8 | All customers | `features/customers/.../all_customers_view.dart` | drawer «جميع العملاء» | Implemented (now with extended FAB «إضافة عميل») |
| S9 | All suppliers | `features/suppliers/.../all_suppliers_view.dart` | drawer «جميع الموردين» | Implemented (now with extended FAB «إضافة مورد») |
| S10 | Customer form (add/edit) | `core/widgets/customer_form_view.dart` | S8 empty-state button, `CustomerCard` edit | Implemented |
| S11 | Supplier form (add/edit) | `core/widgets/supplier_form_view.dart` | S9 empty-state button, `SupplierCard` edit | Implemented |
| S12 | Product form (add/edit) | `core/widgets/product_form_view.dart` | S5 FAB/empty state/`ProductCard` edit, S14 empty state, S16 FAB | Implemented |
| S13 | Sell invoice | `features/selling_invoice/.../selling_invoice_view.dart` | S3 quick action «فاتورة بيع» | Implemented |
| S14 | Sell invoice product picker | `features/selling_invoice/.../selling_product_selection_view.dart` | S13 FAB `+` | Implemented |
| S15 | Buy invoice | `features/buying_invoice/.../buying_invoice_view.dart` | drawer «فواتير المشتريات» | Implemented (title fixed to «فاتورة شراء») |
| S16 | Buy invoice product picker | `features/buying_invoice/.../buying_product_selection_view.dart` | S15 FAB `+` | Implemented |
| S17 | Add expense | `features/safe/.../add_expense_view.dart` | **S3 quick-action card «مصروف»** (S6 FAB removed) | Implemented (`_saveExpense()` gates the pop — §11-X6 fixed) |
| S18 | Invoice details | `features/safe/.../invoice_details_view.dart` (moved from deleted transactions feature) | tap sell/buy/return card on S6 | Implemented |
| — | `AppRoutes.addInvoiceView` (`'/addInvoiceView'`) | `core/config/configrations.dart:180` | **no switch case, no callers** | **Missing** → default route returns empty `Scaffold` (§11-X1) |

Unreachable widgets: `DashboardListCard` (`dashboard_list_card.dart`), `DashboardEmptyState` (`dashboard_empty_state.dart`) — defined, never referenced (§11-X2).

---

## 3. Navigation Map

### 3.1 Route table (`AppRoutes` → `AppRouter.generateRoute`)

| Route constant | Path | Builds | Arg | Wrap |
|---|---|---|---|---|
| `mainView` | `/` | `MainView` | — | — |
| `productFormView` | `/addProductView` | `ProductFormView` | `ProductDetailsArguments?` (`product`, `isQuantitiyEditable`) | `BlocProvider.value(ProductCubit)` |
| `customerFormView` | `/customerFormView` | `CustomerFormView` | `CustomerModel?` | `CustomerCubit` |
| `supplierFormView` | `/edit-supplier` | `SupplierFormView` | `SupplierModel?` | `SupplierCubit` |
| `addExpenseView` | `/addExpenseView` | `AddExpenseView` | — | `SafeCubit` |
| `sellingInvoiceView` | `/selling-invoice` | `SellingInvoiceView` | — | `SellInvoiceCubit..loadCustomers()` |
| `addProductToInvoice` | `/add-product-to-invoice` | `SellingProductSelectionView` | — | `SellInvoiceCubit..loadProducts('')` |
| `allCustomers` | `/all-customers` | `AllCustomersView` | — | `CustomerCubit..loadCustomers()` |
| `allSuppliers` | `/all-suppliers` | `AllSuppliersView` | — | `SupplierCubit..loadSuppliers()` |
| `buyingInvoiceView` | `/buying-invoice` | `BuyingInvoiceView` | — | `BuyInvoiceCubit..loadSuppliers()` |
| `productSelectionView` | `/product-selection` | `BuyingProductSelectionView` | — | `BuyInvoiceCubit..loadProducts('')` |
| `invoiceDetailsView` | `/invoice-details` | `InvoiceDetailsView` (`features/safe/...`) | `InvoiceDetailsModel` (required) | — |
| `addInvoiceView` | `/addInvoiceView` | **no case** → `default` → empty `Scaffold()` | — | — |

(The `settings` route constant and its `case` were removed along with S7.)

All routes use the custom `pageRouteBuilderMethod` transition (`core/transitions/`). Unknown route ⇒ blank `Scaffold`.

### 3.2 Navigation primitives (`AppNavigation`, `core/navigations/navigations.dart`)

| Method | Semantics |
|---|---|
| `pushName<T>(context, route, argument, rootNavigator:false)` | `pushNamed` (returns `Future<T?>`) |
| `pushWithReplacement(...)` | `pushReplacementNamed` (unused by current screens) |
| `pushAndRemoveUntil(...)` | `pushNamedAndRemoveUntil(clear all)` (unused by current screens) |
| `pop(context, [result])` | `Navigator.pop` |
| `navigationdelay(...)` | pushes after 4 s (unused) |

`rootNavigator: true` is used for: S3 quick actions, S5 FAB, S6 transaction-card → details, S12 push from S5 FAB.

### 3.3 Graph

```
                                      ┌────────────────────────── '/' ──────────────────────────┐
                                      │                        MainView (S1)                   │
                                      │  PersistentTabView (4 tabs) + Drawer (S2)               │
                                      └─────────────────────────────────────────────────────────┘
        ┌───────────────┬───────────────┬───────────────┐
   tab 0│          tab 1│          tab 2│  (drawer S2 is shared)
        ▼               ▼               ▼
   ┌──────────┐   ┌──────────┐   ┌──────────┐
   │ S3       │   │ S5       │   │ S6       │
   │ Dashboard│   │ Inventory│   │ Safe     │
   └────┬─────┘   └────┬─────┘   └──┬───┬───┘
        │ S3 quick card │ FAB «منتج» │   │ «تعديل» on BalanceCard
        │ 3 actions     ▼            │   │               ▼
        │              │ S12         │   │         ┌────────────────┐
        │              │ Product     │   │         │ D2 Adjust       │
        │              │ Form        │   │         │ Balance dialog  │
        │              └─────────────┘   │         └────────────────┘
        │  actions:                     │
        │   ├─ «فاتورة بيع»    → S13   │  S6 body: BalanceCard +
        │   ├─ «فاتورة شراء»   → S15   │  TransactionsFilter +
        │   └─ «مصروف»         → S17   │  date-grouped TransactionCards
        │                               │  card tap → S18 / D4 / D5
        ▼
   ┌──────────────┐  FAB '+'  ┌───────────────────┐
   │ S13          │ ────────▶ │ S14                │
   │ Sell Invoice │           │ Sell product picker│
   └──────┬───────┘           │  empty → S12       │
          │                   └───────────────────┘
          │ confirm (pop on success)
          ▼
   back to origin

   S6 TransactionCard tap:
     sell/buy/return → S18 · expense → D4 · manualAdjustment → D5

   S15 Buy Invoice ──FAB '+'──▶ S16 Buy product picker ── add ──▶ D3 Price dialog
         ▲                        empty-state FAB «إضافة منتج» ──▶ S12 (isQuantitiyEditable:false)
         │
         ├── drawer «فواتير المشتريات»
         └── S3 quick action «فاتورة شراء»

   S17 entry: S3 quick action «مصروف» (S6 FAB removed)

  S8 All Customers ── empty-state «إضافة عميل» ──▶ S10 ; CustomerCard ✎ ──▶ S10 (arg customer)
  S9 All Suppliers ── empty-state «إضافة مورد» ──▶ S11 ; SupplierCard ✎ ──▶ S11 (arg supplier)
  S5 Inventory     ── empty-state «إضافة منتج» ──▶ S12 ; ProductCard ✎ ──▶ S12 (arg product)
```

### 3.4 Back-button / leading-edge behaviour

| Screen | App bar | Back | Menu (drawer) |
|---|---|---|---|
| S3 Dashboard | `CustomAppBar(showDrawerButton:true)` | — | ✔ |
| S5 Inventory | `SliverAppBar(automaticallyImplyLeading:false, title: CustomAppBar(showDrawerButton:true))` | ✖ | ✔ |
| S6 Safe | `CustomAppBar(showDrawerButton:true)` | — | ✔ |
| S8 / S9 Customers/Suppliers | `SliverAppBar(automaticallyImplyLeading:false, title: CustomAppBar(...))` — **no** `showDrawerButton` | ✖ (system back only) | ✖ |
| S10–S18 (pushed) | `CustomAppBar(...)` used as `Scaffold.appBar` → default `automaticallyImplyLeading` ⇒ **automatic back arrow** | ✔ | ✖ |

Shell behaviour: `handleAndroidBackButtonPress: true` — Android back on tab 0 exits the app (no exit confirmation dialog exists).

Tab-change side effects (`MainView.onTabChanged`): index 1 → `ProductCubit.loadProducts()`; index 2 → `SafeCubit.init()`; index 0 → none (Dashboard re-inits via `..init()` in `_tabs`).

---

## 4. User Flow

### F1 — Sell an invoice (primary flow)
1. S3 Dashboard → tap «فاتورة بيع» → S13.
2. S13: pick customer from dropdown «اختر العميل» (search/filter enabled; typing an exact name on focus-loss auto-selects, otherwise clears selection).
3. Tap `+` FAB → S14 «إضافة منتج الى الفاتورة» → search → card → `QuantityCounter` → «إضافة للفاتورة» → pops back to S13 (item added).
4. S13 shows tile(s) with per-line `QuantityCounter`, delete, «الإجمالي: x ج.م»; totals card «المجموع» + «الخصم» input + «الإجمالي بعد الخصم».
5. «تأكيد الفاتورة» → `validateSellInvoice()`:
   - no customer → snackbar «يرجى اختيار عميل» (stays on S13)
   - no items → «يرجى إضافة منتج واحد على الأقل» (stays)
   - ok → `confirmInvoice()` (stock check may emit «الكمية غير متوفرة للمنتج: x») → **only on success** `pop` → back to origin; success snackbar «تم اضافة الفاتورة بنجاح» is emitted via `BlocListener` **before** the pop (§11-X9 resolved).
6. Effects: product quantities ↓, safe balance ↑, `SellInvoice` + `TransactionEntry` written.

### F2 — Buy an invoice
Drawer «فواتير المشتريات» → S15 → dropdown «اختر المورد» → `+` FAB → S16 → card «إضافة للفاتورة» → **price dialog D3** («هل تريد تعديل السعر») → returns edited product → added & view pops → «تأكيد الفاتورة» («يرجى اختيار مورد» / «يرجى إضافة منتج واحد على الأقل بكمية أكبر من صفر») → pop. Effects: quantities ↑, safe ↓.

### F3 — Add expense
S6 → FAB «مصروف» → S17 → «القيمة» (validator: required, positive, ≤ safe balance, ≤ 999 999 999.99) + «الملاحظة» (required) → «حفظ» → `_saveExpense()` returns `bool` → **`pop` only on success** (§11-X6 fixed) → back to S6 (list refreshes only on next tab switch / pull-to-refresh via `SafeCubit.init()`).

### F4 — Adjust safe balance
S6 → BalanceCard «تعديل» → **D2** «تعديل الرصيد» → «الرصيد الجديد» + «ملاحظة (اختياري)» → «تأكيد» (validates inline: «الرصيد مطلوب», «رقم غير صالح», «القيمة خارج النطاق المسموح») → pop dialog, balance replaced; creates `ManualAdjustment` transaction.

### F5 — Manage contacts
Drawer → S8/S9 → search «ابحث بالاسم...» (300 ms debounce) → card ✎ → S10/S11 (prefilled) → save → snackbar «تم تعديل … بنجاح» → pop. **New** contact from the empty state button («إضافة عميل» / «إضافة مورد») or the extended FAB on populated lists (§11-X4 fixed). Call icon → `PhoneUtils.launchDialer`.

### F6 — Product lifecycle
S5 → FAB «منتج» / empty-state «إضافة منتج» / card ✎ → S12 (image via **camera only**, 500×500) → validate → `updateProduct` → `pop(result)`; delete card icon → **D1** confirm «تأكيد الحذف» → «حذف».

### F7 — Review history
Tab «الخزنة» → S6 → type filter chips («الكل» … «تعديل يدوي») → grouped list by «اليوم»/«أمس»/Arabic date with «n عملية»-style day headers → tap:
- sell/buy/return → **S18** invoice details (with «اتصال»),
- expense → **D4** «تفاصيل المصروف»,
- manual adjustment → **D5** «تعديل يدوي» (prev → arrow → new balance, delta, note).

(Historical note: this flow used to live in the separate «عمليات» tab with a date-range picker D6; D6 was removed along with the standalone transactions screen.)

### F8 — Dashboard analysis
S3 → pull-to-refresh (`DashboardCubit.refresh()`) → tap KPI card («الارباح»/«المبيعات»/«المشتريات»/«المصاريف») to switch chart metric → tap period («اليوم»/«الأسبوع»/«الشهر»/«السنة») → chart re-renders or shows no-data state.

---

## 5. Per-Screen Wireframes

> Legend: `[brackets]` = interactive control · `«»` = exact Arabic string · ⤶ = pull-to-refresh · ASCII shows logical stacking; in the real UI the leading edge is the **right**.

### S1 — Main shell (`MainView`)
- **Purpose**: app container: 5-tab bottom navigation + side drawer.
- **Entry**: initial route `'/'`.
- **Layout**: `Scaffold(key: mainScaffold, drawer: AppDrawer, resizeToAvoidBottomInset:false)` → `PersistentTabView` with `Style8BottomNavBar(height: 58, color: white)` — **4 tabs**.

```
┌──────────────────────────────────────────────┐
│  (current tab screen renders full-bleed)     │
│                                              │
│                                              │
├──────────────────────────────────────────────┤
 │ [◫ لوحة التحكم] [▤ المخزن] [▢ الخزنة]         │  ← bar h=58, active = AppColors.primary
└──────────────────────────────────────────────┘
        ▲ swipe/right-edge or menu button opens drawer (S2)
```
- **Components**: `ItemConfig` per tab (icon + title + `AppTextStyle.navBar`), inactive color `white70`/`grey` depending on theme.
- **Interactions**: tap tab switches screen; `onTabChanged` reloads data for indices 1–3; Android back handled by `PersistentTabView`.
- **States**: none of its own (each tab owns its states).

### S2 — Drawer (`AppDrawer`)
- **Purpose**: secondary navigation + branding/footer.
- **Entry**: menu button (S3/S5/S6) → `AppGlobalKeys.mainScaffold.currentState?.openDrawer()`.
- **Layout**: width `75%` of screen.

```
┌───────────────────────────┐
│ ▓▓▓ primary header ▓▓▓▓▓▓ │  (rounded bottom 24)
│  (◯ logo)  Inventra       │
│           نظام إدارة المخزون│
├───────────────────────────┤
│ 👤 جميع العملاء        ‹  │  → S8
│ 🚚 جميع الموردين       ‹  │  → S9
 │ ⎘ فواتير المشتريات      ‹  │  → S15
 ├───────────────────────────┤
 │ قريباً                    │
│ 🚚 فواتير المرتجعات  [جديد]│  (disabled placeholder row)
│ 📈 التقارير المتقدمة  [جديد]│
│ 👥 إدارة المستخدمين    [جديد]│
├───────────────────────────┤
│ ℹ إصدارات التطبيق 1.0.0   │  (grey footer, rounded top)
│ © جميع الحقوق محفوظة © 2024│
└───────────────────────────┘
```
- **Interactions**: `ListTile` tap → `pushName` (drawer stays in stack underneath); «قريباً» rows are non-interactive decorations.
- **States**: static.

### S3 — Dashboard (`DashboardView`)
- **Purpose**: at-a-glance KPIs, trend chart, single primary CTA.
- **Entry**: tab «لوحة التحكم» (cubit `init()` on tab build).
- **Layout**: `CustomAppBar('لوحة التحكم', showDrawerButton:true)` + scrolling body.

```
┌──────────────────────────────────────────────┐
│ [☰] ◯ لوحة التحكم                            │
├──────────────────────────────────────────────┤
│ ┌──────────────────────────────────────────┐ │
│ │            الرصيد الحالي                 │ │   hero card
│ │        12,500 ج.م  (AppColors.primary)   │ │
│ └──────────────────────────────────────────┘ │
│ ┌──────────────────┐ ┌────────────────────┐  │
│ │ ● الارباح         │ │ ● المبيعات         │  │  KPI grid 2×2 (3:2)
│ │ 4,200 ج.م        │ │ 25,000 ج.م        │  │  tap ⇄ selects metric
│ └──────────────────┘ └────────────────────┘  │  (selected = metric color border+glow)
│ ┌──────────────────┐ ┌────────────────────┐  │
│ │ ● المشتريات       │ │ ● المصاريف         │  │
│ │ 18,000 ج.م       │ │ 2,800 ج.م         │  │
│ └──────────────────┘ └────────────────────┘  │
│ [اليوم][الأسبوع][الشهر][السنة]                │  segmented outlined buttons
│ ┌──────────────────────────────────────────┐ │
│ │            ( line/area chart )           │ │  DashboardChart, colored by metric
│ └──────────────────────────────────────────┘ │
 │ [ ▣ فاتورة بيع ] [ ▣ فاتورة شراء ] [ ▣ مصروف ]   │  DashboardQuickActions → S13/S15/S17
└──────────────────────────────────────────────┘
   ⤶ pull-to-refresh → DashboardCubit.refresh()
```
- **Components**: `SafeBalanceSection`, `KpisSection` (`_DashboardMetricKpi`), `DashboardPeriodSelector`, `ChartSection`/`DashboardChart`, `DashboardQuickActions` (replaces deleted `DashboardPrimaryAction`).
- **Interactions**: KPI tap → `changeChartMetric`; period tap → `changePeriod`; quick actions → S13/S15/S17; refresh → `refresh()`.
- **States**:
  - `DashboardLoading` → `DashboardLoadingSkeleton` (shimmer: 100 h card, 4×100 h KPI blocks, 44 h bar, 280 h chart block).
  - `DashboardError` → `ErrorStateWidget` («حدث خطأ» + message + «إعادة المحاولة» → `refresh()`).
  - `DashboardLoaded` with empty series → inline no-data block: circle icon `event_busy_outlined`, «لا توجد {المؤشر}» (e.g. «لا توجد المبيعات»), «خلال {الفترة}».
  - `DashboardListCard`, `DashboardEmptyState` → **unreachable** (§11-X2).

### S4 — Operations / Transactions — **Removed (merged into S6)**
The standalone tab («عمليات») and its `TransactionsView` were deleted. Its UI — filter chips, date-grouped list, `TransactionCard`, `DateHeader`, `InvoiceDetailsView` — moved into `features/safe/` and now renders inside S6. `TransactionType`/`TransactionsEntry` models and the audit writes in buy/sell/safe repositories remain.

### S5 — Inventory (`InventoryView`)
- **Purpose**: browse/search/edit/delete products; entry point for creating products.
- **Entry**: tab «المخزن» (auto `loadProducts()` on tab entry).
- **Layout**: pinned `SliverAppBar` (floating+snap, **no system back**) with `CustomAppBar('قائمة المنتجات', showDrawerButton:true)`, search, list, extended FAB.

```
┌──────────────────────────────────────────────┐
│ [☰] ◯ قائمة المنتجات                         │
├──────────────────────────────────────────────┤
│ [🔍 ابحث باسم المنتج أو الباركود...      ✕]  │  SearchField, 300ms debounce
│ ┌──────────────────────────────────────────┐ │
│ │ ┌────┐  قهوة مختصة                    [✎]│ │  image 70×70 / 🚫 placeholder
│ │ │img │  🔲 6901234567890                 │ │  or «لا يوجد باركود»
│ │ └────┘  المتاح: 12              [🗑]     │ │  >5 primary · ≤5 warning · ≤0 «نفذت الكمية» red
│ │  شراء 80.00  جملة 90.00  بيع 120.00 ج.م  │ │  price row
│ └──────────────────────────────────────────┘ │
│ ...                                          │
└───────────────────────────[＋ منتج]──────────┘  ← FloatingActionButton.extended (root nav → S12)
```
- **Interactions**: search (debounced, clear button resets); ✎ → S12 with `ProductDetailsArguments(product)`; 🗑 → **D1** «تأكيد الحذف» / «هل أنت متأكد من حذف "اسم المنتج"؟» / «حذف» / «إلغاء» → `deleteProduct`; FAB → S12 (add).
- **States**: `ProductLoading` → full-screen spinner; `ProductErrorState` → `ErrorStateWidget` + retry; success-but-empty → `EmptyStateWidget` with icon `inventory_2_outlined`, message «لا يوجد منتجات» or «لا توجد نتائج للبحث», action «إضافة منتج» → S12.

### S6 — Safe (`SafeView`)
- **Purpose**: cash balance, unified transaction history (sell/buy/return/expense/manual adjustment), filter by type, adjust balance. Add-expense is entered from S3's quick actions.
- **Entry**: tab «الخزنة» (auto `SafeCubit.init()` on tab entry).
- **Layout**: `CustomAppBar('الخزنة', showDrawerButton:true)` + `RefreshIndicator` + `CustomScrollView` (no FAB — S6's «مصروف» FAB was removed).

```
┌──────────────────────────────────────────────┐
│ [☰] ◯ الخزنة                                 │
├──────────────────────────────────────────────┤
│ ┌──────────────────────────────────────────┐ │
│ │ الرصيد الحالي            [✎ تعديل]       │ │  BalanceCard (isNegative always false)
│ │            12,500 ج.م                     │ │
│ └──────────────────────────────────────────┘ │
│ (الكل)(المبيعات)(المشتريات)(مصروفات)          │  TransactionsFilter chips (no date picker)
│ (مرتجعات)(تعديل يدوي)                         │
│ │ اليوم                                     │ │  DateHeader
│ │ ┌──────────────────────────────────────┐   │ │
│ │ │ [🧾] مصروفات #2  OK?note: مصاريف نقل  │   │ │  TransactionCard (type-colored)
│ │ │                        -150 ج.م       │   │ │  signedValue (green >0 / red ≤0)
│ │ └──────────────────────────────────────┘   │ │
│ ...                                          │
└──────────────────────────────────────────────┘
```
- **Interactions**: «تعديل» → **D2**; chip tap → `SafeCubit.loadTransactions(type:)` («الكل» clears); card tap → S18 / D4 / D5; ⤶ → `init()`.
- **States**: `SafeInitial` → empty `SizedBox`; `SafeLoading` → centered spinner; `SafeError` → `ErrorStateWidget` + retry `init()`; `SafeLoaded` with no items → `EmptyStateWidget(«لا توجد عمليات», icon receipt_long_outlined)`.

### S7 — Settings — **Removed**
- `SettingsView`, its tab (tab 4), its drawer row «الاعدادات», and the `/settings` route case/constant were deleted. Drawer «قريباً» placeholders remain.

### S8 — All Customers (`AllCustomersView`)
- **Purpose**: list/search customers, launch edit or call.
- **Entry**: drawer «جميع العملاء» (route pushes `CustomerCubit.loadCustomers()`).
- **Layout**: pinned `SliverAppBar(automaticallyImplyLeading:false, title: CustomAppBar('جميع العملاء'))` → **no back arrow, no menu button** (§11-X5).

```
┌──────────────────────────────────────────────┐
│            ◯ جميع العملاء                    │  ← no ☰, no ‹ (system back only)
├──────────────────────────────────────────────┤
│ [🔍 ابحث بالاسم...                        ✕]  │
│ ┌──────────────────────────────────────────┐ │
│ │ (◯)  أحمد محمد                   [✎]     │ │  CustomerCard: CircleAvatar person
│ │      📍 العنوان (أو «لا يوجد عنوان»)      │ │
│ │      📞 01000000000              [📞]     │ │  call → dialer (tooltip «اتصال»)
│ └──────────────────────────────────────────┘ │
│ ...                                          │
└──────────────────────────────────────────────┘
    empty state: EmptyStateWidget(icon person_off_outlined,
        message «لا يوجد عملاء» | «لا توجد نتائج للبحث»,
        action «إضافة عميل» → S10)
    ✎ (tooltip «تعديل») → S10 with CustomerModel argument
    FAB «إضافة عميل» (extended, bottom corner) → S10
```
- **States**: `CustomerLoading` → full-screen spinner; `CustomerLoadingError` → `ErrorStateWidget` + retry; loaded/updated → list or empty state above.

### S9 — All Suppliers (`AllSuppliersView`)
- **Purpose**: identical pattern to S8 for suppliers.
- **Entry**: drawer «جميع الموردين».
- **Layout/behaviour**: same SliverAppBar restriction as S8; title «جميع الموردين»; hint «ابحث بالاسم...».
- **Card**: avatar · name · 🏪 store name · 📍 address or «لا يوجد عنوان» · ✎ (tooltip «تعديل» → S11 with `SupplierModel`) · phone row + 📞 (tooltip «اتصال»).
- **States**: loading spinner; error state — now the standard `ErrorStateWidget` message + retry (was an inline custom column); empty → «لا يوجد موردين» / «لا توجد نتائج للبحث» + action «إضافة مورد» → S11. FAB «إضافة مورد» (extended) → S11.

### S10 — Customer Form (`CustomerFormView`)
- **Purpose**: create or edit a customer.
- **Entry**: S8 empty-state button (create) · `CustomerCard` ✎ (edit, `customer` arg).
- **Layout**: `CustomAppBar(isEditing ? 'تعديل العميل' : 'اضافة عميل')` + single scrollable `Form` (`autovalidateMode: onUserInteraction`).

```
┌──────────────────────────────────────────────┐
│ [‹] ◯ اضافة عميل / تعديل العميل               │
├──────────────────────────────────────────────┤
│ [👤 اسم العميل                            ]  │  label, prefix person
│ [📞 رقم الهاتف                            ]  │  prefix phone
│ [📍 العنوان (اختياري)                     ]  │  prefix location, optional
│                                              │
│ [            اضافة عميل / تعديل العميل       ]  │  AppButton (full width)
└──────────────────────────────────────────────┘
```
- **Interactions**: validate → `CustomerCubit.insertCustomer` → snackbar «تم اضافة العميل بنجاح» / «تم تعديل العميل بنجاح» → `pop` (§11-X9 about snackbar visibility).
- **Validation messages** (§7): «برجاء إدخال الاسم», «الاسم يجب أن يكون 3 أحرف على الأقل», «برجاء إدخال رقم الهاتف», «برجاء إدخال رقم هاتف صحيح».

### S11 — Supplier Form (`SupplierFormView`)
- **Purpose**: create or edit a supplier.
- **Entry**: S9 empty state (create) · `SupplierCard` ✎ (edit, `supplier` arg).
- **Layout**: app bar «اضافة مورد» / «تعديل المورد» + 4 fields + full-width AppButton (same labels as §7): `اسم المورد` · `اسم المتجر / الشركة` · `عنوان المتجر` · `رقم الهاتف`.
- **Interactions**: validate → `insertSupplier` → snackbar «تم اضافة المورد بنجاح» / «تم تعديل المورد بنجاح» → `pop`.

### S12 — Product Form (`ProductFormView`)
- **Purpose**: create or edit a product (also used with `isQuantitiyEditable:false` inside the buy flow).
- **Entry**: S5 FAB / empty state / card ✎ · S14 empty state · S16 FAB (quantity locked).
- **Layout**: `CustomAppBar('إضافة منتج' | 'تعديل المنتج')` + scroll `Form`.

```
┌──────────────────────────────────────────────┐
│ [‹] ◯ إضافة منتج                             │
├──────────────────────────────────────────────┤
│            ( ◯ add_a_photo  [+])              │  AddProductImageWidget (camera only, 500×500)
│         or  ( ◯ 150×150 image  [✎])           │  ProductImage
│                                              │
│ [ اسم المنتج                               ] │
│ [ الباركود                            🔲 ]  │  suffix qr_code_scanner (decorative)
│ [ الكمية المتاحة                         ]  │  only when isQuantitiyEditable ?? true
│ [ سعر الشراء    ]   [ سعر الجملة     ]      │  suffix «ج.م», side by side
│ [ سعر البيع                          ]      │  full width
│ [              إضافة المنتج / تعديل المنتج    ] │  AppButton
└──────────────────────────────────────────────┘
```
- **Interactions**: pick photo (camera) → saved into app documents as `prod_<ts>.<ext>` on submit; validate → `updateProduct` → `pop<ProductModel>(product)`; failure → snackbar «فشل تعديل المنتج: e» / «فشل إضافة المنتج: e» (old image restored/deleted appropriately); `BlocListener` also emits «تم تعديل المنتج بنجاح» / «تم إضافة المنتج بنجاح» / `ProductInsertError` message (§11-X10).
- **States**: no dedicated loading state (button press is synchronous against ObjectBox).

### S13 — Sell Invoice (`SellingInvoiceView`)
- **Purpose**: compose and confirm a sales invoice.
- **Entry**: S3 CTA (`rootNavigator:true`); route wraps `SellInvoiceCubit..loadCustomers()`.
- **Layout**: `CustomAppBar(AppStrings.invoiceFormTitle = «فاتورة بيع»)` + `CustomScrollView` + FAB.

```
┌──────────────────────────────────────────────┐
│ [‹] ◯ فاتورة بيع                             │
├──────────────────────────────────────────────┤
│ [ ▾ اختر العميل                          ]   │  DropdownMenu (search+filter, person/phone icons)
│ ┌──────────────────────────────────────────┐ │
│ │  أو: «لا توجد منتجات مضافة»  (grey, tiny)│ │  when items empty
│ │ ┌──────────────────────────────────────┐ │ │
│ │ │ قهوة مختصة                          │ │ │  SellingInvoiceItemTile
│ │ │ 120.00 ج.م          [−][ 2 ][+]  [🗑]│ │ │  QuantityCounter (max = stock)
│ │ │                    الإجمالي: 240.00 ج.م│ │ │
│ │ └──────────────────────────────────────┘ │ │
│ ┌──────────────────────────────────────────┐ │
│ │ المجموع                        240.00   │ │  SellingInvoiceTotalsCard
│ │ الخصم [ 0.00                     ج.م]  │ │  «الخصم» input
│ │ الإجمالي بعد الخصم             240.00    │ │  green highlighted row
│ └──────────────────────────────────────────┘ │
│ [              تأكيد الفاتورة                 ] │  AppButton
│                                              │
└───────────────────────────[＋]───────────────┘  ← FAB → S14
```
- **Interactions**: dropdown select/clear (focus-loss exact-match logic in `CustomerDropdownMenu`); FAB → S14; tile −/+/type quantity → `updateItemQuantity` (clamped by stock input formatter), 🗑 → `removeItem`; discount `onChanged` → `setDiscount`; confirm → validate → confirm → `pop`.
- **Snackbar contract** (`BlocListener`): `SellInvoiceError` → red snackbar (message); `SellInvoiceConfirmed` → «تم اضافة الفاتورة بنجاح» green. Messages emitted by cubit: «يرجى اختيار عميل», «يرجى إضافة منتج واحد على الأقل», «الكمية غير متوفرة للمنتج: {name}», «Failed to save invoice: e» (English, §11-X14). Confirm now returns a `bool` (`confirmInvoice()`); the view pops **only on success**, so a stock shortage now leaves S13 on screen with its error snackbar (§11-X9 partially fixed — success snackbar still fires immediately before the pop and may not be seen).
- **States**: no spinner state is rendered for confirm (`SellInvoiceLoading` exists but no UI binds to it).

### S14 — Sell product picker (`SellingProductSelectionView`)
- **Purpose**: search inventory and add lines to the sell invoice.
- **Entry**: S13 FAB.
- **Layout**: `CustomAppBar('إضافة منتج الى الفاتورة')` + search «ابحث باسم المنتج أو الباركود...» + list.

```
┌──────────────────────────────────────────────┐
│ [‹] ◯ إضافة منتج الى الفاتورة                 │
├──────────────────────────────────────────────┤
│ [🔍 ابحث باسم المنتج أو الباركود...       ]  │
│ ┌──────────────────────────────────────────┐ │
│ │ قهوة مختصة                     12        │ │  SellingProductCardWithCounter
│ │ شراء: 80.00 ج.م   بيع: 120.00 ج.م        │ │
│ │ جملة: 90.00 ج.م                          │ │
│ │ [ − ][ 1 ][ + ]   [   إضافة للفاتورة   ]  │ │  + pops back to S13
│ └──────────────────────────────────────────┘ │
└──────────────────────────────────────────────┘
   out of stock: button disabled + red «نفذ من المخزن»
   loading → full-screen spinner · error → message + [إعادة المحاولة]
   empty → «لا يوجد منتجات» / «لا توجد نتائج للبحث» + action «إضافة منتج» → S12
```
- **Interactions**: debounced search → `SellInvoiceCubit.loadProducts(q)`; counter clamped `1..product.quantity`; «إضافة للفاتورة» → `addProductItemLine(product, qty)` → `pop`.

### S15 — Buy Invoice (`BuyingInvoiceView`)
- **Purpose**: compose and confirm a purchase invoice.
- **Entry**: drawer «فواتير المشتريات»; route wraps `BuyInvoiceCubit..loadSuppliers()`.
- **Layout**: mirrors S13 with these differences:
  - app bar title = `AppStrings.buyInvoice` → **«فاتورة شراء»** (§11-X8 fixed).
  - supplier dropdown hint **«اختر المورد»** (`supplier_dropdown_menu.dart`).
  - totals card = single row **«الإجمالي» + value** (no discount field).
  - FAB → `AppRoutes.productSelectionView` (S16).
- **Validation messages**: «يرجى اختيار مورد» · «يرجى إضافة منتج واحد على الأقل بكمية أكبر من صفر» · errors via `BuyInvoiceError`; success snackbar «تم اضافة الفاتورة بنجاح». Confirm also returns a success `bool`; pop is gated on success.

### S16 — Buy product picker (`BuyingProductSelectionView`)
- **Purpose**: pick existing products (with optional price edit) or create a new product.
- **Entry**: S15 FAB.
- **Layout**: same shell as S14 (title «إضافة منتج الى الفاتورة», same search hint) **plus** extended FAB «إضافة منتج» → S12 with `ProductDetailsArguments(isQuantitiyEditable:false)`; returned product is `insertProduct`-ed into the buy session.
- **Card behaviour**: «إضافة للفاتورة» first opens **D3** price dialog; if the user returns an edited product it is persisted (`insertProduct`) then `addProductItem(product ?? original, qty)` → `pop`.
- **States**: same loading/error/empty contract as S14 (buy cubit emits «الباركود مستخدم بالفعل» on duplicate-barcode insert, «Failed to load products: e»).

### S17 — Add Expense (`AddExpenseView`)
- **Purpose**: record a cash expense against the safe balance.
- **Entry**: S3 quick-action card «مصروف» (`rootNavigator:true`); route wraps `SafeCubit`. (S6's «مصروف» FAB was removed.)
- **Layout**: `CustomAppBar('إضافة مصروف')` + padded `Form`.

```
┌──────────────────────────────────────────────┐
│ [‹] ◯ إضافة مصروف                            │
├──────────────────────────────────────────────┤
│ القيمة                                        │  Text(regular18)
│ [ مثال: 150.50                             ] │  numeric keyboard
│ الملاحظة                                      │
│ [ مثال: مصاريف نقل                          ] │
│ [                     حفظ                    ] │  AppButton (primary)
└──────────────────────────────────────────────┘
```
- **Validation** (`Validator.validateExpense(currentBalance)`): «القيمة مطلوبة» · «قيمة المصروف يجب أن تكون موجبة» · «القيمة كبيرة جداً» · «القيمة اكبر من المبلغ في الخزنة»; note: «برجاء إدخال الملاحظة».
- **Interactions**: «حفظ» → `_saveExpense()` returns `bool` → **`pop` only when it succeeds** (§11-X6 fixed). Effects on success: `ExpenseModel.value` stored **negative**, balance ↓, `TransactionEntry(expense)` written.
- **States**: no explicit loading/error UI on this screen (cubit errors surface elsewhere).

### S18 — Invoice Details (`InvoiceDetailsView`)
- **Purpose**: read-only receipt view for a sell/buy (and return) invoice.
- **Entry**: tap an invoice/return card on S6 (`rootNavigator:true`, argument `InvoiceDetailsModel`).
- **Layout**: `CustomAppBar('فاتورة بيع' | 'فاتورة شراء')`, scroll content, sticky bottom bar.

```
┌──────────────────────────────────────────────┐
│ [‹] ◯ فاتورة بيع                             │  ← title by type
├──────────────────────────────────────────────┤
│ ┌─ tinted header card (success for sell,      │
│ │  primary for buy) ───────────────────────┐ │
│ │ [▣ icon] فاتورة بيع              #3      │ │  id = invoice.id
│ │          2026/09/27 02:14 م               │ │
│ │  ──────────────── divider ──────────────  │ │
│ │  👤 العميل / 🚚 المورد                    │ │
│ │  أحمد محمد                      [📞 اتصال]│ │  → dialer
│ └───────────────────────────────────────────┘ │
│ ┌──────────────────────────────────────────┐ │
│ │ قهوة مختصة                2 × 120 ج.م    │ │  item rows, dividers between
│ │ شاي أخضر                  1 × 40 ج.م     │ │
│ └──────────────────────────────────────────┘ │
│ ┌──────────────────────────────────────────┐ │
│ │ المجموع                       280 ج.م    │ │
│ │ الخصم                       -30 ج.م      │ │  only when discount > 0 (red)
│ │ ────────                              │ │
│ │ الإجمالي                      250 ج.م     │ │  big, type-colored
│ └──────────────────────────────────────────┘ │
├──────────────────────────────────────────────┤
│ الإجمالي  250 ج.م                 [2 أصناف]  │  bottomNavigationBar (sticky)
└──────────────────────────────────────────────┘
```
- **Interactions**: «اتصال» → `PhoneUtils.launchDialer(personPhoneNum)`; back arrow only (no drawer).
- **States**: no empty/loading handling — an invoice with zero items would render an empty items card (strings `noProductsInSellInvoice`/`noProductsInBuyInvoice` exist but are unused, §11-X15).

---

## 6. Dialogs, Sheets & Overlays

**There are no bottom sheets in the app** (`showModalBottomSheet` appears nowhere). All modals are `showDialog` dialogs plus one Material picker.

| ID | Dialog | File | Trigger | Content | Actions |
|----|--------|------|---------|---------|---------|
| **D1** | `appDialog` (generic confirm) | `core/helper/app_dialog.dart` | product delete on S5 | `title`, `content` (max 2 lines), radius 16 | «إلغاء» (primary text) · `msg` destructive (error text) — destructive runs *after* dialog pop |
| **D2** | `AdjustBalanceDialog` | `features/safe/.../adjust_balance_dialog.dart` | «تعديل» on S6 BalanceCard (provided `SafeCubit` via `BlocProvider.value`) | title «تعديل الرصيد»; «الرصيد الجديد» field (hint «مثال: 5000.00»); «ملاحظة (اختياري)» (hint «مثال: رصيد افتتاحي») | «إلغاء» · «تأكيد» (validates; pops only on success) |
| **D3** | `ChangeProductPriceDialog` | `features/buying_invoice/.../change_product_price_dialog.dart` | «إضافة للفاتورة» on S16 card | title «هل تريد تعديل السعر»; product name; 3 fields «سعر الشراء» / «سعر الجملة» / «سعر البيع» (suffix «ج.م»); `barrierDismissible:false` | «إلغاء» (error) · **«تغيير السعر»** (primary) — returns `ProductModel` only if a price actually changed, else returns `null` |
| **D4** | Expense detail | `features/safe/.../transaction_card.dart` | tap «مصروفات» card on S6 | title «تفاصيل المصروف»; red tinted «المبلغ» block (signed value); optional «ملاحظة» block | «إغلاق» (AppButton) |
| **D5** | Manual adjustment detail | `features/safe/.../transaction_card.dart` | tap «تعديل يدوي» card on S6 | title «تعديل يدوي»; «الرصيد السابق» → circle arrow (↑ green / ↓ red) → «الرصيد الجديد»; delta chip «+$x»/«- $x»; optional «ملاحظة» | «إغلاق» (AppButton) |
| D6 | — | — | **Removed** with the standalone transactions screen (no `showDateRangePicker` in `lib/`) | — | — |

**Snackbar overlay** (`showSnackBar`): floating, radius 12, 2 s, margin 30, centered `AppTextStyle.medium14` white text, background `color ?? AppColors.snackBarDefault`. Only helper is used — no raw `ScaffoldMessenger` in views.

---

## 7. Form Structures

### 7.1 Common field/button infrastructure
- **`AppTextField`** (`core/widgets/app_text_field.dart`): `TextFormField` with outlined borders (radius 10; focused = primary 2 px; error = error 2 px), `labelText` + `labelStyle regular14`, optional `hintText`, `prefixIcon`, `suffixIcon`/`suffixText`, focus listener selects-to-end. **All forms/search use this widget; no raw `TextField`/`TextFormField` except inside `QuantityCounter`.**
- **`SearchField`**: wraps `AppTextField` with `prefixIcon 🔍`, clear-suffix, 300 ms debounce → `searchFunction(q)`; clear button → `clearFunction()`.
- **`AppButton`**: full-width action button (used for all primary submits).
- **`QuantityCounter`**: `−` (red) · `TextFormField` width 50, centered, numeric, input formatter blocks values > `maxQuantity` · `+` (green); internal `uiQuantity` clamps `1..maxQuantity`. *(Contains a stray `print` and a raw `InputDecoration` — §11-X12.)*
- **Validation timing**: all forms `AutovalidateMode.onUserInteraction`.

### 7.2 Field matrix

| Screen | Field label | Keyboard | Validator → message |
|---|---|---|---|
| S10 Customer | `اسم العميل` | text | `validateName` → «برجاء إدخال الاسم» / «الاسم يجب أن يكون 3 أحرف على الأقل» |
| S10 | `رقم الهاتف` | phone | `validatePhone` → «برجاء إدخال رقم الهاتف» / «برجاء إدخال رقم هاتف صحيح» (`^[0-9+]{7,15}$`) |
| S10 | `العنوان (اختياري)` | streetAddress | — (optional) |
| S11 Supplier | `اسم المورد` | text | `validateName` |
| S11 | `اسم المتجر / الشركة` | text | `validateStoreName` → «برجاء إدخال اسم المتجر» |
| S11 | `عنوان المتجر` | streetAddress | — (optional) |
| S11 | `رقم الهاتف` | phone | `validatePhone` |
| S12 Product | `اسم المنتج` | text | `validateName` |
| S12 | `الباركود` | text | `validateBarcode` → «برجاء إدخال الباركود» |
| S12 | `الكمية المتاحة` | number | `validateQuantaty` → «ادخل الكمية المتاحة» / «رقم غير صحيح» (must be > 0) — *hidden when `isQuantitiyEditable == false`* |
| S12 | `سعر الشراء` (suffix «ج.م») | number | `validateBuyingPrice` → «ادخل سعر الشراء» / «رقم غير صحيح» |
| S12 | `سعر الجملة` (suffix «ج.م») | number | `validateWholeSalePrice` → «ادخل سعر الجملة» / «يجب أن يزيد عن سعر الشراء» |
| S12 | `سعر البيع` (suffix «ج.م») | number | `validateSellingPrice` → «ادخل سعر البيع» / «يجب أن يزيد عن سعر الشراء» / «يجب أن يزيد عن سعر الجملة» |
| S13 | discount input (hint `0.00`, suffix «ج.م») | number (decimal) | none (cubit-side) |
| S17 | «القيمة» field (label «مثال: 150.50») | number (decimal) | `validateExpense(balance)` → «القيمة مطلوبة» / «قيمة المصروف يجب أن تكون موجبة» / «القيمة كبيرة جداً» / «القيمة اكبر من المبلغ في الخزنة» |
| S17 | «الملاحظة» field (label «مثال: مصاريف نقل») | done | `requiredField(…, "الملاحظة")` → «برجاء إدخال الملاحظة» |
| D2 | «الرصيد الجديد» (hint «مثال: 5000.00») | number (decimal) | inline → «الرصيد مطلوب» / «رقم غير صالح» / «القيمة خارج النطاق المسموح» (0 … 999 999 999.99) |
| D2 | «ملاحظة (اختياري)» (hint «مثال: رصيد افتتاحي») | — | — |
| D3 | «سعر الشراء» / «سعر الجملة» / «سعر البيع» | number (decimal) | same price validators as S12 |

### 7.3 Submit actions

| Screen | Button label | On success |
|---|---|---|
| S10 | «اضافة عميل» / «تعديل العميل» | `insertCustomer` → snackbar → `pop` |
| S11 | «اضافة مورد» / «تعديل المورد» | `insertSupplier` → snackbar → `pop` |
| S12 | «إضافة المنتج» / «تعديل المنتج» | image save → `updateProduct` → `pop(result)` (error → snackbar) |
| S13/S15 | «تأكيد الفاتورة» | validate → `confirmInvoice()` → `pop` |
| S17 | «حفظ» | `_saveExpense()` → **pop only on success** |
| D2 | «تأكيد» | validate → `adjustBalance` → pop dialog |
| D3 | «تغيير السعر» | validate → return product (or null if unchanged) |

---

## 8. Empty / Loading / Error States

### 8.1 Shared state widgets
| Widget | Renders |
|---|---|
| `EmptyStateWidget(message, icon, actionText?, onAction?)` | centered icon (60 r, `greyMedium400`) + message (`medium16`, grey) + optional **raw `ElevatedButton`** action |
| `ErrorStateWidget(message, onPressed)` | `error_outline` 64 w + «حدث خطأ» (`bold20`, error) + message (grey) + `AppButton` **«إعادة المحاولة»** (width 200) |
| Spinner | `CircularProgressIndicator` centered (or `SliverFillRemaining`) |
| Shimmer | only `DashboardLoadingSkeleton` (package `shimmer`) |

### 8.2 Per-screen matrix

| Screen | Loading | Empty | Error |
|---|---|---|---|
| S3 Dashboard | shimmer skeleton (card/4 KPIs/bar/chart) | chart-area «لا توجد {metric}» + «خلال {period}» | `ErrorStateWidget` → `refresh()` |
| — | S4 Transactions (removed) | — | — | — |
| S5 Inventory | centered spinner | «لا يوجد منتجات» or «لا توجد نتائج للبحث» + «إضافة منتج» | `ErrorStateWidget` → `loadProducts()` |
| S6 Safe | centered spinner (initial = empty box) | «لا توجد عمليات» (`receipt_long_outlined`) | `ErrorStateWidget` → `init()` |
| S8 Customers | full-screen spinner | «لا يوجد عملاء» / «لا توجد نتائج للبحث» + «إضافة عميل» | `ErrorStateWidget` → `loadCustomers()` |
| S9 Suppliers | full-screen spinner | «لا يوجد موردين» / «لا توجد نتائج للبحث» + «إضافة مورد» | *inline custom* message + retry (not `ErrorStateWidget`) |
| S13 Sell invoice | none rendered | «لا توجد منتجات مضافة» (inline text) | snackbar via `BlocListener` |
| S14/S16 pickers | full-screen spinner | «لا يوجد منتجات» / «لا توجد نتائج للبحث» + «إضافة منتج» | inline message + «إعادة المحاولة» (raw `ElevatedButton`) |
| S15 Buy invoice | none rendered | «لا توجد منتجات مضافة» | snackbar via `BlocListener` |
| S17 Add expense | none | — | field-level validation only |
| S18 Details | none (always has data) | none — empty items render an empty card | none |
| — | S7 Settings | — (removed) | — | — |

---

## 9. Screen-to-Screen Relationships

### 9.1 Reachability matrix (target ← sources)

| Target | From |
|---|---|
| S1 MainView | initial route `/` (only) |
| S2 Drawer | ☰ on S3, S5, S6 |
| S3 Dashboard | tab 0 |
| S5 Inventory | tab 1 |
| S6 Safe | tab 2 |
| — | S7 Settings | — (removed) |
| S8 Customers | drawer «جميع العملاء» |
| S9 Suppliers | drawer «جميع الموردين» |
| S10 Customer form | S8 empty-state «إضافة عميل» · S8 FAB «إضافة عميل» · `CustomerCard` ✎ (S8) |
| S11 Supplier form | S9 empty-state «إضافة مورد» · S9 FAB «إضافة مورد» · `SupplierCard` ✎ (S9) |
| S12 Product form | S5 FAB · S5 empty state · `ProductCard` ✎ (S5) · S14 empty state · S16 FAB (`isQuantitiyEditable:false`) |
| S13 Sell invoice | S3 quick action «فاتورة بيع» |
| S14 Sell picker | S13 FAB `+` |
| S15 Buy invoice | drawer «فواتير المشتريات» · S3 quick action «فاتورة شراء» |
| S16 Buy picker | S15 FAB `+` |
| S17 | Add expense | S3 quick-action card «مصروف» |
| S18 Invoice details | S6 card tap (sell/buy/return) |
| D1 delete confirm | `ProductCard` 🗑 (S5, also reachable wherever cards render) |
| D2 adjust balance | S6 BalanceCard «تعديل» |
| D3 price dialog | S16 card «إضافة للفاتورة» |
| D4/D5 detail dialogs | S6 card tap (expense / manual adjustment) |

### 9.2 Return edges (pop targets)
Every `pop` returns to the exact pusher: S10–S12, S14, S16, S17, S18 and D3 pop to their triggers; S13/S15 pop after confirm to whatever pushed them (S3 quick action, drawer push for S15). D1/D2/D4/D5 pop only the dialog route.

### 9.3 Cross-feature data coupling
- S3 reads `SafeBalance` (hero), `TransactionEntry` aggregates (KPIs/charts), `Product`/`SellInvoice`/`BuyInvoice`/`Expense` (via `DashboardCubit`).
- S6 reads `TransactionEntry` and resolves `InvoiceDetailsModel` / `ManualAdjustmentModel` on tap.
- S13/S15 mutate `Product` quantities, `SafeBalance`, `SellInvoice`/`BuyInvoice`, `InvoiceItemModel`, `TransactionEntry`; S16 additionally may update `Product` prices (D3).
- S17/S6 mutate `ExpenseModel`, `SafeBalance`, `ManualAdjustmentModel`, `TransactionEntry`.
- Tab entry triggers reloads for S5/S6 (see §3.4) — i.e., **S3 is the only tab that does not auto-refresh on re-entry** (it refreshes via `..init()` on tab construction and pull-to-refresh).

---

## 10. Shared Component Catalog

| Component | File | Notes |
|---|---|---|
| `CustomAppBar` | `core/widgets/custom_app_bar.dart` | `PreferredSize 56 h`; title row = SVG logo (32 r) + `bold18`; `showDrawerButton` ⇒ ☰ opens `mainScaffold` drawer; else default leading (automatic back arrow on pushed routes) |
| `AppDrawer` | `core/widgets/app_drawer.dart` | see S2 |
| `AppTextField` | `core/widgets/app_text_field.dart` | see §7.1 |
| `SearchField` | `core/widgets/search_field.dart` | debounce 300 ms, clear suffix |
| `AppButton` | `core/widgets/app_button.dart` | full-width primary action |
| `QuantityCounter` | `core/widgets/quantity_counter.dart` | see §7.1 |
| `EmptyStateWidget` / `ErrorStateWidget` | `core/widgets/*` | see §8.1 |
| `AddProductImageWidget` / `ProductImage` | `core/widgets/add_image.dart` | circular avatar + floating badge (`+` / ✎), radius 55 r / 150×150 |
| `ProductCard` | `features/inventory/.../product_card.dart` | see S5 |
| `CustomerCard` / `SupplierCard` | feature widget folders | see S8/S9 |
| `BalanceCard` / `TransactionsFilter` / `TransactionCard` / `DateHeader` | `features/safe/...` | see S6 |
| `Selling/BuyingInvoiceItemTile`, `...ProductListWithCounters`, `...TotalsCard`, dropdowns | feature folders | see S13–S16 |
| `DashboardQuickActions` | `features/dashboard/...` | see S3 |
| `Dashboard*` widgets | `features/dashboard/...` | see S3 |

---

## 11. Implementation Discrepancies

Collected, **marked per current source (2026-10-03)**. Items resolved since the 2026-09-27 review are flagged **[FIXED]** with the new behaviour.

**Routing / reachability**
- **X1 — `AppRoutes.addInvoiceView` (`'/addInvoiceView'`)** — *still open*: declared (`configrations.dart:172`) but has **no `case`** and **no call sites** → `default` returns an empty `Scaffold`.
- **X2 — Unreachable widgets** — *still open*: `DashboardListCard` and `DashboardEmptyState` remain implemented but unreferenced.
- **X3 — Dashboard CTA mismatch** — *partially addressed 2026-10-03 (`75d5f08`)*: the dashboard now has `DashboardQuickActions` (sell invoice / buy invoice / expense), but `AGENTS.md` still describes 4 quick-add cards (sell, customer, supplier, product) — customer/supplier/product creation is still only reachable via S5/S8/S9 (and S14/S16 empty states).
- **X7 — Settings placeholder** — **[FIXED 2026-10-03]**: `SettingsView`, tab 4, drawer row and `/settings` route removed entirely.

**Missing affordances**
- **X4 — No "add" button on populated lists** — **[FIXED 2026-10-03]**: `AllCustomersView` / `AllSuppliersView` now expose extended FABs («إضافة عميل» / «إضافة مورد») that push S10/S11 even when the list is populated.
- **X5 — No back or drawer button on S8/S9** — *still open*: both keep `SliverAppBar(automaticallyImplyLeading: false, ...)` with no `showDrawerButton` → rely on system back; drawer not re-openable from them.

**Logic / UX defects**
- **X6 — `AddExpenseView` pops unconditionally** — **[FIXED 2026-10-03]**: `_saveExpense()` now returns `bool` (`add_expense_view.dart:51,112`) and `pop` runs only on success.
- **X8 — Wrong title on buy invoice** — **[FIXED 2026-10-03]**: `BuyingInvoiceView` now uses `AppStrings.buyInvoice` → «فاتورة شراء».
- **X9 — Success snackbars race the `pop`** — **[partially fixed 2026-10-03]**: `SellInvoiceCubit.confirmInvoice()` / buy equivalent now return a success `bool` and S13/S15 pop only on success, so stock-shortage errors now stay visible; the *success* snackbar is still raised immediately before the pop and may flash out.
- **X10 — Snackbars on popped contexts** — **[partially fixed 2026-10-03]**: `ProductFormView` no longer pops on failure (stays to show the error); the success `BlocListener` snackbar still fires just before `pop(result)` (`product_form_view.dart:92-106,284`), so it can still be cut off, and the dual BlocListener+try/catch feedback path remains.
- **X11 — Transaction numbering** — **[FIXED 2026-10-03]**: `TransactionCard` now renders `'#${transaction.referenceId}'` (`transaction_card.dart:98`); `TransactionsEntry.referenceId` is set to the invoice id (e.g. `sell_invoice_repository_impl.dart:108`), matching `InvoiceDetailsView`'s `'#${invoice.id}'`. The stray `+1` and the `signedValue` refactor (`dd6225b`) are reflected.

**Convention violations (vs AGENTS.md rules)**
- **X12 — `QuantityCounter`**: raw `TextFormField` + hard-coded `InputDecoration`/colors (`AppColors.red`, `AppColors.success`), plus a leftover `print(widget.maxQuantity)` debug statement (`quantity_counter.dart:92`).
- **X13 — Hard-coded colors/styles outside `AppColors`/`AppTheme`**: `SellingInvoiceTotalsCard` uses `Colors.green.shade50/200` and `Colors.green`; selling/buying product cards and item tiles use `Colors.grey[600]` and inline `ElevatedButton`s; FAB labels use `Colors.white`; `EmptyStateWidget` uses a raw `ElevatedButton`; multiple widgets build `BoxDecoration`/`MenuStyle`/`ButtonStyle` inline instead of through `AppTheme`.
- **X14 — Mixed-language error copy**: cubits emit English errors — «Failed to save invoice: e» (sell & buy), «Failed to load products: e», «الباركود مستخدم بالفعل» is Arabic but `Failed …` strings surface directly to the user in an Arabic-only app.
- **X15 — Unused strings** in `AppStrings` (defined, never referenced): `invoiceSaved`, `selectCustomerAndAddProducts`, `changePrice`, `startSearchByBarcodeOrName`, `searchByBarcodeOrName`, `sellInvoiceDetails`, `buyInvoiceDetails`, `unknownCustomer`, `unknownSupplier`, `noProductsInSellInvoice`, `noProductsInBuyInvoice`, `lineTotal`, `customerRequired`, `atLeastOneProduct`, `insufficientStock`, `discountExceedsSubtotal` — including two that would fix real gaps (empty-invoice-details copy and discount validation copy).

**Product / feature gaps visible in the UI**
- **X16 — Return receipts are read-only**: `TransactionType.returnReceipt` cards render («مرتجع», warning color, opens S18) and `ReturnReceipt` exists as an entity, but **no screen creates one**; the drawer lists «فواتير المرتجعات» under «قريباً» with a «جديد» badge.
- **X17 — Expense amount sign display** *(updated)*: the old `ExpenseCard` (which printed the negative `ExpenseModel.value` with a red color) was removed with the safe/transaction merge; amounts are now rendered via `TransactionCard`/`TransactionEntry.signedValue` (still sign + red color for expenses). `BalanceCard(isNegative: false)` remains hard-coded on S6, so the red/negative branch is still dead code.
- **X18 — D3 confirm label** — **[FIXED 2026-10-03]**: the price dialog's confirm action now reads **«تغيير السعر»** (`change_product_price_dialog.dart:149`).
- **X19 — Docs vs code drift**: `AGENTS.md` still states navBar height `65.h` (code: `58`) and still describes a «الاعدادات» tab/drawer entry and dark-theme toggle gotchas that no longer match (settings removed, `ThemeMode.light` hardcoded at `main.dart:80` with the AppCubit binding commented out at `main.dart:79`). `SPECIFICATION.md` §11-I2 (expense sign) should still be read against `SafeCubit.addExpense` (`value: -value`), which makes runtime balance math correct as documented in §4 of that file.
- **X20 — `DashboardPeriod.formmatTime` typo** (method name) and `productFormView` route path `'/addProductView'` vs constant name `productFormView` — cosmetic inconsistencies that affect greppability only.

---

*End of document. Generated from source inspection only; re-verified against source on 2026-10-03 (commits through `f36994e`).*
