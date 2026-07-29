# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

## Users

**Primary:** Arabic-speaking small shop/retail owners and warehouse/inventory managers. They operate in Arabic RTL environments (Saudi Arabia, Gulf region, wider Arabic market). They need to manage daily operations offline without internet dependency.

**Secondary:** Employees in retail/wholesale operations who handle stock counts, invoice creation, supplier/customer management.

**Situation:** Working behind a counter, in a warehouse, or on the shop floor. Often one-handed phone use. Need fast Arabic input, barcode scanning, quick invoice creation, and instant safe/cash balance visibility.

**Job-to-be-done:** Run daily retail operations end-to-end — add products with barcodes/prices, create sell/buy/return invoices, track expenses, monitor safe balance, view profit/sales analytics — all offline, in Arabic, RTL-first.

## Product Purpose

**Inventra** is an offline-first, Arabic RTL inventory + simple POS app for small retailers. No backend, no cloud, no accounts — just a local ObjectBox database on the device.

**Meaningfully different:** Unlike generic inventory apps or cloud POS systems, Inventra is purpose-built for Arabic RTL retailers who need: zero internet dependency, ObjectBox local speed, barcode-driven product entry, invoice workflows (sell/buy/return) that auto-adjust inventory + safe balance, and a dashboard showing real-time profit/sales/expenses — all in a cohesive Arabic-first design system.

**Success means:** A shop owner opens the app, scans a barcode, creates a sell invoice in <30 seconds, sees the safe balance update instantly, and at day-end views accurate profit/expense summary — without ever leaving the app or needing internet.

## Positioning

The only offline-first, Arabic RTL, ObjectBox-powered inventory + POS that combines: product CRUD with barcode, sell/buy/return invoices auto-syncing inventory + safe, expenses tracking, and a real-time dashboard — all in one cohesive Arabic design system with zero backend.

Neighboring products cannot truthfully copy: the RTL-first Arabic UX, ObjectBox local-only architecture, invoice→inventory+safe auto-reconciliation, and Cairo font Arabic typography system.

## Operating Context

**Workflows (daily):**
1. **Morning:** Open app → Dashboard shows yesterday's profit/sales/expenses → Check safe balance
2. **During day:** Scan barcode → Create sell invoice (customer + items) → Safe↑, Inventory↓ auto → Print/send receipt
3. **Restocking:** Create buy invoice (supplier + items) → Safe↓, Inventory↑ auto
4. **Returns:** Create return receipt from sell invoice → Safe↓, Inventory↑ auto
5. **Expenses:** Log expense (rent, utilities, etc.) → Safe↓
6. **End of day:** Dashboard shows updated profit, sales total, expenses, safe balance

**Environment:** Shop counter, warehouse shelf, delivery van. Phone held one-handed. Arabic keyboard. Barcode scanner (camera). Occasional thermal printer via Bluetooth.

**Rituals:** Daily open/close safe count. Weekly stock take. Monthly supplier settlement. VAT-ready invoice format (implied by buy/sell prices).

**Artifacts:** Invoices (sell/buy/return), product cards with barcode, customer/supplier ledgers, safe balance history, expense categories.

## Capabilities and Constraints

**Confirmed functionality:**
- Product CRUD: name, barcode, image, quantity, buy/sell/wholesale prices, supplier link
- Customer CRUD: name, phone, address, running balance
- Supplier CRUD: name, phone, address, running balance
- Sell Invoice: customer + line items → total, paid amount, date → inventory↓, safe↑
- Buy Invoice: supplier + line items → total, paid amount, date → inventory↑, safe↓
- Return Receipt: from sell invoice + items → total, date → inventory↑, safe↓
- Expense: note, amount, date, category → safe↓
- Safe Balance: running total with transaction history
- Dashboard: profit, sales, expenses, safe balance analytics + 4 quick-add cards
- Operations History: unified list of all transactions with filter/search
- Settings: placeholder (theme toggle disabled, locale fixed)

