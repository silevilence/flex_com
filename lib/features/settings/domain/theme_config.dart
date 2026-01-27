import 'package:flutter/material.dart';

/// Theme mode configuration for the application.
///
/// Supports three modes: light, dark, and system (follows OS setting).
class ThemeConfig {
  const ThemeConfig({this.themeMode = ThemeMode.system});

  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    final modeString = json['themeMode'] as String?;
    final mode = switch (modeString) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    return ThemeConfig(themeMode: mode);
  }

  /// The current theme mode.
  final ThemeMode themeMode;

  Map<String, dynamic> toJson() {
    final modeString = switch (themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    return {'themeMode': modeString};
  }

  ThemeConfig copyWith({ThemeMode? themeMode}) {
    return ThemeConfig(themeMode: themeMode ?? this.themeMode);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeConfig && other.themeMode == themeMode;
  }

  @override
  int get hashCode => themeMode.hashCode;
}
