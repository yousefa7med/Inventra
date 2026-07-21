# Research: Buying Invoice Feature

**Date**: 2026-07-20 | **Spec**: [spec.md](spec.md)

## Research Questions & Answers

### 1. How should BuyingInvoiceModel relate to InvoiceItemModel?

**Context**: Spec FR-001/002 requires BuyingInvoiceModel with items (one-to-many) using existing InvoiceItemModel. The existing SellingInvoiceModel uses ToMany<SellInvoiceItemModel> but we now have shared InvoiceItemModel.

**Finding**: In ObjectBox, ToMany relationships work with any entity. The InvoiceItemModel already has a product ToOne. For the buying invoice backlink, we need a ToOne<BuyingInvoiceModel> on InvoiceItemModel.

**Decision**: Add `ToOne<BuyingInvoiceModel> invoice = ToOne<BuyingInvoiceModel>();` to InvoiceItemModel. BuyingInvoiceModel gets `ToMany<InvoiceItemModel> items = ToMany<InvoiceItemModel>();`. This mirrors SellingInvoiceModel pattern.

**References**: 
- `lib/core/models/selling_invoice_model.dart` (line 15: `final ToMany<SellInvoiceItemModel> items`)
- `lib/core/models/invoice_item_model.dart` (current: no invoice backlink)

### 2. How to implement supplier dropdown mirroring CustomerDropdownMenu?

**Context**: FR-003 requires SupplierDropdownMenu widget mirroring CustomerDropdownMenu pattern.

**Finding**: CustomerDropdownMenu (lib/features/selling_invoice/presentation/widgets/customer_dropdown_menu.dart):
- Uses DropdownMenu<CustomerModel> with search
- Arabic normalization for search matching
- Reads cubit.customers, cubit.selectedCustomer
- On selection calls cubit.selectCustomer()

**Decision**: Create SupplierDropdownMenu in features/buying_invoice/presentation/widgets/ with identical pattern:
- Read BuyInvoiceCubit.suppliers, selectedSupplier
- Use SupplierModel fields (name, storeName, phoneNum)
- Call cubit.selectSupplier() on selection
- Arabic normalization via same helper

### 3. Product selection view with quantity counter (default 0)

**Context**: FR-004/005 require FAB → product selection view (like AddProductToInvoiceView) with quantity counter default 0.

**Finding**: AddProductToInvoiceView (lib/features/selling_invoice/presentation/views/add_product_to_invoice_view.dart):
- SearchField for product search
- ProductListWithCountersSliver for list with quantity counters
- Uses SellInvoiceCubit.loadProducts(search)
- Products shown via ProductListWithCounters

**Decision**: Create ProductSelectionView in features/buying_invoice/presentation/views/:
- Same structure: SearchField + ProductListWithCounters
- Quantity counter default 0 (not 1 like selling)
- FAB opens ProductFormView for new product
- Returns selected products with qty > 0 to buying invoice

**Reuse**: ProductListWithCountersSliver and ProductCardWithCounter from selling_invoice/widgets can be reused with BuyInvoiceCubit.

### 4. Price change confirmation dialog for restocking

**Context**: FR-006: When adding existing product with different buying price, show dialog "Price changed. Update product buying price?"

**Finding**: No existing price change dialog pattern. Need new dialog component.

**Decision**: Create PriceChangeDialog in core/widgets/ or features/buying_invoice/presentation/widgets/:
- Show current buying price vs new price
- Two actions: "Update Price" / "Keep Current"
- Returns boolean: true = update product.buyingPrice, false = use current price
- Use showDialog with AppButton actions

### 5. BuyInvoiceCubitInterface methods mapping from SellInvoiceCubitInterface

**Context**: FR-010 requires BuyInvoiceCubit with interface mirroring SellInvoiceCubit.

