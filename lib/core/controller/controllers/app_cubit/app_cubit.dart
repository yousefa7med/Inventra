

import 'package:Inventra/core/helper/cache_helper.dart';
import 'package:Inventra/core/helper/cache_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppInitialState());

  ThemeModeState currentTheme = ThemeModeState.system;
  static AppCubit get(BuildContext context) => BlocProvider.of(context);
  Future<void> init() async {
    _loadTheme();

  }
  ThemeMode getTheme() {
    switch (currentTheme) {
      case ThemeModeState.light:
        return ThemeMode.light;
      case ThemeModeState.dark:
        return ThemeMode.dark;

      default:
        return ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeModeState theme) async {
    currentTheme = theme;
    GetIt.instance<CacheHelper>().saveData(
      key: CacheKeys.theme,
      value: theme.name,
    );
    emit(ThemeChangesState());
  }

  void _loadTheme() {
    String savedTheme =
        GetIt.instance<CacheHelper>().getData(CacheKeys.theme) as String? ??
        "system";

    currentTheme = ThemeModeState.values.firstWhere(
      (e) => e.name == savedTheme,
      orElse: () => ThemeModeState.system,
    );
    emit(ThemeChangesState());
  }


}

enum ThemeModeState { light, dark, system }
