// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Inventra/core/controller/controllers/app_cubit/app_cubit.dart';
import 'package:Inventra/core/utilities/app_theme.dart';

class FakeAppCubit extends AppCubit {
  FakeAppCubit() : super();
}

void main() {
  testWidgets('App starts smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, _) {
          return BlocProvider<AppCubit>.value(
            value: FakeAppCubit(),
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.light,
              locale: const Locale('ar'),
              home: const Scaffold(body: Text('Test')),
            ),
          );
        },
      ),
    );

    // Verify that our app starts with a MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
