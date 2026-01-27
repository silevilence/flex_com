import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../connection/domain/connection_config.dart';
import '../../serial/domain/serial_port_config.dart';
import '../data/config_service.dart';

part 'config_providers.g.dart';

/// Provider for the config service.
@Riverpod(keepAlive: true)
ConfigService configService(Ref ref) {
  return ConfigService();
}

/// Provider for loading saved serial port configuration.
///
/// This is used to restore the last used configuration on app startup.
@riverpod
Future<SerialPortConfig?> savedSerialConfig(Ref ref) async {
  final service = ref.watch(configServiceProvider);
  return service.loadConfig();
}

/// Notifier for managing saved serial port configuration.
@Riverpod(keepAlive: true)
class SavedConfigNotifier extends _$SavedConfigNotifier {
  @override
  Future<SerialPortConfig?> build() async {
    final service = ref.watch(configServiceProvider);
    return service.loadConfig();
  }

  /// Saves the configuration and updates state.
  Future<bool> saveConfig(SerialPortConfig config) async {
    final service = ref.read(configServiceProvider);
    final success = await service.saveConfig(config);
    if (success) {
      state = AsyncData(config);
    }
    return success;
  }
}

// ============ TCP Client Config ============

/// Notifier for managing saved TCP client configuration.
@Riverpod(keepAlive: true)
class SavedTcpClientConfig extends _$SavedTcpClientConfig {
  @override
  Future<TcpClientConfig?> build() async {
    final service = ref.watch(configServiceProvider);
    return service.loadTcpClientConfig();
  }

  /// Saves the configuration and updates state.
  Future<bool> saveConfig(TcpClientConfig config) async {
    final service = ref.read(configServiceProvider);
    final success = await service.saveTcpClientConfig(config);
    if (success) {
      state = AsyncData(config);
    }
    return success;
  }
}

// ============ TCP Server Config ============

/// Notifier for managing saved TCP server configuration.
@Riverpod(keepAlive: true)
class SavedTcpServerConfig extends _$SavedTcpServerConfig {
  @override
  Future<TcpServerConfig?> build() async {
    final service = ref.watch(configServiceProvider);
    return service.loadTcpServerConfig();
  }

  /// Saves the configuration and updates state.
  Future<bool> saveConfig(TcpServerConfig config) async {
    final service = ref.read(configServiceProvider);
    final success = await service.saveTcpServerConfig(config);
    if (success) {
      state = AsyncData(config);
    }
    return success;
  }
}

// ============ UDP Config ============

/// Notifier for managing saved UDP configuration.
@Riverpod(keepAlive: true)
class SavedUdpConfig extends _$SavedUdpConfig {
  @override
  Future<UdpConfig?> build() async {
    final service = ref.watch(configServiceProvider);
    return service.loadUdpConfig();
  }

  /// Saves the configuration and updates state.
  Future<bool> saveConfig(UdpConfig config) async {
    final service = ref.read(configServiceProvider);
    final success = await service.saveUdpConfig(config);
    if (success) {
      state = AsyncData(config);
    }
    return success;
  }
}

// ============ Theme Mode Config ============

/// Notifier for managing theme mode.
@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  Future<ThemeMode> build() async {
    final service = ref.watch(configServiceProvider);
    final config = await service.loadThemeConfig();
    return config.themeMode;
  }

  /// Sets the theme mode and persists it.
  Future<void> setThemeMode(ThemeMode mode) async {
    final service = ref.read(configServiceProvider);
    await service.saveThemeMode(mode);
    state = AsyncData(mode);
  }
}
