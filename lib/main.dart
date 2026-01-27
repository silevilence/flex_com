import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_page.dart';
import 'features/settings/application/config_providers.dart';

void main() {
  runApp(const ProviderScope(child: FlexComApp()));
}

/// The root widget of the FlexCom application
class FlexComApp extends ConsumerWidget {
  const FlexComApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(themeModeProvider);

    // Default to system theme while loading
    final themeMode = themeModeAsync.value ?? ThemeMode.system;

    return MaterialApp(
      title: 'FlexCom',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const HomePage(),
    );
  }
}
