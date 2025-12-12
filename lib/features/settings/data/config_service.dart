import 'dart:convert';
import 'dart:io';

import '../../serial/domain/serial_port_config.dart';

/// Service for reading and writing user configuration to a JSON file.
///
/// The configuration file is stored in the application's executable directory
/// as `config.json`.
class ConfigService {
  ConfigService({String? configPath}) : _configPath = configPath;

  final String? _configPath;

  /// Gets the path to the configuration file.
  String get configFilePath {
    if (_configPath != null) {
      return _configPath;
    }
    // Get the directory of the running executable
    final executablePath = Platform.resolvedExecutable;
    final executableDir = File(executablePath).parent.path;
    return '$executableDir${Platform.pathSeparator}config.json';
  }

  /// Loads the serial port configuration from the config file.
  ///
  /// Returns null if the file doesn't exist or can't be parsed.
  Future<SerialPortConfig?> loadConfig() async {
    try {
      final file = File(configFilePath);
      if (!await file.exists()) {
        return null;
      }

      final contents = await file.readAsString();
      final json = jsonDecode(contents) as Map<String, dynamic>;

      // Extract serial config from the root or nested structure
      final serialConfig = json['serialPort'] as Map<String, dynamic>?;
      if (serialConfig == null) {
        return null;
      }

      return SerialPortConfig.fromJson(serialConfig);
    } catch (e) {
      // Log error but don't crash - just return null
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
      final file = File(configFilePath);

      // Load existing config to preserve other settings
      Map<String, dynamic> existingConfig = {};
      if (await file.exists()) {
        try {
          final contents = await file.readAsString();
          existingConfig = jsonDecode(contents) as Map<String, dynamic>;
        } catch (_) {
          // Ignore parse errors, start fresh
        }
      }

      // Update serial port config
      existingConfig['serialPort'] = config.toJson();

      // Write back with pretty formatting
      final encoder = const JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(existingConfig));

      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Failed to save config: $e');
      return false;
    }
  }

  /// Checks if a configuration file exists.
  Future<bool> configExists() async {
    final file = File(configFilePath);
    return file.exists();
  }
}
