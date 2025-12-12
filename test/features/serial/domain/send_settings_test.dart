import 'package:flex_com/features/serial/domain/send_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SendSettings', () {
    test('默认值正确', () {
      const settings = SendSettings();
      expect(settings.appendNewline, isFalse);
      expect(settings.checksumType, equals(ChecksumType.none));
      expect(settings.cyclicSendEnabled, isFalse);
      expect(settings.cyclicIntervalMs, equals(1000));
    });

    test('copyWith 复制所有属性', () {
      const original = SendSettings(
        appendNewline: true,
        checksumType: ChecksumType.crc16Modbus,
        cyclicSendEnabled: true,
        cyclicIntervalMs: 500,
      );

      final copied = original.copyWith();
      expect(copied.appendNewline, isTrue);
      expect(copied.checksumType, equals(ChecksumType.crc16Modbus));
      expect(copied.cyclicSendEnabled, isTrue);
      expect(copied.cyclicIntervalMs, equals(500));
    });

    test('copyWith 可以修改单个属性', () {
      const original = SendSettings();

      final modified = original.copyWith(appendNewline: true);
      expect(modified.appendNewline, isTrue);
      expect(modified.checksumType, equals(ChecksumType.none));
      expect(modified.cyclicSendEnabled, isFalse);
      expect(modified.cyclicIntervalMs, equals(1000));
    });

    test('相同属性的对象相等', () {
      const settings1 = SendSettings(appendNewline: true);
      const settings2 = SendSettings(appendNewline: true);
      expect(settings1, equals(settings2));
    });

    test('不同属性的对象不相等', () {
      const settings1 = SendSettings(appendNewline: true);
      const settings2 = SendSettings(appendNewline: false);
      expect(settings1, isNot(equals(settings2)));
    });
  });

  group('ChecksumType', () {
    test('displayName 返回正确的显示名称', () {
      expect(ChecksumType.none.displayName, equals('无'));
      expect(ChecksumType.checksum8.displayName, equals('Checksum'));
      expect(ChecksumType.crc16Modbus.displayName, equals('CRC16'));
    });
  });
}
