import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:calculator/core/router/app_router.dart';
import 'package:calculator/core/theme/app_theme.dart';
import 'package:calculator/core/services/database_service.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    try {
      final box = Hive.box(DatabaseService.settingsBoxName);
      final themeStr = box.get('theme_mode', defaultValue: 'dark');
      return themeStr == 'light' ? ThemeMode.light : ThemeMode.dark;
    } catch (_) {
      return ThemeMode.dark;
    }
  }

  void toggle() {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newMode;
    try {
      final box = Hive.box(DatabaseService.settingsBoxName);
      box.put('theme_mode', newMode == ThemeMode.light ? 'light' : 'dark');
    } catch (_) {
      // Fail-safe if Hive isn't initialized (e.g. in widget tests)
    }
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Antigravity Calculator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
