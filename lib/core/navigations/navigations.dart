import 'package:flutter/material.dart';

abstract class AppNavigation {
static Future<T?> pushName<T extends Object?>({
  required BuildContext context,
  required String route,
  Object? argument,
  bool rootNavigator = false,
}) {
  return Navigator.of(
    context,
    rootNavigator: rootNavigator,
  ).pushNamed<T>(
    route,
    arguments: argument,
  );
}

  static void pushWithReplacement({
    required BuildContext context,
    required String route,
    bool rootNavigator = false,
  }) {
    Navigator.of(
      context,
      rootNavigator: rootNavigator,
    ).pushReplacementNamed(route);
  }

  static void pushAndRemoveUntil({
    required BuildContext context,
    required String route,
    bool rootNavigator = false,
  }) {
    Navigator.of(
      context,
      rootNavigator: rootNavigator,
    ).pushNamedAndRemoveUntil(route, (Route<dynamic> route) => false);
  }

  static void navigationdelay({
    required BuildContext context,
    required String route,
  }) {
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushNamed(context, route);
    });
  }

  static void pop<T extends Object?>( BuildContext context,[T? result]) {
    Navigator.pop(context,result);
  }
}
