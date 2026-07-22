import 'package:Inventra/core/transitions/slide_transation_builder.dart';
import 'package:flutter/material.dart';

PageRouteBuilder<T> pageRouteBuilderMethod<T>({
  required Widget Function(BuildContext, Animation<double>, Animation<double>)
  pageBuilder,
  required RouteSettings settings,
}) {
  return PageRouteBuilder(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 230),
    transitionsBuilder: slideTransitionBuilder,
    pageBuilder: pageBuilder,
  );
}
