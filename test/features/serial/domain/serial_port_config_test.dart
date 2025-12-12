import 'package:flex_com/features/serial/domain/serial_port_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SerialPortConfig', () {
    group('constructor', () {
      test(
        'should create config with required portName and default values',
        () {
          const config = SerialPortConfig(portName: 'COM1');

          expect(config.portName, 'COM1');
          expect(config.baudRate, 9600);
          expect(config.dataBits, 8);
          expect(config.stopBits, 1);
          expect(config.parity, Parity.none);
          expect(config.flowControl, FlowControl.none);
        },
      );

      test('should create config with custom values', () {
        const config = SerialPortConfig(
          portName: 'COM3',
          baudRate: 115200,
          dataBits: 7,
          stopBits: 2,
          parity: Parity.even,
          flowControl: FlowControl.hardware,
        );

        expect(config.portName, 'COM3');
        expect(config.baudRate, 115200);
        expect(config.dataBits, 7);
        expect(config.stopBits, 2);
        expect(config.parity, Parity.even);
        expect(config.flowControl, FlowControl.hardware);
      });
    });

    group('withDefaults factory', () {
      test('should create config with default values for given port', () {
        final config = SerialPortConfig.withDefaults('COM5');

        expect(config.portName, 'COM5');
        expect(config.baudRate, 9600);
        expect(config.dataBits, 8);
        expect(config.stopBits, 1);
        expect(config.parity, Parity.none);
        expect(config.flowControl, FlowControl.none);
      });
    });

    group('copyWith', () {
      test('should create a copy with updated baudRate', () {
        const original = SerialPortConfig(portName: 'COM1');
        final updated = original.copyWith(baudRate: 115200);

        expect(updated.portName, 'COM1');
        expect(updated.baudRate, 115200);
        expect(updated.dataBits, 8);
        expect(updated.stopBits, 1);
        expect(updated.parity, Parity.none);
        expect(updated.flowControl, FlowControl.none);
      });

      test('should create a copy with multiple updated fields', () {
        const original = SerialPortConfig(portName: 'COM1');
        final updated = original.copyWith(
          portName: 'COM2',
          baudRate: 38400,
          parity: Parity.odd,
          flowControl: FlowControl.software,
        );

        expect(updated.portName, 'COM2');
        expect(updated.baudRate, 38400);
        expect(updated.dataBits, 8);
        expect(updated.stopBits, 1);
        expect(updated.parity, Parity.odd);
        expect(updated.flowControl, FlowControl.software);
      });

      test('should not modify original config when copying', () {
        const original = SerialPortConfig(portName: 'COM1', baudRate: 9600);
        final copy = original.copyWith(baudRate: 115200);

        expect(original.baudRate, 9600);
        expect(copy.baudRate, 115200);
      });
    });

    group('equality', () {
      test('should be equal when all fields are the same', () {
        const config1 = SerialPortConfig(portName: 'COM1', baudRate: 9600);
        const config2 = SerialPortConfig(portName: 'COM1', baudRate: 9600);

        expect(config1, equals(config2));
        expect(config1.hashCode, equals(config2.hashCode));
      });

      test('should not be equal when fields differ', () {
        const config1 = SerialPortConfig(portName: 'COM1', baudRate: 9600);
        const config2 = SerialPortConfig(portName: 'COM1', baudRate: 115200);

        expect(config1, isNot(equals(config2)));
      });

      test('should not be equal when flowControl differs', () {
        const config1 = SerialPortConfig(
          portName: 'COM1',
          flowControl: FlowControl.none,
        );
        const config2 = SerialPortConfig(
          portName: 'COM1',
          flowControl: FlowControl.hardware,
        );

        expect(config1, isNot(equals(config2)));
      });
    });

    group('static constants', () {
      test('commonBaudRates should contain standard baud rates', () {
        expect(SerialPortConfig.commonBaudRates, contains(9600));
        expect(SerialPortConfig.commonBaudRates, contains(115200));
        expect(SerialPortConfig.commonBaudRates.length, greaterThan(5));
      });

      test('commonDataBits should contain 5, 6, 7, 8', () {
        expect(SerialPortConfig.commonDataBits, [5, 6, 7, 8]);
      });

      test('commonStopBits should contain 1, 2', () {
        expect(SerialPortConfig.commonStopBits, [1, 2]);
      });
    });
  });

  group('Parity enum', () {
    test('should have correct integer values', () {
      expect(Parity.none.value, 0);
      expect(Parity.odd.value, 1);
      expect(Parity.even.value, 2);
      expect(Parity.mark.value, 3);
      expect(Parity.space.value, 4);
    });

    test('should have correct display names', () {
      expect(Parity.none.displayName, 'None');
      expect(Parity.odd.displayName, 'Odd');
      expect(Parity.even.displayName, 'Even');
      expect(Parity.mark.displayName, 'Mark');
      expect(Parity.space.displayName, 'Space');
    });
  });

  group('FlowControl enum', () {
    test('should have correct integer values', () {
      expect(FlowControl.none.value, 0);
      expect(FlowControl.hardware.value, 1);
      expect(FlowControl.software.value, 2);
    });

    test('should have correct display names', () {
      expect(FlowControl.none.displayName, 'None');
      expect(FlowControl.hardware.displayName, 'RTS/CTS');
      expect(FlowControl.software.displayName, 'XON/XOFF');
    });
  });

  group('JSON serialization', () {
    test('toJson creates correct map', () {
      const config = SerialPortConfig(
        portName: 'COM3',
        baudRate: 115200,
        dataBits: 8,
        stopBits: 1,
        parity: Parity.none,
        flowControl: FlowControl.hardware,
      );

      final json = config.toJson();

      expect(json['portName'], equals('COM3'));
      expect(json['baudRate'], equals(115200));
      expect(json['dataBits'], equals(8));
      expect(json['stopBits'], equals(1));
      expect(json['parity'], equals(0));
      expect(json['flowControl'], equals(1));
    });

    test('fromJson creates correct config', () {
      final json = {
        'portName': 'COM5',
        'baudRate': 9600,
        'dataBits': 7,
        'stopBits': 2,
        'parity': 2,
        'flowControl': 2,
      };

      final config = SerialPortConfig.fromJson(json);

      expect(config.portName, equals('COM5'));
      expect(config.baudRate, equals(9600));
      expect(config.dataBits, equals(7));
      expect(config.stopBits, equals(2));
      expect(config.parity, equals(Parity.even));
      expect(config.flowControl, equals(FlowControl.software));
    });

    test('fromJson uses defaults for missing fields', () {
      final json = <String, dynamic>{'portName': 'COM1'};

      final config = SerialPortConfig.fromJson(json);

      expect(config.portName, equals('COM1'));
      expect(config.baudRate, equals(9600));
      expect(config.dataBits, equals(8));
      expect(config.stopBits, equals(1));
      expect(config.parity, equals(Parity.none));
      expect(config.flowControl, equals(FlowControl.none));
    });

    test('fromJson handles null portName', () {
      final json = <String, dynamic>{};

      final config = SerialPortConfig.fromJson(json);

      expect(config.portName, equals(''));
    });

    test('fromJson handles invalid parity value', () {
      final json = {'portName': 'COM1', 'parity': 99};

      final config = SerialPortConfig.fromJson(json);

      expect(config.parity, equals(Parity.none));
    });

    test('fromJson handles invalid flowControl value', () {
      final json = {'portName': 'COM1', 'flowControl': 99};

      final config = SerialPortConfig.fromJson(json);

      expect(config.flowControl, equals(FlowControl.none));
    });

    test('roundtrip serialization preserves data', () {
      const original = SerialPortConfig(
        portName: 'COM10',
        baudRate: 921600,
        dataBits: 7,
        stopBits: 2,
        parity: Parity.odd,
        flowControl: FlowControl.dtrDsr,
      );

      final json = original.toJson();
      final restored = SerialPortConfig.fromJson(json);

      expect(restored, equals(original));
    });

    test('all parity values can be serialized', () {
      for (final parity in Parity.values) {
        final config = SerialPortConfig(portName: 'COM1', parity: parity);
        final json = config.toJson();
        final restored = SerialPortConfig.fromJson(json);
        expect(restored.parity, equals(parity));
      }
    });

    test('all flowControl values can be serialized', () {
      for (final fc in FlowControl.values) {
        final config = SerialPortConfig(portName: 'COM1', flowControl: fc);
        final json = config.toJson();
        final restored = SerialPortConfig.fromJson(json);
        expect(restored.flowControl, equals(fc));
      }
    });
  });
}
