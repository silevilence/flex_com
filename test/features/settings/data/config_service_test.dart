import 'dart:convert';
import 'dart:io';

import 'package:flex_com/features/serial/domain/serial_port_config.dart';
import 'package:flex_com/features/settings/data/config_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConfigService', () {
    late Directory tempDir;
    late String configPath;
    late ConfigService service;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('config_test_');
      configPath = '${tempDir.path}${Platform.pathSeparator}config.json';
      service = ConfigService(configPath: configPath);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('loadConfig', () {
      test('returns null when config file does not exist', () async {
        final config = await service.loadConfig();
        expect(config, isNull);
      });

      test('returns null when config file is empty', () async {
        await File(configPath).writeAsString('');
        final config = await service.loadConfig();
        expect(config, isNull);
      });

      test('returns null when config file has invalid JSON', () async {
        await File(configPath).writeAsString('not valid json');
        final config = await service.loadConfig();
        expect(config, isNull);
      });

      test('returns null when serialPort key is missing', () async {
        await File(configPath).writeAsString('{"otherKey": "value"}');
        final config = await service.loadConfig();
        expect(config, isNull);
      });

      test('loads valid config successfully', () async {
        final json = {
          'serialPort': {
            'portName': 'COM3',
            'baudRate': 115200,
            'dataBits': 8,
            'stopBits': 1,
            'parity': 0,
            'flowControl': 1,
          },
        };
        await File(configPath).writeAsString(jsonEncode(json));

        final config = await service.loadConfig();

        expect(config, isNotNull);
        expect(config!.portName, equals('COM3'));
        expect(config.baudRate, equals(115200));
        expect(config.dataBits, equals(8));
        expect(config.stopBits, equals(1));
        expect(config.parity, equals(Parity.none));
        expect(config.flowControl, equals(FlowControl.hardware));
      });
    });

    group('saveConfig', () {
      test('saves config to file successfully', () async {
        const config = SerialPortConfig(
          portName: 'COM5',
          baudRate: 9600,
          dataBits: 7,
          stopBits: 2,
          parity: Parity.even,
          flowControl: FlowControl.software,
        );

        final success = await service.saveConfig(config);

        expect(success, isTrue);

        final file = File(configPath);
        expect(await file.exists(), isTrue);

        final contents = await file.readAsString();
        final json = jsonDecode(contents) as Map<String, dynamic>;
        final serialPort = json['serialPort'] as Map<String, dynamic>;

        expect(serialPort['portName'], equals('COM5'));
        expect(serialPort['baudRate'], equals(9600));
        expect(serialPort['dataBits'], equals(7));
        expect(serialPort['stopBits'], equals(2));
        expect(serialPort['parity'], equals(2));
        expect(serialPort['flowControl'], equals(2));
      });

      test('preserves other keys when saving', () async {
        // Create initial config with other keys
        final initialJson = {
          'otherSetting': 'preserved value',
          'anotherSetting': 123,
        };
        await File(configPath).writeAsString(jsonEncode(initialJson));

        const config = SerialPortConfig(portName: 'COM1');
        await service.saveConfig(config);

        final contents = await File(configPath).readAsString();
        final json = jsonDecode(contents) as Map<String, dynamic>;

        expect(json['otherSetting'], equals('preserved value'));
        expect(json['anotherSetting'], equals(123));
        expect(json['serialPort'], isNotNull);
      });

      test('overwrites existing serialPort config', () async {
        // Save initial config
        const initialConfig = SerialPortConfig(
          portName: 'COM1',
          baudRate: 9600,
        );
        await service.saveConfig(initialConfig);

        // Save new config
        const newConfig = SerialPortConfig(portName: 'COM5', baudRate: 115200);
        await service.saveConfig(newConfig);

        final loaded = await service.loadConfig();

        expect(loaded!.portName, equals('COM5'));
        expect(loaded.baudRate, equals(115200));
      });
    });

    group('configExists', () {
      test('returns false when file does not exist', () async {
        final exists = await service.configExists();
        expect(exists, isFalse);
      });

      test('returns true when file exists', () async {
        await File(configPath).writeAsString('{}');
        final exists = await service.configExists();
        expect(exists, isTrue);
      });
    });

    group('roundtrip', () {
      test('save then load preserves all config values', () async {
        const original = SerialPortConfig(
          portName: 'COM10',
          baudRate: 921600,
          dataBits: 7,
          stopBits: 2,
          parity: Parity.odd,
          flowControl: FlowControl.dtrDsr,
        );

        await service.saveConfig(original);
        final loaded = await service.loadConfig();

        expect(loaded, equals(original));
      });
    });
  });
}
