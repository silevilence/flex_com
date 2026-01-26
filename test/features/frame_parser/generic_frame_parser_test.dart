import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flex_com/features/frame_parser/data/generic_frame_parser.dart';
import 'package:flex_com/features/frame_parser/domain/frame_config.dart';
import 'package:flex_com/features/frame_parser/domain/parser_types.dart';

void main() {
  group('GenericFrameParser', () {
    late GenericFrameParser parser;

    setUp(() {
      parser = const GenericFrameParser();
    });

    group('基本属性', () {
      test('应返回正确的名称和描述', () {
        expect(parser.name, '通用帧解析器');
        expect(parser.description.isNotEmpty, true);
      });
    });

    group('parse() - 基础解析', () {
      test('当未提供配置时应返回错误', () {
        final data = Uint8List.fromList([0x01, 0x02, 0x03]);
        final result = parser.parse(data);

        expect(result.isValid, false);
        expect(result.errorMessage, contains('未提供帧配置'));
      });

      test('当数据长度不足时应返回错误', () {
        final config = const FrameConfig(
          id: 'test',
          name: 'Test',
          minLength: 10,
        );
        final data = Uint8List.fromList([0x01, 0x02, 0x03]);
        final result = parser.parse(data, config: config);

        expect(result.isValid, false);
        expect(result.errorMessage, contains('帧长度不足'));
      });

      test('当数据长度超限时应返回错误', () {
        final config = const FrameConfig(
          id: 'test',
          name: 'Test',
          maxLength: 3,
        );
        final data = Uint8List.fromList([0x01, 0x02, 0x03, 0x04, 0x05]);
        final result = parser.parse(data, config: config);

        expect(result.isValid, false);
        expect(result.errorMessage, contains('帧长度超限'));
      });
    });

    group('parse() - 帧头帧尾验证', () {
      test('帧头匹配时应成功解析', () {
        final config = const FrameConfig(
          id: 'test',
          name: 'Test',
          header: [0xAA, 0x55],
        );
        final data = Uint8List.fromList([0xAA, 0x55, 0x01, 0x02]);
        final result = parser.parse(data, config: config);

        expect(result.isValid, true);
        expect(result.errorMessage, isNull);
      });

      test('帧头不匹配时应返回错误', () {
        final config = const FrameConfig(
          id: 'test',
          name: 'Test',
          header: [0xAA, 0x55],
        );
        final data = Uint8List.fromList([0xBB, 0x55, 0x01, 0x02]);
        final result = parser.parse(data, config: config);

        expect(result.isValid, false);
        expect(result.errorMessage, contains('帧头不匹配'));
      });

      test('帧尾匹配时应成功解析', () {
        final config = const FrameConfig(
          id: 'test',
          name: 'Test',
          footer: [0x0D, 0x0A],
        );
        final data = Uint8List.fromList([0x01, 0x02, 0x0D, 0x0A]);
        final result = parser.parse(data, config: config);

        expect(result.isValid, true);
        expect(result.errorMessage, isNull);
      });

      test('帧尾不匹配时应返回错误', () {
        final config = const FrameConfig(
          id: 'test',
          name: 'Test',
          footer: [0x0D, 0x0A],
        );
        final data = Uint8List.fromList([0x01, 0x02, 0x0D, 0x0B]);
        final result = parser.parse(data, config: config);

        expect(result.isValid, false);
        expect(result.errorMessage, contains('帧尾不匹配'));
      });

      test('同时验证帧头帧尾', () {
        final config = const FrameConfig(
          id: 'test',
          name: 'Test',
          header: [0xAA, 0x55],
          footer: [0x0D, 0x0A],
        );
        final data = Uint8List.fromList([0xAA, 0x55, 0x01, 0x02, 0x0D, 0x0A]);
        final result = parser.parse(data, config: config);

        expect(result.isValid, true);
      });
    });

    group('parse() - 字段解析', () {
      test('应正确解析 UInt8 字段', () {
        final config = FrameConfig(
          id: 'test',
          name: 'Test',
          fields: [
            const FieldDefinition(
              id: 'byte1',
              name: '字节1',
              startByte: 0,
              dataType: DataType.uint8,
            ),
          ],
        );
        final data = Uint8List.fromList([0xFF]);
        final result = parser.parse(data, config: config);

        expect(result.isValid, true);
        expect(result.fields.length, 1);
        expect(result.fields[0].value, 255);
      });

      test('应正确解析 Int8 字段（负数）', () {
        final config = FrameConfig(
          id: 'test',
          name: 'Test',
          fields: [
            const FieldDefinition(
              id: 'byte1',
              name: '字节1',
              startByte: 0,
              dataType: DataType.int8,
            ),
          ],
        );
        final data = Uint8List.fromList([0xFF]); // -1
        final result = parser.parse(data, config: config);

        expect(result.isValid, true);
        expect(result.fields[0].value, -1);
      });

      test('应正确解析 UInt16 字段（大端序）', () {
        final config = FrameConfig(
          id: 'test',
          name: 'Test',
          fields: [
            const FieldDefinition(
              id: 'word1',
              name: '字1',
              startByte: 0,
              dataType: DataType.uint16,
              endianness: Endianness.big,
            ),
          ],
        );
        final data = Uint8List.fromList([0x12, 0x34]); // 0x1234 = 4660
        final result = parser.parse(data, config: config);

        expect(result.isValid, true);
        expect(result.fields[0].value, 0x1234);
      });

      test('应正确解析 UInt16 字段（小端序）', () {
        final config = FrameConfig(
          id: 'test',
          name: 'Test',
          fields: [
            const FieldDefinition(
              id: 'word1',
              name: '字1',
              startByte: 0,
              dataType: DataType.uint16,
              endianness: Endianness.little,
            ),
          ],
        );
        final data = Uint8List.fromList([0x34, 0x12]); // 0x1234 = 4660
        final result = parser.parse(data, config: config);

        expect(result.isValid, true);
        expect(result.fields[0].value, 0x1234);
      });

      test('应正确解析 UInt32 字段（大端序）', () {
        final config = FrameConfig(
          id: 'test',
          name: 'Test',
          fields: [
            const FieldDefinition(
              id: 'dword1',
              name: '双字1',
              startByte: 0,
              dataType: DataType.uint32,
              endianness: Endianness.big,
            ),
          ],
        );
        final data = Uint8List.fromList([0x12, 0x34, 0x56, 0x78]);
        final result = parser.parse(data, config: config);

        expect(result.isValid, true);
        expect(result.fields[0].value, 0x12345678);
      });

      test('应正确解析 Float32 字段', () {
        final config = FrameConfig(
          id: 'test',
          name: 'Test',
          fields: [
            const FieldDefinition(
              id: 'float1',
              name: '浮点1',
              startByte: 0,
              dataType: DataType.float32,
              endianness: Endianness.big,
            ),
          ],
        );
        // IEEE 754: 3.14 ≈ 0x4048F5C3
        final data = Uint8List.fromList([0x40, 0x48, 0xF5, 0xC3]);
        final result = parser.parse(data, config: config);

        expect(result.isValid, true);
        expect((result.fields[0].value as double).toStringAsFixed(2), '3.14');
      });

      test('应正确解析 ASCII 字符串字段', () {
        final config = FrameConfig(
          id: 'test',
          name: 'Test',
          fields: [
            const FieldDefinition(
              id: 'str1',
              name: '字符串1',
              startByte: 0,
              dataType: DataType.ascii,
              length: 5,
            ),
          ],
        );
        final data = Uint8List.fromList([
          0x48,
          0x65,
          0x6C,
          0x6C,
          0x6F,
        ]); // "Hello"
        final result = parser.parse(data, config: config);

        expect(result.isValid, true);
        expect(result.fields[0].value, 'Hello');
      });

      test('应正确解析 Bytes 字段', () {
        final config = FrameConfig(
          id: 'test',
          name: 'Test',
          fields: [
            const FieldDefinition(
              id: 'bytes1',
              name: '字节数组1',
              startByte: 0,
              dataType: DataType.bytes,
              length: 4,
            ),
          ],
        );
        final data = Uint8List.fromList([0x01, 0x02, 0x03, 0x04]);
        final result = parser.parse(data, config: config);

        expect(result.isValid, true);
        expect(result.fields[0].value, [0x01, 0x02, 0x03, 0x04]);
        expect(result.fields[0].displayValue, '01 02 03 04');
      });
    });

    group('parse() - 位域解析', () {
      test('应正确提取位域（使用掩码）', () {
        final config = FrameConfig(
          id: 'test',
          name: 'Test',
          fields: [
            const FieldDefinition(
              id: 'flags',
              name: '标志位高4位',
              startByte: 0,
              dataType: DataType.uint8,
              bitMask: 0xF0,
              bitOffset: 4,
            ),
          ],
        );
        final data = Uint8List.fromList([0xA5]); // 高4位为 0xA = 10
        final result = parser.parse(data, config: config);

        expect(result.isValid, true);
        expect(result.fields[0].value, 0x0A);
      });

      test('应正确提取位域（低4位）', () {
        final config = FrameConfig(
          id: 'test',
          name: 'Test',
          fields: [
            const FieldDefinition(
              id: 'flags',
              name: '标志位低4位',
              startByte: 0,
              dataType: DataType.uint8,
              bitMask: 0x0F,
            ),
          ],
        );
        final data = Uint8List.fromList([0xA5]); // 低4位为 0x5 = 5
        final result = parser.parse(data, config: config);

        expect(result.isValid, true);
        expect(result.fields[0].value, 0x05);
      });

      test('应正确提取单个位', () {
        final config = FrameConfig(
          id: 'test',
          name: 'Test',
          fields: [
            const FieldDefinition(
              id: 'bit7',
              name: '第7位',
              startByte: 0,
              dataType: DataType.uint8,
              bitMask: 0x80,
              bitOffset: 7,
            ),
          ],
        );
        final data = Uint8List.fromList([0x80]); // bit7 = 1
        final result = parser.parse(data, config: config);

        expect(result.isValid, true);
        expect(result.fields[0].value, 1);
      });
    });

    group('parse() - 比例因子和偏移量', () {
      test('应正确应用比例因子', () {
        final config = FrameConfig(
          id: 'test',
          name: 'Test',
          fields: [
            const FieldDefinition(
              id: 'temp',
              name: '温度',
              startByte: 0,
              dataType: DataType.uint8,
              scaleFactor: 0.5,
              unit: '°C',
            ),
          ],
        );
        final data = Uint8List.fromList([100]); // 100 * 0.5 = 50
        final result = parser.parse(data, config: config);

        expect(result.isValid, true);
        expect(result.fields[0].displayValue, '50 °C');
      });

      test('应正确应用偏移量', () {
        final config = FrameConfig(
          id: 'test',
          name: 'Test',
          fields: [
            const FieldDefinition(
              id: 'temp',
              name: '温度',
              startByte: 0,
              dataType: DataType.uint8,
              offset: -40,
              unit: '°C',
            ),
          ],
        );
        final data = Uint8List.fromList([60]); // 60 - 40 = 20
        final result = parser.parse(data, config: config);

        expect(result.isValid, true);
        expect(result.fields[0].displayValue, '20 °C');
      });

      test('应正确同时应用比例因子和偏移量', () {
        final config = FrameConfig(
          id: 'test',
          name: 'Test',
          fields: [
            const FieldDefinition(
              id: 'temp',
              name: '温度',
              startByte: 0,
              dataType: DataType.uint16,
              endianness: Endianness.big,
              scaleFactor: 0.1,
              offset: -40,
              unit: '°C',
            ),
          ],
        );
        final data = Uint8List.fromList([0x01, 0xF4]); // 500 * 0.1 - 40 = 10
        final result = parser.parse(data, config: config);

        expect(result.isValid, true);
        expect(result.fields[0].displayValue, '10 °C');
      });
    });

    group('parse() - 校验验证', () {
      test('Sum8 校验应正确验证', () {
        // 数据: [0x01, 0x02, 0x03], Sum8 = 0x06
        final config = const FrameConfig(
          id: 'test',
          name: 'Test',
          checksumType: ChecksumType.sum8,
          checksumStartByte: 0,
        );
        final data = Uint8List.fromList([0x01, 0x02, 0x03, 0x06]);
        final result = parser.parse(data, config: config);

        expect(result.isValid, true);
        expect(result.checksumValid, true);
      });

      test('Sum8 校验失败时应报告', () {
        final config = const FrameConfig(
          id: 'test',
          name: 'Test',
          checksumType: ChecksumType.sum8,
          checksumStartByte: 0,
        );
        final data = Uint8List.fromList([0x01, 0x02, 0x03, 0xFF]); // 错误校验
        final result = parser.parse(data, config: config);

        expect(result.isValid, false);
        expect(result.checksumValid, false);
        expect(result.errorMessage, contains('校验失败'));
      });

      test('XOR8 校验应正确验证', () {
        // 数据: [0x01, 0x02, 0x03], XOR8 = 0x00
        final config = const FrameConfig(
          id: 'test',
          name: 'Test',
          checksumType: ChecksumType.xor8,
          checksumStartByte: 0,
        );
        final data = Uint8List.fromList([0x01, 0x02, 0x03, 0x00]);
        final result = parser.parse(data, config: config);

        expect(result.isValid, true);
        expect(result.checksumValid, true);
      });

      test('CRC16-MODBUS 校验应正确验证', () {
        // Modbus 帧: 地址=0x01, 功能码=0x03, 寄存器=0x0000, 数量=0x0001
        // CRC16-MODBUS = 0x840A (小端序: 0x0A, 0x84)
        final config = const FrameConfig(
          id: 'test',
          name: 'Test',
          checksumType: ChecksumType.crc16Modbus,
          checksumStartByte: 0,
          checksumEndianness: Endianness.little,
        );
        final data = Uint8List.fromList([
          0x01,
          0x03,
          0x00,
          0x00,
          0x00,
          0x01,
          0x84,
          0x0A,
        ]);
        final result = parser.parse(data, config: config);

        expect(result.isValid, true);
        expect(result.checksumValid, true);
      });
    });

    group('parse() - 多字段解析', () {
      test('应正确解析多个字段', () {
        final config = FrameConfig(
          id: 'test',
          name: 'Test',
          header: [0xAA],
          fields: [
            const FieldDefinition(
              id: 'cmd',
              name: '命令码',
              startByte: 1,
              dataType: DataType.uint8,
            ),
            const FieldDefinition(
              id: 'len',
              name: '长度',
              startByte: 2,
              dataType: DataType.uint8,
            ),
            const FieldDefinition(
              id: 'data',
              name: '数据',
              startByte: 3,
              dataType: DataType.uint16,
              endianness: Endianness.big,
            ),
          ],
        );
        final data = Uint8List.fromList([0xAA, 0x01, 0x02, 0x12, 0x34]);
        final result = parser.parse(data, config: config);

        expect(result.isValid, true);
        expect(result.fields.length, 3);
        expect(result.getField('cmd')?.value, 0x01);
        expect(result.getField('len')?.value, 0x02);
        expect(result.getField('data')?.value, 0x1234);
      });

      test('toMap() 应返回正确的键值对', () {
        final config = FrameConfig(
          id: 'test',
          name: 'Test',
          fields: [
            const FieldDefinition(
              id: 'a',
              name: 'A',
              startByte: 0,
              dataType: DataType.uint8,
            ),
            const FieldDefinition(
              id: 'b',
              name: 'B',
              startByte: 1,
              dataType: DataType.uint8,
            ),
          ],
        );
        final data = Uint8List.fromList([0x10, 0x20]);
        final result = parser.parse(data, config: config);

        final map = result.toMap();
        expect(map['a'], 0x10);
        expect(map['b'], 0x20);
      });
    });

    group('validate()', () {
      test('有效帧应返回 true', () {
        final config = const FrameConfig(
          id: 'test',
          name: 'Test',
          header: [0xAA],
        );
        final data = Uint8List.fromList([0xAA, 0x01, 0x02]);

        expect(parser.validate(data, config), true);
      });

      test('无效帧应返回 false', () {
        final config = const FrameConfig(
          id: 'test',
          name: 'Test',
          header: [0xAA],
        );
        final data = Uint8List.fromList([0xBB, 0x01, 0x02]);

        expect(parser.validate(data, config), false);
      });
    });

    group('findFrame()', () {
      test('应在缓冲区中找到帧', () {
        final config = const FrameConfig(
          id: 'test',
          name: 'Test',
          header: [0xAA, 0x55],
          footer: [0x0D, 0x0A],
        );
        // 缓冲区中有一个完整帧
        final buffer = Uint8List.fromList([
          0x00, 0x00, // 噪声
          0xAA, 0x55, 0x01, 0x02, 0x0D, 0x0A, // 帧
          0x00, // 噪声
        ]);

        final found = parser.findFrame(buffer, config);

        expect(found, isNotNull);
        expect(found!.start, 2);
        expect(found.end, 8);
      });

      test('当没有帧头时应返回 null', () {
        final config = const FrameConfig(
          id: 'test',
          name: 'Test',
          footer: [0x0D, 0x0A],
        );
        final buffer = Uint8List.fromList([0x01, 0x02, 0x0D, 0x0A]);

        final found = parser.findFrame(buffer, config);

        expect(found, isNull);
      });

      test('当帧不完整时应返回 null', () {
        final config = const FrameConfig(
          id: 'test',
          name: 'Test',
          header: [0xAA, 0x55],
          footer: [0x0D, 0x0A],
        );
        // 帧头存在但没有帧尾
        final buffer = Uint8List.fromList([0xAA, 0x55, 0x01, 0x02]);

        final found = parser.findFrame(buffer, config);

        expect(found, isNull);
      });
    });
  });

  group('FrameConfig', () {
    test('toJson/fromJson 应正确序列化和反序列化', () {
      const original = FrameConfig(
        id: 'test',
        name: 'Test Protocol',
        description: '测试协议',
        header: [0xAA, 0x55],
        footer: [0x0D, 0x0A],
        checksumType: ChecksumType.crc16Modbus,
        checksumStartByte: 2,
        checksumEndianness: Endianness.little,
        fields: [
          FieldDefinition(
            id: 'field1',
            name: '字段1',
            startByte: 2,
            dataType: DataType.uint16,
            endianness: Endianness.big,
            description: '测试字段',
            unit: 'mV',
            scaleFactor: 0.1,
          ),
        ],
        minLength: 10,
        maxLength: 100,
      );

      final json = original.toJson();
      final restored = FrameConfig.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.description, original.description);
      expect(restored.header, original.header);
      expect(restored.footer, original.footer);
      expect(restored.checksumType, original.checksumType);
      expect(restored.checksumStartByte, original.checksumStartByte);
      expect(restored.checksumEndianness, original.checksumEndianness);
      expect(restored.fields.length, original.fields.length);
      expect(restored.fields[0].id, original.fields[0].id);
      expect(restored.fields[0].scaleFactor, original.fields[0].scaleFactor);
      expect(restored.minLength, original.minLength);
      expect(restored.maxLength, original.maxLength);
    });
  });

  group('FieldDefinition', () {
    test('byteLength 应根据数据类型返回正确的长度', () {
      expect(
        const FieldDefinition(
          id: '',
          name: '',
          startByte: 0,
          dataType: DataType.uint8,
        ).byteLength,
        1,
      );
      expect(
        const FieldDefinition(
          id: '',
          name: '',
          startByte: 0,
          dataType: DataType.uint16,
        ).byteLength,
        2,
      );
      expect(
        const FieldDefinition(
          id: '',
          name: '',
          startByte: 0,
          dataType: DataType.uint32,
        ).byteLength,
        4,
      );
      expect(
        const FieldDefinition(
          id: '',
          name: '',
          startByte: 0,
          dataType: DataType.float32,
        ).byteLength,
        4,
      );
      expect(
        const FieldDefinition(
          id: '',
          name: '',
          startByte: 0,
          dataType: DataType.float64,
        ).byteLength,
        8,
      );
      expect(
        const FieldDefinition(
          id: '',
          name: '',
          startByte: 0,
          dataType: DataType.bytes,
          length: 10,
        ).byteLength,
        10,
      );
      expect(
        const FieldDefinition(
          id: '',
          name: '',
          startByte: 0,
          dataType: DataType.ascii,
          length: 5,
        ).byteLength,
        5,
      );
    });

    test('isBitField 应正确识别位域字段', () {
      expect(
        const FieldDefinition(
          id: '',
          name: '',
          startByte: 0,
          dataType: DataType.uint8,
        ).isBitField,
        false,
      );
      expect(
        const FieldDefinition(
          id: '',
          name: '',
          startByte: 0,
          dataType: DataType.uint8,
          bitMask: 0xF0,
        ).isBitField,
        true,
      );
    });
  });

  group('FrameConfigTemplates', () {
    test('Modbus RTU 模板应有正确的配置', () {
      final config = FrameConfigTemplates.modbusRtu();

      expect(config.checksumType, ChecksumType.crc16Modbus);
      expect(config.checksumEndianness, Endianness.little);
      expect(config.fields.length, greaterThan(0));
    });

    test('简单帧头帧尾模板应有正确的配置', () {
      final config = FrameConfigTemplates.simpleHeaderFooter();

      expect(config.header, [0xAA, 0x55]);
      expect(config.footer, [0x0D, 0x0A]);
      expect(config.checksumType, ChecksumType.sum8);
    });
  });
}
