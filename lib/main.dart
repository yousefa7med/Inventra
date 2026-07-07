import 'package:Inventra/core/config/configrations.dart';
import 'package:Inventra/core/controller/controllers/app_cubit/app_cubit.dart';
import 'package:Inventra/core/helper/cache_helper.dart';
import 'package:Inventra/core/observer.dart';
import 'package:Inventra/core/utilities/app_theme.dart';
import 'package:Inventra/features/inventory/controller/cubit/product_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();
  Bloc.observer = AppBlocObserver();

  runApp(
    BlocProvider(
      create: (context) => AppCubit()..init(),
      child: const Inventra(),
    ),
  );
}

class Inventra extends StatelessWidget {
  const Inventra({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,

              locale: const Locale('ar'),

              supportedLocales: const [Locale('ar')],

              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              themeAnimationCurve: Curves.easeInOut,
              themeAnimationDuration: const Duration(milliseconds: 100),
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              // themeMode: AppCubit.get(context).getTheme(),
              themeMode: ThemeMode.light,
              initialRoute: AppRoutes.mainView,
              onGenerateRoute: AppRouter.generateRoute,
            );
          },
        );
      },
    );
  }
}

Future<void> configureDependencies() async {
  // 1. CacheHelper
  final cacheHelper = CacheHelper();
  await cacheHelper.init();
  GetIt.instance.registerSingleton<CacheHelper>(cacheHelper);

  // 2. ObjectBoxServices
  final objectBoxServices = ObjectBoxServices();
  await objectBoxServices.init();
  GetIt.instance.registerSingleton<ObjectBoxServices>(objectBoxServices);

  // 3. Cubits (LazySingletons for app-wide state)
  GetIt.instance.registerLazySingleton<AppCubit>(() => AppCubit());
  GetIt.instance.registerLazySingleton<ProductCubit>(() => ProductCubit());
}