**Technical constraints:**
- **Platform:** Android primary; iOS/Web/Linux/macOS/Windows secondary (adaptive web acceptable)
- **Language:** Arabic only, RTL only — `Locale('ar')` hardcoded, `supportedLocales: [Locale('ar')]`
- **Database:** ObjectBox (local, no sync) — entities in `core/models/*.dart` with `@Entity()`, indexes on barcode/name/date
- **Codegen required:** Run `dart run build_runner build --delete-conflicting-outputs` after any model change
- **State:** `flutter_bloc` ^9.1.1 Cubit pattern (not Bloc) — feature cubits in `features/*/controller/cubit/`, `AppCubit` for app-wide state
- **DI:** `GetIt` ^9.2.1 — strict init order: `CacheHelper` → `ObjectBoxServices` → Repositories → Cubits (all LazySingleton except AppCubit)
- **Routing:** Custom `AppRouter` + `AppNavigation` (NOT go_router) — named routes in `AppRoutes`, navigation via `AppNavigation.pushName()` only
- **Theme:** `AppTheme` with `AppColors` + `AppTextStyle` — NEVER hardcode colors, TextStyles, BoxDecorations, InputDecorations, ButtonStyles. Use `AppTextField`, `AppButton`, `AppDrawer` only.
- **Widgets:** NEVER inline builders or `_build*()` methods — extract to proper widget classes in `features/*/presentation/widgets/` or `core/widgets/`
- **BLoC states:** Each `BlocBuilder` state body (Loading/Error/Loaded) MUST be a separate widget class (e.g., `SafeLoadingBody`)
- **Const correctness:** `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, `prefer_const_declarations` enforced
- **Responsive:** `flutter_screenutil` with `designSize: Size(360, 690)` — use `.w`, `.h`, `.sp` extensions
- **Bottom nav:** `persistent_bottom_nav_bar_v2` ^6.3.2 (Style8BottomNavBar)
- **Icons:** Material Icons + `flutter_svg` for custom assets
- **Image picker:** `image_picker` ^1.2.2 for product images
- **Lint:** Defaults only (`flutter_lints` ^6.0.0), no `analysis_options.yaml`
- **Theme toggle:** Dark theme exists in `AppTheme` but `themeMode: ThemeMode.light` hardcoded in `main.dart:76` — not wired to `AppCubit`

**Explicitly undecided:**
- VAT/tax calculation on invoices
- Multi-user/role support
- Cloud backup/sync (explicitly out of scope — offline-first)
- Multi-language (explicitly Arabic-only)
- Barcode scanning implementation (camera vs. external scanner)
- Thermal printer integration details
- Export/report formats (PDF, Excel, CSV)

## Brand Commitments

**Name:** Inventra (English, used as package name `Inventra` with capital I in imports)

**Voice:** Professional, efficient, Arabic-first. Direct, no fluff. RTL-aware copy.

**Assets:** Cairo font family (`assets/fonts/Cairo.ttf`) — the only font. Custom `AppColors` palette (primary, secondary, success, red, grey, white, darkRed, lightRed, etc.). `AppTheme` with full light/dark `ColorScheme` and component themes.

**Identity constraints:** Arabic RTL is non-negotiable. Cairo font is non-negotiable. Offline-first ObjectBox is non-negotiable. No backend/cloud is a feature, not a limitation.

## Evidence on Hand

**Real codebase (source of truth):**
- `lib/main.dart` — entry point, DI setup, MaterialApp config
- `lib/core/models/*.dart` — 11 ObjectBox entities (Product, Customer, Supplier, SellInvoice, BuyInvoice, ReturnReceipt, Expense, SafeBalance, InvoiceItem, ManualAdjustment, TransactionEntry)
- `lib/features/*/` — 10 feature modules (dashboard, inventory, customers, suppliers, selling_invoice, buying_invoice, safe, transactions, expenses, settings, main)
- `lib/core/config/configrations.dart` — `AppRouter` + `AppRoutes`
- `lib/core/navigations/navigations.dart` — `AppNavigation` helpers
- `lib/core/utilities/app_theme.dart` — Light/dark `ThemeData` with component themes
- `lib/core/utilities/app_colors.dart` — `AppColors` class
- `lib/core/utilities/app_text_style.dart` — `AppTextStyle` class
- `lib/core/widgets/` — `AppTextField`, `AppButton`, `AppDrawer`, `CustomAppBar`, etc.

**Absences (must not fabricate):**
- No user authentication/accounts
- No cloud sync or backend API
- No multi-language support
- No automated tests visible (`test/` directory exists but contents unknown)
- No CI/CD configuration
- No `analysis_options.yaml` (lint defaults only)
- No design system documentation (`DESIGN.md` absent)
- No visual regression testing

## Product Principles

1. **Arabic-first, RTL-always** — Every pixel, interaction, and flow designed for Arabic RTL. No LTR accommodation.
2. **Offline-first, zero backend** — ObjectBox local DB is the architecture. No network calls for core flows. Sync is explicitly out of scope.
3. **Invoice = source of truth** — Sell/Buy/Return invoices are the atomic operations. Inventory and Safe balance derive from them, never edited directly.
4. **Speed over features** — Shop floor speed: barcode scan → invoice in <30s. Dashboard glanceable in <3s. No deep nesting.
5. **Cohesive Arabic design system** — One font (Cairo), one color system (AppColors), one typography (AppTextStyle), one component library (AppTheme). No ad-hoc styling.

## Accessibility & Inclusion

**Known requirements:**
- Arabic RTL layout — mirrored navigation, mirrored icons where appropriate, correct text alignment
- Cairo font supports Arabic diacritics and numerals
- `flutter_localizations` delegates for Material/Cupertino RTL support
- Screen reader labels in Arabic (via semantics)
- Touch targets ≥ 48dp (Material baseline)
- Color contrast: AppColors must meet WCAG AA in both light/dark themes

**Not yet established:**
- Dynamic type scaling beyond `flutter_screenutil` `.sp`
- High contrast mode
- Reduced motion preference
- VoiceOver/TalkBack testing protocol