**Finding**: SellInvoiceCubitInterface (lib/features/selling_invoice/controller/cubit/sell_invoice_cubit_interface.dart):
- loadCustomers(), loadProducts(search)
- selectCustomer(), clearCustomer()
- setDiscount(), addProductItemLine(), updateItemQuantity(), removeItem()
- validateSellInvoice(), confirmInvoice()
- Getters: items, selectedCustomer, customers, products, subtotal, totalAfterDiscount, discount

**Decision**: BuyInvoiceCubitInterface with supplier equivalents:
- loadSuppliers(), loadProducts(search)
- selectSupplier(), clearSupplier()
- setDiscount(), addProductItem(), updateItemQuantity(), removeItem()
- validateBuyInvoice(), confirmInvoice()
- Getters: items, selectedSupplier, suppliers, products, subtotal, totalAfterDiscount, discount

### 6. Repository pattern for BuyingInvoice

**Context**: FR-011 requires BuyInvoiceRepository interface and implementation.

**Finding**: SellInvoiceRepository (lib/features/selling_invoice/data/repositories/sell_invoice_repository.dart):
- createSellInvoice({customer, items, discount})
- getAllSellInvoices()
- getSellInvoiceById(id)

**Decision**: BuyInvoiceRepository with:
- createBuyInvoice({supplier, items, discount})
- getAllBuyInvoices()
- getBuyInvoiceById(id)
- Implementation uses ObjectBox boxes from ObjectBoxServices

### 7. Route registration and navigation

**Context**: FR-008/009 require drawer item (exists as placeholder) and route AppRoutes.buyingInvoiceView.

**Finding**: AppRoutes (lib/core/config/configrations.dart):
- buyInvoices = '/buy-invoices' (placeholder, line 159)
- Need to add buyingInvoiceView = '/buying-invoice'
- AppRouter.generateRoute() case for buyingInvoiceView

**Decision**: 
1. Update AppRoutes: add buyingInvoiceView = '/buying-invoice'
2. Update AppRouter: case for buyingInvoiceView → BlocProvider.value(BuyInvoiceCubit()..loadSuppliers(), BuyingInvoiceView())
3. Update AppDrawer: existing 'فواتير المشتريات' item already uses AppRoutes.buyInvoices - change to buyingInvoiceView or add new item
4. Register BuyInvoiceCubit as LazySingleton in main.dart configureDependencies()

### 8. ObjectBox codegen after model changes

**Context**: New BuyingInvoiceModel + modified InvoiceItemModel (add invoice backlink).

**Finding**: AGENTS.md: "ObjectBox requires codegen - run `dart run build_runner build --delete-conflicting-outputs` after model changes"

**Decision**: After creating BuyingInvoiceModel and updating InvoiceItemModel, run build_runner. Generated files: lib/objectbox.g.dart, lib/objectbox-model.json.

---

## Summary of Decisions

| Area | Decision |
|------|----------|
| BuyingInvoiceModel items | ToMany<InvoiceItemModel> with backlink ToOne<BuyingInvoiceModel> on InvoiceItemModel |
| Supplier dropdown | SupplierDropdownMenu mirroring CustomerDropdownMenu pattern |
| Product selection | ProductSelectionView reusing ProductListWithCountersSliver, qty default 0 |
| Price change dialog | New PriceChangeDialog widget, returns bool for update decision |
| BuyInvoiceCubitInterface | Mirrors SellInvoiceCubitInterface with supplier/product methods |
| BuyInvoiceRepository | Mirrors SellInvoiceRepository with supplier/items/discount |
| Routes | Add buyingInvoiceView, update AppRouter, update AppDrawer item |
| DI | Register BuyInvoiceCubit as LazySingleton in main.dart |
| Codegen | Run build_runner after model changes |

---

## Open Items (Deferred to Plan)

- Exact dialog text in Arabic
- Whether discount applies to buying invoices (spec says "optional" in FR-001)
- Whether paidAmount/partial payment needed for v1 (spec FR-001 says "partial payment support")
- Integration with SafeCubit for balance decrease (existing pattern in SellInvoiceCubit.confirmInvoice)