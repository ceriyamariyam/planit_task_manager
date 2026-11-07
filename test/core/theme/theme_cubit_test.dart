import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_task_manager/core/theme/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeCubit Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial state should default to ThemeMode.system', () {
      final cubit = ThemeCubit();
      expect(cubit.state, ThemeMode.system);
      cubit.close();
    });

    blocTest<ThemeCubit, ThemeMode>(
      'Emits [ThemeMode.dark] when updateThemeMode is called with dark mode and saves to preferences',
      build: () => ThemeCubit(),
      wait: const Duration(milliseconds: 100),
      act: (cubit) => cubit.updateThemeMode(ThemeMode.dark),
      expect: () => [ThemeMode.dark],
      verify: (_) async {
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('selected_theme_mode'), 'dark');
      },
    );

    blocTest<ThemeCubit, ThemeMode>(
      'Emits [ThemeMode.light] when updateThemeMode is called with light mode and saves to preferences',
      build: () => ThemeCubit(),
      wait: const Duration(milliseconds: 100),
      act: (cubit) => cubit.updateThemeMode(ThemeMode.light),
      expect: () => [ThemeMode.light],
      verify: (_) async {
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('selected_theme_mode'), 'light');
      },
    );
    blocTest<ThemeCubit, ThemeMode>(
      'Toggles between light and dark correctly',
      build: () => ThemeCubit(),
      wait: const Duration(milliseconds: 100),
      act: (cubit) async {
        await cubit.toggleTheme();
        await cubit.toggleTheme();
      },
      expect: () => [ThemeMode.dark, ThemeMode.light],
    );
    // blocTest<ThemeCubit, ThemeMode>(
    //   'Toggles between light and dark correctly',
    //   build: () => ThemeCubit(),
    //   wait: const Duration(milliseconds: 100),
    //   act: (cubit) {
    //     cubit.toggleTheme();
    //     cubit.toggleTheme();
    //   },
    //   expect: () => [ThemeMode.dark, ThemeMode.light],
    // );
  });
}
