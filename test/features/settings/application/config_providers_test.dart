import 'dart:convert';
import 'dart:io';

import 'package:flex_com/features/serial/domain/serial_port_config.dart';
import 'package:flex_com/features/settings/application/config_providers.dart';
import 'package:flex_com/features/settings/data/config_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Config Loading Integration', () {
    late Directory tempDir;
    late String configPath;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('config_integration_');
      configPath = '${tempDir.path}${Platform.pathSeparator}config.json';
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('ConfigService loads config correctly', () async {
      // Create config file
      final configData = {
        'serialPort': {
          'portName': 'COM5',
          'baudRate': 115200,
          'dataBits': 8,
          'stopBits': 1,
          'parity': 0,
          'flowControl': 1,
        },
      };
      await File(configPath).writeAsString(jsonEncode(configData));

      // Load with service
      final service = ConfigService(configPath: configPath);
      final config = await service.loadConfig();

      expect(config, isNotNull);
      expect(config!.portName, equals('COM5'));
      expect(config.baudRate, equals(115200));
      expect(config.flowControl, equals(FlowControl.hardware));
    });

    test('Provider loads config through service', () async {
      // Create config file
      final configData = {
        'serialPort': {
          'portName': 'COM3',
          'baudRate': 9600,
          'dataBits': 8,
          'stopBits': 1,
          'parity': 2,
          'flowControl': 0,
        },
      };
      await File(configPath).writeAsString(jsonEncode(configData));

      // Create container with overridden service
      final container = ProviderContainer(
        overrides: [
          configServiceProvider.overrideWithValue(
            ConfigService(configPath: configPath),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Read the async provider
      final future = container.read(savedConfigProvider.future);
      final config = await future;

      expect(config, isNotNull);
      expect(config!.portName, equals('COM3'));
      expect(config.baudRate, equals(9600));
      expect(config.parity, equals(Parity.even));
    });

    test('Provider returns null when no config file exists', () async {
      final container = ProviderContainer(
        overrides: [
          configServiceProvider.overrideWithValue(
            ConfigService(configPath: configPath),
          ),
        ],
      );
      addTearDown(container.dispose);

      final future = container.read(savedConfigProvider.future);
      final config = await future;

      expect(config, isNull);
    });
  });
}
