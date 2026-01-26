import 'dart:typed_data';

import 'package:flex_com/features/frame_parser/domain/frame_config.dart';
import 'package:flex_com/features/frame_parser/domain/parser_types.dart';
import 'package:flex_com/features/frame_parser/domain/protocol_parser.dart';
import 'package:flex_com/features/visualization/domain/chart_types.dart';
import 'package:flex_com/features/visualization/domain/oscilloscope_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('数据流核心逻辑测试', () {
    test('fieldId 格式解析测试', () {
      // 测试 fieldId 格式解析
      const fieldId = 'configId:fieldId';
      final parts = fieldId.split(':');

      expect(parts.length, equals(2));
      expect(parts[0], equals('configId'));
      expect(parts[1], equals('fieldId'));
    });

    test('ParsedFrame.getField 应该能正确获取字段', () {
      const config = FrameConfig(
        id: 'testConfig',
        name: 'Test Config',
        fields: [
          FieldDefinition(
            id: 'testField',
            name: 'Test Field',
            dataType: DataType.int16,
            startByte: 0,
          ),
        ],
      );

      final parsedFrame = ParsedFrame(
        config: config,
        rawData: Uint8List.fromList([0x00, 0x64]),
        fields: [
          ParsedField(
            definition: config.fields.first,
            rawBytes: Uint8List.fromList([0x00, 0x64]),
            value: 100,
          ),
        ],
        isValid: true,
      );

      // 测试 getField
      final field = parsedFrame.getField('testField');
      expect(field, isNotNull);
      expect(field!.value, equals(100));
    });

    test('通道 fieldId 与解析帧配置匹配测试', () {
      // 模拟 addDataFromParsedFrameBuffered 的逻辑
      const channelFieldId = 'testConfig:testField';
      final parts = channelFieldId.split(':');
      expect(parts.length, equals(2));

      final configId = parts[0];
      final fieldId = parts[1];

      expect(configId, equals('testConfig'));
      expect(fieldId, equals('testField'));

      // 创建配置
      const config = FrameConfig(
        id: 'testConfig',
        name: 'Test Config',
        fields: [
          FieldDefinition(
            id: 'testField',
            name: 'Test Field',
            dataType: DataType.int16,
            startByte: 0,
          ),
        ],
      );

      // 检查配置 ID 匹配
      expect(config.id, equals(configId));

      // 创建解析帧
      final parsedFrame = ParsedFrame(
        config: config,
        rawData: Uint8List.fromList([0x00, 0x64]),
        fields: [
          ParsedField(
            definition: config.fields.first,
            rawBytes: Uint8List.fromList([0x00, 0x64]),
            value: 100,
          ),
        ],
        isValid: true,
      );

      // 检查帧配置匹配
      expect(parsedFrame.config.id, equals(configId));

      // 获取字段
      final field = parsedFrame.getField(fieldId);
      expect(field, isNotNull);
      expect(field!.value, equals(100));
    });

    test('_toDouble 转换测试', () {
      // 模拟 _toDouble 逻辑
      double? toDouble(dynamic value) {
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is num) return value.toDouble();
        return null;
      }

      expect(toDouble(100), equals(100.0));
      expect(toDouble(100.5), equals(100.5));
      expect(toDouble('string'), isNull);
    });

    test('OscilloscopeState 数据更新测试', () {
      // 创建初始状态
      final initialState = OscilloscopeState(
        config: const OscilloscopeConfig(
          channels: [
            ChartChannel(
              id: 'ch1',
              name: 'Test Channel',
              fieldId: 'testConfig:testField',
            ),
          ],
        ),
        isRunning: true,
        channelData: const {},
      );

      expect(initialState.isRunning, isTrue);
      expect(initialState.config.channels.length, equals(1));
      expect(initialState.channelData, isEmpty);

      // 添加数据
      final newData = <String, List<ChartDataPoint>>{
        'ch1': [
          ChartDataPoint(
            timestamp: DateTime.now().millisecondsSinceEpoch,
            value: 100.0,
          ),
        ],
      };

      final updatedState = initialState.copyWith(channelData: newData);
      expect(updatedState.channelData['ch1'], isNotNull);
      expect(updatedState.channelData['ch1']!.length, equals(1));
      expect(updatedState.channelData['ch1']!.first.value, equals(100.0));
    });

    test('完整数据流模拟', () {
      // 1. 创建通道配置
      const channel = ChartChannel(
        id: 'ch1',
        name: 'Test Channel',
        fieldId: 'testConfig:testField',
        color: Colors.blue,
      );

      // 2. 创建解析配置
      const frameConfig = FrameConfig(
        id: 'testConfig',
        name: 'Test Config',
        fields: [
          FieldDefinition(
            id: 'testField',
            name: 'Test Field',
            dataType: DataType.int16,
            startByte: 0,
          ),
        ],
      );

      // 3. 创建解析帧
      final parsedFrame = ParsedFrame(
        config: frameConfig,
        rawData: Uint8List.fromList([0x00, 0x64]),
        fields: [
          ParsedField(
            definition: frameConfig.fields.first,
            rawBytes: Uint8List.fromList([0x00, 0x64]),
            value: 100,
          ),
        ],
        isValid: true,
      );

      // 4. 模拟 addDataFromParsedFrameBuffered 逻辑
      final dataBuffer = <String, List<ChartDataPoint>>{};
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // 模拟处理通道
      final parts = channel.fieldId.split(':');
      expect(parts.length, equals(2));

      final configId = parts[0];
      final fieldId = parts[1];

      // 检查配置 ID 匹配
      if (parsedFrame.config.id == configId) {
        final field = parsedFrame.getField(fieldId);
        if (field != null) {
          final value = (field.value is num)
              ? (field.value as num).toDouble()
              : null;

          if (value != null) {
            final point = ChartDataPoint(timestamp: timestamp, value: value);
            final channelPoints = dataBuffer[channel.id] ?? [];
            channelPoints.add(point);
            dataBuffer[channel.id] = channelPoints;
          }
        }
      }

      // 验证结果
      expect(dataBuffer['ch1'], isNotNull);
      expect(dataBuffer['ch1']!.length, equals(1));
      expect(dataBuffer['ch1']!.first.value, equals(100.0));
    });
  });
}
