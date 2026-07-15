import 'dart:developer';

import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/core/transitions/page_route_builder_method.dart';
import 'package:Inventra/features/dashboard/presentation/views/add_customer_view.dart';
import 'package:Inventra/features/dashboard/presentation/views/add_invoice_view.dart';
import 'package:Inventra/features/dashboard/presentation/views/add_product_view.dart';
import 'package:Inventra/features/dashboard/presentation/views/add_supplier_view.dart';
import 'package:Inventra/features/inventory/controller/cubit/product_cubit.dart';
import 'package:Inventra/features/inventory/presentation/views/edit_product_view.dart';
import 'package:Inventra/features/selling_invoice/controller/cubit/sell_invoice_cubit.dart';
import 'package:Inventra/features/selling_invoice/presentation/views/add_product_to_invoice_view.dart';
import 'package:Inventra/features/selling_invoice/presentation/views/selling_invoice_view.dart';
import 'package:Inventra/features/main/presentation/views/main_view.dart';
import 'package:Inventra/features/safe/controller/cubit/safe_cubit.dart';
import 'package:Inventra/features/safe/presentation/views/add_expense_view.dart';
import 'package:Inventra/features/settings/presentation/views/settings_view.dart';
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
      case AppRoutes.addInvoiceView:
        return pageRouteBuilderMethod(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AddInvoiceView(),
        );
      case AppRoutes.addproductView:
        return pageRouteBuilderMethod(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              BlocProvider.value(
                value: GetIt.instance<ProductCubit>(),
                child: const AddProductView(),
              ),
        );
      case AppRoutes.addcustomerView:
        return pageRouteBuilderMethod(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AddCustomerView(),
        );
      case AppRoutes.addsupplierView:
        return pageRouteBuilderMethod(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AddSupplierView(),
        );
      case AppRoutes.editproductView:
        final product = settings.arguments as ProductModel;
        return pageRouteBuilderMethod(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              BlocProvider.value(
                value: GetIt.instance<ProductCubit>(),
                child: EditProductView(product: product),
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
        return pageRouteBuilderMethod(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              const Scaffold(body: Center(child: Text('جميع العملاء'))),
        );

      case AppRoutes.allSuppliers:
        return pageRouteBuilderMethod(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              const Scaffold(body: Center(child: Text('جميع الموردين'))),
        );

      case AppRoutes.buyInvoices:
        return pageRouteBuilderMethod(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              const Scaffold(body: Center(child: Text('فواتير المشتريات'))),
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
  static const String addInvoiceView = '/addInvoiceView';
  static const String addsupplierView = '/addsupplierView';
  static const String addproductView = '/addproductView';
  static const String editproductView = '/editproductView';
  static const String addcustomerView = '/addcustomerView';
  static const String addExpenseView = '/addExpenseView';
  static const String sellingInvoiceView = '/selling-invoice';
  static const String addProductToInvoice = '/add-product-to-invoice';

  static const String allCustomers = '/all-customers';
  static const String allSuppliers = '/all-suppliers';
  static const String buyInvoices = '/buy-invoices';
  static const String settings = '/settings';
}
