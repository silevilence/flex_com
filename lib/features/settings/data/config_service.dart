import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/utils/app_paths.dart';
import '../../connection/domain/connection_config.dart';
import '../../serial/domain/serial_port_config.dart';
import '../domain/theme_config.dart';

/// Service for reading and writing user configuration to a JSON file.
///
/// The configuration file is stored in the user's application data directory
/// (e.g., %APPDATA%\FlexCom on Windows) as `config.json`.
class ConfigService {
  ConfigService({String? configPath}) : _configPath = configPath;

  final String? _configPath;
  String? _cachedConfigPath;

  /// Gets the path to the configuration file.
  Future<String> getConfigFilePath() async {
    if (_configPath != null) {
      return _configPath;
    }
    _cachedConfigPath ??= await AppPaths.getConfigFilePath();
    return _cachedConfigPath!;
  }

  /// 读取完整配置文件
  Future<Map<String, dynamic>> _readConfigFile() async {
    try {
      final configPath = await getConfigFilePath();
      final file = File(configPath);
      if (!await file.exists()) {
        return {};
      }
      final contents = await file.readAsString();
      return jsonDecode(contents) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  /// 写入完整配置文件
  Future<bool> _writeConfigFile(Map<String, dynamic> config) async {
    try {
      final configPath = await getConfigFilePath();
      final file = File(configPath);
      final encoder = const JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(config));
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Failed to save config: $e');
      return false;
    }
  }

  /// Loads the serial port configuration from the config file.
  ///
  /// Returns null if the file doesn't exist or can't be parsed.
  Future<SerialPortConfig?> loadConfig() async {
    try {
      final json = await _readConfigFile();
      final serialConfig = json['serialPort'] as Map<String, dynamic>?;
      if (serialConfig == null) {
        return null;
      }
      return SerialPortConfig.fromJson(serialConfig);
    } catch (e) {
      // ignore: avoid_print
      print('Failed to load config: $e');
      return null;
    }
  }

  /// Saves the serial port configuration to the config file.
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> saveConfig(SerialPortConfig config) async {
    try {
      final existingConfig = await _readConfigFile();
      existingConfig['serialPort'] = config.toJson();
      return _writeConfigFile(existingConfig);
    } catch (e) {
      // ignore: avoid_print
      print('Failed to save config: $e');
      return false;
    }
  }

  // ============ TCP Client Config ============

  /// 加载 TCP 客户端配置
  Future<TcpClientConfig?> loadTcpClientConfig() async {
    try {
      final json = await _readConfigFile();
      final tcpConfig = json['tcpClient'] as Map<String, dynamic>?;
      if (tcpConfig == null) {
        return null;
      }
      return TcpClientConfig.fromJson(tcpConfig);
    } catch (e) {
      // ignore: avoid_print
      print('Failed to load TCP client config: $e');
      return null;
    }
  }

  /// 保存 TCP 客户端配置
  Future<bool> saveTcpClientConfig(TcpClientConfig config) async {
    try {
      final existingConfig = await _readConfigFile();
      existingConfig['tcpClient'] = config.toJson();
      return _writeConfigFile(existingConfig);
    } catch (e) {
      // ignore: avoid_print
      print('Failed to save TCP client config: $e');
      return false;
    }
  }

  // ============ TCP Server Config ============

  /// 加载 TCP 服务器配置
  Future<TcpServerConfig?> loadTcpServerConfig() async {
    try {
      final json = await _readConfigFile();
      final tcpConfig = json['tcpServer'] as Map<String, dynamic>?;
      if (tcpConfig == null) {
        return null;
      }
      return TcpServerConfig.fromJson(tcpConfig);
    } catch (e) {
      // ignore: avoid_print
      print('Failed to load TCP server config: $e');
      return null;
    }
  }

  /// 保存 TCP 服务器配置
  Future<bool> saveTcpServerConfig(TcpServerConfig config) async {
    try {
      final existingConfig = await _readConfigFile();
      existingConfig['tcpServer'] = config.toJson();
      return _writeConfigFile(existingConfig);
    } catch (e) {
      // ignore: avoid_print
      print('Failed to save TCP server config: $e');
      return false;
    }
  }

  // ============ UDP Config ============

  /// 加载 UDP 配置
  Future<UdpConfig?> loadUdpConfig() async {
    try {
      final json = await _readConfigFile();
      final udpConfig = json['udp'] as Map<String, dynamic>?;
      if (udpConfig == null) {
        return null;
      }
      return UdpConfig.fromJson(udpConfig);
    } catch (e) {
      // ignore: avoid_print
      print('Failed to load UDP config: $e');
      return null;
    }
  }

  /// 保存 UDP 配置
  Future<bool> saveUdpConfig(UdpConfig config) async {
    try {
      final existingConfig = await _readConfigFile();
      existingConfig['udp'] = config.toJson();
      return _writeConfigFile(existingConfig);
    } catch (e) {
      // ignore: avoid_print
      print('Failed to save UDP config: $e');
      return false;
    }
  }

  /// Checks if a configuration file exists.
  Future<bool> configExists() async {
    final configPath = await getConfigFilePath();
    final file = File(configPath);
    return file.exists();
  }

  // ============ Layout Config ============

  /// 加载布局配置
  Future<LayoutConfig?> loadLayoutConfig() async {
    try {
      final json = await _readConfigFile();
      final layoutConfig = json['layout'] as Map<String, dynamic>?;
      if (layoutConfig == null) {
        return null;
      }
      return LayoutConfig.fromJson(layoutConfig);
    } catch (e) {
      // ignore: avoid_print
      print('Failed to load layout config: $e');
      return null;
    }
  }

  /// 保存布局配置
  Future<bool> saveLayoutConfig(LayoutConfig config) async {
    try {
      final existingConfig = await _readConfigFile();
      existingConfig['layout'] = config.toJson();
      return _writeConfigFile(existingConfig);
    } catch (e) {
      // ignore: avoid_print
      print('Failed to save layout config: $e');
      return false;
    }
  }

  // ============ Parser State Config ============

  /// 加载解析器状态配置
  Future<ParserStateConfig?> loadParserStateConfig() async {
    try {
      final json = await _readConfigFile();
      final parserConfig = json['parserState'] as Map<String, dynamic>?;
      if (parserConfig == null) {
        return null;
      }
      return ParserStateConfig.fromJson(parserConfig);
    } catch (e) {
      // ignore: avoid_print
      print('Failed to load parser state config: $e');
      return null;
    }
  }

  /// 保存解析器状态配置
  Future<bool> saveParserStateConfig(ParserStateConfig config) async {
    try {
      final existingConfig = await _readConfigFile();
      existingConfig['parserState'] = config.toJson();
      return _writeConfigFile(existingConfig);
    } catch (e) {
      // ignore: avoid_print
      print('Failed to save parser state config: $e');
      return false;
    }
  }

  // ============ Theme Config ============

  /// 加载主题配置
  Future<ThemeConfig> loadThemeConfig() async {
    try {
      final json = await _readConfigFile();
      final themeConfig = json['theme'] as Map<String, dynamic>?;
      if (themeConfig == null) {
        return const ThemeConfig();
      }
      return ThemeConfig.fromJson(themeConfig);
    } catch (e) {
      // ignore: avoid_print
      print('Failed to load theme config: $e');
      return const ThemeConfig();
    }
  }

  /// 保存主题配置
  Future<bool> saveThemeConfig(ThemeConfig config) async {
    try {
      final existingConfig = await _readConfigFile();
      existingConfig['theme'] = config.toJson();
      return _writeConfigFile(existingConfig);
    } catch (e) {
      // ignore: avoid_print
      print('Failed to save theme config: $e');
      return false;
    }
  }

  /// 快速保存主题模式
  Future<bool> saveThemeMode(ThemeMode mode) async {
    return saveThemeConfig(ThemeConfig(themeMode: mode));
  }
}

/// 布局配置数据类
class LayoutConfig {
  const LayoutConfig({
    required this.panelLocations,
    required this.activePanels,
  });

