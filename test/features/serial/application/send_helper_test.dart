import 'dart:typed_data';

import 'package:flex_com/features/serial/application/send_helper_providers.dart';
import 'package:flex_com/features/serial/domain/send_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('processSendData', () {
    test('无设置时返回原始数据', () {
      final data = Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]);
      const settings = SendSettings();

      final result = processSendData(data, settings);
      expect(result, equals(data));
    });

    test('追加换行符', () {
      final data = Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]);
      const settings = SendSettings(appendNewline: true);

      final result = processSendData(data, settings);
      expect(result.length, equals(7));
      expect(result.sublist(0, 5), equals(data));
      expect(result[5], equals(0x0D)); // \r
      expect(result[6], equals(0x0A)); // \n
    });

    test('追加 Checksum8', () {
      final data = Uint8List.fromList([0x01, 0x02, 0x03]);
      const settings = SendSettings(checksumType: ChecksumType.checksum8);

      final result = processSendData(data, settings);
      expect(result.length, equals(4));
      expect(result.sublist(0, 3), equals(data));
      expect(result[3], equals(0x06)); // 1 + 2 + 3 = 6
    });

    test('追加 CRC16', () {
      final data = Uint8List.fromList([0x01, 0x03, 0x00, 0x00, 0x00, 0x01]);
      const settings = SendSettings(checksumType: ChecksumType.crc16Modbus);

      final result = processSendData(data, settings);
      expect(result.length, equals(8));
      expect(result.sublist(0, 6), equals(data));
      // CRC = 0x0A84, 低字节在前
      expect(result[6], equals(0x84));
      expect(result[7], equals(0x0A));
    });

    test('同时追加换行符和校验和', () {
      final data = Uint8List.fromList([0x48, 0x49]); // "HI"
      const settings = SendSettings(
        appendNewline: true,
        checksumType: ChecksumType.checksum8,
      );

      final result = processSendData(data, settings);
      // 原始数据(2) + 换行符(2) + 校验和(1) = 5 字节
      expect(result.length, equals(5));

      // 原始数据
      expect(result[0], equals(0x48));
      expect(result[1], equals(0x49));
      // 换行符
      expect(result[2], equals(0x0D));
      expect(result[3], equals(0x0A));
      // 校验和: 0x48 + 0x49 + 0x0D + 0x0A = 168 = 0xA8
      expect(result[4], equals(0xA8));
    });

    test('空数据处理', () {
      final data = Uint8List(0);
      const settings = SendSettings(
        appendNewline: true,
        checksumType: ChecksumType.checksum8,
      );

      final result = processSendData(data, settings);
      // 换行符(2) + 校验和(1) = 3 字节
      expect(result.length, equals(3));
      expect(result[0], equals(0x0D));
      expect(result[1], equals(0x0A));
      // 校验和: 0x0D + 0x0A = 0x17
      expect(result[2], equals(0x17));
    });
  });
}
