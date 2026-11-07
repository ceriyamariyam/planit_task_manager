import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themePrefKey = 'selected_theme_mode';

  ThemeCubit() : super(ThemeMode.system) {
    _loadThemeFromPrefs();
  }

  // Load saved theme preference from local storage without duplicate emissions
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themePrefKey);

    ThemeMode loadedMode;
    if (themeString == 'light') {
      loadedMode = ThemeMode.light;
    } else if (themeString == 'dark') {
      loadedMode = ThemeMode.dark;
    } else {
      loadedMode = ThemeMode.system;
    }

    if (state != loadedMode) {
      emit(loadedMode);
    }
  }

  // Toggle or switch explicit theme mode
  Future<void> updateThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.light) {
      await prefs.setString(_themePrefKey, 'light');
    } else if (mode == ThemeMode.dark) {
      await prefs.setString(_themePrefKey, 'dark');
    } else {
      await prefs.remove(_themePrefKey);
    }
    emit(mode);
  }

  // Quick toggle between light and dark modes
  Future<void> toggleTheme() async {
    if (state == ThemeMode.dark) {
      await updateThemeMode(ThemeMode.light);
    } else {
      await updateThemeMode(ThemeMode.dark);
    }
  }
  // void toggleTheme() {
  //   if (state == ThemeMode.dark) {
  //     updateThemeMode(ThemeMode.light);
  //   } else {
  //     updateThemeMode(ThemeMode.dark);
  //   }
  // }
}
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ThemeCubit extends Cubit<ThemeMode> {
//   static const String _themePrefKey = 'selected_theme_mode';

//   ThemeCubit() : super(ThemeMode.system) {
//     _loadThemeFromPrefs();
//   }

//   // Load saved theme preference from local storage
//   Future<void> _loadThemeFromPrefs() async {
//     final prefs = await SharedPreferences.getInstance();
//     final themeString = prefs.getString(_themePrefKey);

//     if (themeString == 'light') {
//       emit(ThemeMode.light);
//     } else if (themeString == 'dark') {
//       emit(ThemeMode.dark);
//     } else {
//       emit(ThemeMode.system);
//     }
//   }

//   // Toggle or switch explicit theme mode
//   Future<void> updateThemeMode(ThemeMode mode) async {
//     final prefs = await SharedPreferences.getInstance();
//     if (mode == ThemeMode.light) {
//       await prefs.setString(_themePrefKey, 'light');
//     } else if (mode == ThemeMode.dark) {
//       await prefs.setString(_themePrefKey, 'dark');
//     } else {
//       await prefs.remove(_themePrefKey);
//     }
//     emit(mode);
//   }

//   // Quick toggle between light and dark modes
//   void toggleTheme() {
//     if (state == ThemeMode.dark) {
//       updateThemeMode(ThemeMode.light);
//     } else {
//       updateThemeMode(ThemeMode.dark);
//     }
//   }
// }