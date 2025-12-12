import 'package:riverpod_annotation/riverpod_annotation.dart';

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