  factory LayoutConfig.fromJson(Map<String, dynamic> json) {
    final locations = <String, String>{};
    final rawLocations = json['panelLocations'] as Map<String, dynamic>?;
    if (rawLocations != null) {
      for (final entry in rawLocations.entries) {
        locations[entry.key] = entry.value as String;
      }
    }

    final active = <String, String?>{};
    final rawActive = json['activePanels'] as Map<String, dynamic>?;
    if (rawActive != null) {
      for (final entry in rawActive.entries) {
        active[entry.key] = entry.value as String?;
      }
    }

    return LayoutConfig(panelLocations: locations, activePanels: active);
  }

  /// 面板位置映射 (panelId -> locationName)
  final Map<String, String> panelLocations;

  /// 激活面板映射 (locationName -> panelId)
  final Map<String, String?> activePanels;

  Map<String, dynamic> toJson() {
    return {'panelLocations': panelLocations, 'activePanels': activePanels};
  }
}

/// 解析器状态配置数据类
class ParserStateConfig {
  const ParserStateConfig({required this.isEnabled, this.activeConfigId});

  factory ParserStateConfig.fromJson(Map<String, dynamic> json) {
    return ParserStateConfig(
      isEnabled: json['isEnabled'] as bool? ?? false,
      activeConfigId: json['activeConfigId'] as String?,
    );
  }

  /// 解析器是否启用
  final bool isEnabled;

  /// 当前激活的配置 ID
  final String? activeConfigId;

  Map<String, dynamic> toJson() {
    return {'isEnabled': isEnabled, 'activeConfigId': activeConfigId};
  }
}
