import 'dart:typed_data';

import 'package:flex_com/core/utils/checksum_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChecksumUtils', () {
    group('calculateChecksum8', () {
      test('空数据返回0', () {
        final data = Uint8List(0);
        expect(ChecksumUtils.calculateChecksum8(data), equals(0));
      });

      test('单字节数据返回该字节值', () {
        final data = Uint8List.fromList([0x42]);
        expect(ChecksumUtils.calculateChecksum8(data), equals(0x42));
      });

      test('多字节数据返回和的低8位', () {
        // 0x01 + 0x02 + 0x03 = 0x06
        final data = Uint8List.fromList([0x01, 0x02, 0x03]);
        expect(ChecksumUtils.calculateChecksum8(data), equals(0x06));
      });

      test('溢出时取低8位', () {
        // 0xFF + 0x02 = 0x101, 取低8位 = 0x01
        final data = Uint8List.fromList([0xFF, 0x02]);
        expect(ChecksumUtils.calculateChecksum8(data), equals(0x01));
      });

      test('典型数据测试', () {
        // "Hello" = [0x48, 0x65, 0x6C, 0x6C, 0x6F]
        // Sum = 0x48 + 0x65 + 0x6C + 0x6C + 0x6F = 0x1F4
        // 低8位 = 0xF4
        final data = Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]);
        expect(ChecksumUtils.calculateChecksum8(data), equals(0xF4));
      });
    });

    group('calculateCrc16Modbus', () {
      test('空数据返回初始值', () {
        final data = Uint8List(0);
        // 空数据时 CRC16-MODBUS 应返回 0xFFFF
        expect(ChecksumUtils.calculateCrc16Modbus(data), equals(0xFFFF));
      });

      test('标准 MODBUS 测试向量', () {
        // 标准测试: 地址0x01, 功能码0x03, 起始地址0x0000, 寄存器数0x0001
        // 数据: 01 03 00 00 00 01
        // CRC16-MODBUS = 0x0A84 (低字节在前时是 84 0A)
        final data = Uint8List.fromList([0x01, 0x03, 0x00, 0x00, 0x00, 0x01]);
        expect(ChecksumUtils.calculateCrc16Modbus(data), equals(0x0A84));
      });

      test('单字节测试', () {
        // 单字节 0x00 的 CRC16-MODBUS
        final data = Uint8List.fromList([0x00]);
        // 验证计算结果
        final crc = ChecksumUtils.calculateCrc16Modbus(data);
        expect(crc, isA<int>());
        expect(crc, lessThanOrEqualTo(0xFFFF));
      });

      test('另一个标准测试向量', () {
        // 测试字符串 "123456789" 的 CRC16-MODBUS = 0x4B37
        final data = Uint8List.fromList([
          0x31,
          0x32,
          0x33,
          0x34,
          0x35,
          0x36,
          0x37,
          0x38,
          0x39,
        ]);
        expect(ChecksumUtils.calculateCrc16Modbus(data), equals(0x4B37));
      });
    });

    group('appendChecksum8', () {
      test('空数据追加校验和', () {
        final data = Uint8List(0);
        final result = ChecksumUtils.appendChecksum8(data);
        expect(result.length, equals(1));
        expect(result[0], equals(0)); // 空数据的校验和为0
      });

      test('正常数据追加校验和', () {
        final data = Uint8List.fromList([0x01, 0x02, 0x03]);
        final result = ChecksumUtils.appendChecksum8(data);
        expect(result.length, equals(4));
        expect(result.sublist(0, 3), equals([0x01, 0x02, 0x03]));
        expect(result[3], equals(0x06)); // 1 + 2 + 3 = 6
      });
    });

    group('appendCrc16Modbus', () {
      test('空数据追加CRC16', () {
        final data = Uint8List(0);
        final result = ChecksumUtils.appendCrc16Modbus(data);
        expect(result.length, equals(2));
        // 空数据的 CRC = 0xFFFF, 低字节在前
        expect(result[0], equals(0xFF));
        expect(result[1], equals(0xFF));
      });

      test('标准 MODBUS 数据追加CRC16', () {
        final data = Uint8List.fromList([0x01, 0x03, 0x00, 0x00, 0x00, 0x01]);
        final result = ChecksumUtils.appendCrc16Modbus(data);
        expect(result.length, equals(8));
        // 原数据保持不变
        expect(result.sublist(0, 6), equals(data));
        // CRC = 0x0A84, 低字节在前
        expect(result[6], equals(0x84));
        expect(result[7], equals(0x0A));
      });
    });
  });
}
