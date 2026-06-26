import 'dart:developer';

import 'package:Inventra/core/transitions/page_route_builder_method.dart';
import 'package:Inventra/features/dashboard/presentation/views/add_customer_view.dart';
import 'package:Inventra/features/dashboard/presentation/views/add_invoice_view.dart';
import 'package:Inventra/features/dashboard/presentation/views/add_product_view.dart';
import 'package:Inventra/features/dashboard/presentation/views/add_supplier_view.dart';
import 'package:Inventra/features/main/presentation/views/main_view.dart';
import 'package:flutter/material.dart';

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
              const AddProductView(),
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
  static const String addcustomerView = '/addcustomerView';
}
