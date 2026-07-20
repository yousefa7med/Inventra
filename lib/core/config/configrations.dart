import 'dart:developer';

import 'package:Inventra/core/models/customer_model.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/core/models/supplier_model.dart';
import 'package:Inventra/core/transitions/page_route_builder_method.dart';
import 'package:Inventra/core/widgets/customer_form_view.dart';
import 'package:Inventra/core/widgets/product_form_view.dart';
import 'package:Inventra/core/widgets/supplier_form_view.dart';
import 'package:Inventra/features/buying_invoice/controller/cubit/buy_invoice_cubit.dart';
import 'package:Inventra/features/buying_invoice/presentation/views/product_selection_view.dart';
import 'package:Inventra/features/customers/controller/cubit/customer_cubit.dart';
import 'package:Inventra/features/customers/presentation/views/all_customers_view.dart';
import 'package:Inventra/features/inventory/controller/cubit/product_cubit.dart';
import 'package:Inventra/features/main/presentation/views/main_view.dart';
import 'package:Inventra/features/safe/controller/cubit/safe_cubit.dart';
import 'package:Inventra/features/safe/presentation/views/add_expense_view.dart';
import 'package:Inventra/features/selling_invoice/controller/cubit/sell_invoice_cubit.dart';
import 'package:Inventra/features/selling_invoice/presentation/views/add_product_to_invoice_view.dart';
import 'package:Inventra/features/selling_invoice/presentation/views/selling_invoice_view.dart';
import 'package:Inventra/features/settings/presentation/views/settings_view.dart';
import 'package:Inventra/features/suppliers/controller/cubit/supplier_cubit.dart';
import 'package:Inventra/features/suppliers/presentation/views/all_suppliers_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class AppRouter {
  static Route? generateRoute(RouteSettings settings) {
    log("${settings.name}");
    switch (settings.name) {
      case AppRoutes.mainView:
        return pageRouteBuilderMethod(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainView(),
        );

      case AppRoutes.productFormView:
        final product = settings.arguments as ProductModel?;
        return pageRouteBuilderMethod(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              BlocProvider.value(
                value: GetIt.instance<ProductCubit>(),
                child: ProductFormView(product: product),
              ),
        );

      case AppRoutes.supplierFormView:
        final supplier = settings.arguments as SupplierModel?;

        return pageRouteBuilderMethod(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              BlocProvider.value(
                value: GetIt.instance<SupplierCubit>(),
                child: SupplierFormView(supplier: supplier),
              ),
        );

      case AppRoutes.customerFormView:
        final customer = settings.arguments as CustomerModel?;
        return pageRouteBuilderMethod(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              BlocProvider.value(
                value: GetIt.instance<CustomerCubit>(),
                child: CustomerFormView(customer: customer),
              ),
        );

      case AppRoutes.addExpenseView:
        return pageRouteBuilderMethod(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              BlocProvider.value(
                value: GetIt.instance<SafeCubit>(),
                child: const AddExpenseView(),
              ),
        );

      case AppRoutes.sellingInvoiceView:
        return pageRouteBuilderMethod(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              BlocProvider.value(
                value: GetIt.instance<SellInvoiceCubit>()..loadCustomers(),
                child: const SellingInvoiceView(),
              ),
        );

      case AppRoutes.addProductToInvoice:
        final cubit = GetIt.instance<SellInvoiceCubit>();
        return pageRouteBuilderMethod(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              BlocProvider.value(
                value: cubit..loadProducts(''),
                child: const AddProductToInvoiceView(),
              ),
        );

      case AppRoutes.allCustomers:
        final cubit = GetIt.instance<CustomerCubit>();

        return pageRouteBuilderMethod(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              BlocProvider.value(
                value: cubit..loadCustomers(),
                child: const AllCustomersView(),
              ),
        );

      case AppRoutes.allSuppliers:
        final cubit = GetIt.instance<SupplierCubit>()..loadSuppliers();

        return pageRouteBuilderMethod(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              BlocProvider.value(value: cubit, child: const AllSuppliersView()),
        );

      case AppRoutes.buyingInvoiceView:
        return pageRouteBuilderMethod(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              const Scaffold(body: Center(child: Text('فاتورة شراء - قريباً'))),
        );

      case AppRoutes.productSelectionView:
        return pageRouteBuilderMethod(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              BlocProvider.value(
                value: GetIt.instance<BuyInvoiceCubit>()..loadProducts(''),
                child: const ProductSelectionView(),
              ),
        );

      case AppRoutes.settings:
        return pageRouteBuilderMethod(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SettingsView(),
        );

      default:
        return pageRouteBuilderMethod(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              const Scaffold(),
        );
    }
  }
}

abstract class AppRoutes {
  static const String mainView = '/';

  static const String customerFormView = '/customerFormView';
  static const String addInvoiceView = '/addInvoiceView';
  static const String productFormView = '/addProductView';
  static const String addExpenseView = '/addExpenseView';
  static const String sellingInvoiceView = '/selling-invoice';
  static const String addProductToInvoice = '/add-product-to-invoice';

  static const String allCustomers = '/all-customers';
  static const String allSuppliers = '/all-suppliers';
  static const String buyingInvoiceView = '/buying-invoice';
  static const String productSelectionView = '/product-selection';
  static const String settings = '/settings';

  static const String supplierFormView = '/edit-supplier';
}
