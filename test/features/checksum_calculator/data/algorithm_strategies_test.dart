import 'dart:typed_data';

import 'package:flex_com/features/checksum_calculator/data/algorithm_strategies.dart';
import 'package:flex_com/features/checksum_calculator/domain/algorithm_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AlgorithmStrategies', () {
    group('Sum8Strategy', () {
      late Sum8Strategy strategy;

      setUp(() {
        strategy = const Sum8Strategy();
      });

      test('算法类型正确', () {
        expect(strategy.type, equals(AlgorithmTypes.sum8));
      });

      test('空数据返回0', () {
        final data = Uint8List(0);
        final result = strategy.calculate(data);
        expect(result.length, equals(1));
        expect(result[0], equals(0));
      });

      test('单字节数据返回该字节值', () {
        final data = Uint8List.fromList([0x42]);
        final result = strategy.calculate(data);
        expect(result[0], equals(0x42));
      });

      test('多字节求和溢出取低8位', () {
        // 0xFF + 0x02 = 0x101, 取低8位 = 0x01
        final data = Uint8List.fromList([0xFF, 0x02]);
        final result = strategy.calculate(data);
        expect(result[0], equals(0x01));
      });

      test('"Hello" 的 Sum8 值', () {
        // "Hello" = [0x48, 0x65, 0x6C, 0x6C, 0x6F]
        // Sum = 0x48 + 0x65 + 0x6C + 0x6C + 0x6F = 0x1F4
        // 低8位 = 0xF4
        final data = Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]);
        final result = strategy.calculate(data);
        expect(result[0], equals(0xF4));
      });
    });

    group('Sum16Strategy', () {
      late Sum16Strategy strategy;

      setUp(() {
        strategy = const Sum16Strategy();
      });

      test('算法类型正确', () {
        expect(strategy.type, equals(AlgorithmTypes.sum16));
      });

      test('空数据返回0', () {
        final data = Uint8List(0);
        final result = strategy.calculate(data);
        expect(result.length, equals(2));
        expect(result[0], equals(0)); // 高字节
        expect(result[1], equals(0)); // 低字节
      });

      test('"Hello" 的 Sum16 值', () {
        // "Hello" = [0x48, 0x65, 0x6C, 0x6C, 0x6F]
        // Sum = 0x48 + 0x65 + 0x6C + 0x6C + 0x6F = 0x01F4
        final data = Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]);
        final result = strategy.calculate(data);
        expect((result[0] << 8) | result[1], equals(0x01F4));
      });

      test('16位溢出取低16位', () {
        // 大量 0xFF 累加测试溢出
        final data = Uint8List.fromList(List.filled(300, 0xFF));
        // 300 * 255 = 76500 = 0x12AF4, 低16位 = 0x2AF4
        final result = strategy.calculate(data);
        final value = (result[0] << 8) | result[1];
        // 实际计算: 300 * 0xFF = 76500 = 0x12AD4
        // 低16位 = 0x2AD4 = 10964
        expect(value, equals(0x2AD4));
      });
    });

    group('Xor8Strategy', () {
      late Xor8Strategy strategy;

      setUp(() {
        strategy = const Xor8Strategy();
      });

      test('算法类型正确', () {
        expect(strategy.type, equals(AlgorithmTypes.xor8));
      });

      test('空数据返回0', () {
        final data = Uint8List(0);
        final result = strategy.calculate(data);
        expect(result[0], equals(0));
      });

      test('单字节返回该字节', () {
        final data = Uint8List.fromList([0xAB]);
        final result = strategy.calculate(data);
        expect(result[0], equals(0xAB));
      });

      test('多字节异或测试', () {
        // 0x01 ^ 0x02 ^ 0x03 = 0
        final data = Uint8List.fromList([0x01, 0x02, 0x03]);
        final result = strategy.calculate(data);
        expect(result[0], equals(0));
      });

      test('相同字节异或结果为0', () {
        final data = Uint8List.fromList([0xAA, 0xAA]);
        final result = strategy.calculate(data);
        expect(result[0], equals(0));
      });
    });

    group('Crc8Strategy', () {
      late Crc8Strategy strategy;

      setUp(() {
        strategy = const Crc8Strategy();
      });

      test('算法类型正确', () {
        expect(strategy.type, equals(AlgorithmTypes.crc8));
      });

      test('"123456789" 的 CRC-8 标准值', () {
        // 标准测试向量: "123456789" -> CRC-8 = 0xF4
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
        final result = strategy.calculate(data);
        expect(result[0], equals(0xF4));
      });
    });

    group('Crc8MaximStrategy', () {
      late Crc8MaximStrategy strategy;

      setUp(() {
        strategy = const Crc8MaximStrategy();
      });

      test('算法类型正确', () {
        expect(strategy.type, equals(AlgorithmTypes.crc8Maxim));
      });

      test('"123456789" 的 CRC-8/MAXIM 值', () {
        // 标准测试向量: "123456789" -> CRC-8/MAXIM = 0xA1
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
        final result = strategy.calculate(data);
        expect(result[0], equals(0xA1));
      });
    });

    group('Crc16ModbusStrategy', () {
      late Crc16ModbusStrategy strategy;

      setUp(() {
        strategy = const Crc16ModbusStrategy();
      });

      test('算法类型正确', () {
        expect(strategy.type, equals(AlgorithmTypes.crc16Modbus));
      });

      test('空数据返回初始值 0xFFFF', () {
        final data = Uint8List(0);
        final result = strategy.calculate(data);
        final value = (result[0] << 8) | result[1];
        expect(value, equals(0xFFFF));
      });

      test('"123456789" 的 CRC-16/MODBUS 值', () {
        // 标准测试向量: "123456789" -> CRC-16/MODBUS = 0x4B37
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
        final result = strategy.calculate(data);
        final value = (result[0] << 8) | result[1];
        expect(value, equals(0x4B37));
      });

      test('MODBUS 标准测试向量', () {
        // 地址0x01, 功能码0x03, 起始地址0x0000, 寄存器数0x0001
        // CRC16-MODBUS = 0x0A84
        final data = Uint8List.fromList([0x01, 0x03, 0x00, 0x00, 0x00, 0x01]);
        final result = strategy.calculate(data);
        final value = (result[0] << 8) | result[1];
        expect(value, equals(0x0A84));
      });
    });

    group('Crc16CcittStrategy', () {
      late Crc16CcittStrategy strategy;

      setUp(() {
        strategy = const Crc16CcittStrategy();
      });

      test('算法类型正确', () {
        expect(strategy.type, equals(AlgorithmTypes.crc16Ccitt));
      });

      test('"123456789" 的 CRC-16/CCITT-FALSE 值', () {
        // 标准测试向量: "123456789" -> CRC-16/CCITT-FALSE = 0x29B1
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
        final result = strategy.calculate(data);
        final value = (result[0] << 8) | result[1];
        expect(value, equals(0x29B1));
      });
    });

    group('Crc16XModemStrategy', () {
      late Crc16XModemStrategy strategy;

      setUp(() {
        strategy = const Crc16XModemStrategy();
      });

      test('算法类型正确', () {
        expect(strategy.type, equals(AlgorithmTypes.crc16XModem));
      });

      test('"123456789" 的 CRC-16/XMODEM 值', () {
        // 标准测试向量: "123456789" -> CRC-16/XMODEM = 0x31C3
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
        final result = strategy.calculate(data);
        final value = (result[0] << 8) | result[1];
        expect(value, equals(0x31C3));
      });
    });

    group('Crc32Strategy', () {
      late Crc32Strategy strategy;

      setUp(() {
        strategy = const Crc32Strategy();
      });

      test('算法类型正确', () {
        expect(strategy.type, equals(AlgorithmTypes.crc32));
      });

      test('"123456789" 的 CRC-32 值', () {
        // 标准测试向量: "123456789" -> CRC-32 = 0xCBF43926
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
        final result = strategy.calculate(data);
        final value =
            (result[0] << 24) |
            (result[1] << 16) |
            (result[2] << 8) |
            result[3];
        expect(value, equals(0xCBF43926));
      });
    });

    group('Md5Strategy', () {
      late Md5Strategy strategy;

      setUp(() {
        strategy = const Md5Strategy();
      });

      test('算法类型正确', () {
        expect(strategy.type, equals(AlgorithmTypes.md5));
      });

      test('空字符串的 MD5 值', () {
        // MD5("") = d41d8cd98f00b204e9800998ecf8427e
        final data = Uint8List(0);
        final result = strategy.calculate(data);
        final hex = strategy.formatResult(result);
        expect(
          hex.replaceAll(' ', '').toLowerCase(),
          equals('d41d8cd98f00b204e9800998ecf8427e'),
        );
      });

      test('"abc" 的 MD5 值', () {
        // MD5("abc") = 900150983cd24fb0d6963f7d28e17f72
        final data = Uint8List.fromList([0x61, 0x62, 0x63]); // "abc"
        final result = strategy.calculate(data);
        final hex = strategy.formatResult(result);
        expect(
          hex.replaceAll(' ', '').toLowerCase(),
          equals('900150983cd24fb0d6963f7d28e17f72'),
        );
      });
    });

    group('Sha1Strategy', () {
      late Sha1Strategy strategy;

      setUp(() {
        strategy = const Sha1Strategy();
      });

      test('算法类型正确', () {
        expect(strategy.type, equals(AlgorithmTypes.sha1));
      });

      test('"abc" 的 SHA-1 值', () {
        // SHA1("abc") = a9993e364706816aba3e25717850c26c9cd0d89d
        final data = Uint8List.fromList([0x61, 0x62, 0x63]); // "abc"
        final result = strategy.calculate(data);
        final hex = strategy.formatResult(result);
        expect(
          hex.replaceAll(' ', '').toLowerCase(),
          equals('a9993e364706816aba3e25717850c26c9cd0d89d'),
        );
      });
    });

    group('Sha256Strategy', () {
      late Sha256Strategy strategy;

      setUp(() {
        strategy = const Sha256Strategy();
      });

      test('算法类型正确', () {
        expect(strategy.type, equals(AlgorithmTypes.sha256));
      });

      test('"abc" 的 SHA-256 值', () {
        // SHA256("abc") = ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
        final data = Uint8List.fromList([0x61, 0x62, 0x63]); // "abc"
        final result = strategy.calculate(data);
        final hex = strategy.formatResult(result);
        expect(
          hex.replaceAll(' ', '').toLowerCase(),
          equals(
            'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
          ),
        );
      });
    });

    group('AlgorithmRegistry', () {
      test('包含所有预定义算法', () {
        final registry = AlgorithmRegistry();
        for (final type in AlgorithmTypes.all) {
          expect(
            registry.getStrategy(type.id),
            isNotNull,
            reason: '缺少策略: ${type.id}',
          );
        }
      });

      test('未注册的算法返回 null', () {
        final registry = AlgorithmRegistry();
        expect(registry.getStrategy('unknown_algorithm'), isNull);
      });
    });
  });
}
