import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flex_com/features/visualization/domain/chart_types.dart';

void main() {
  group('ChartDataPoint', () {
    test('should create a data point with timestamp and value', () {
      const point = ChartDataPoint(timestamp: 1000, value: 42.5);

      expect(point.timestamp, 1000);
      expect(point.value, 42.5);
    });

    test('should compare equal data points', () {
      const point1 = ChartDataPoint(timestamp: 1000, value: 42.5);
      const point2 = ChartDataPoint(timestamp: 1000, value: 42.5);
      const point3 = ChartDataPoint(timestamp: 2000, value: 42.5);

      expect(point1, equals(point2));
      expect(point1, isNot(equals(point3)));
    });
  });

  group('ChartChannel', () {
    test('should create a channel with default values', () {
      const channel = ChartChannel(
        id: 'ch1',
        name: 'Temperature',
        fieldId: 'temp_field',
      );

      expect(channel.id, 'ch1');
      expect(channel.name, 'Temperature');
      expect(channel.fieldId, 'temp_field');
      expect(channel.color, Colors.blue);
      expect(channel.isVisible, true);
      expect(channel.lineWidth, 2.0);
    });

    test('should create a channel with custom values', () {
      const channel = ChartChannel(
        id: 'ch2',
        name: 'Pressure',
        fieldId: 'pressure_field',
        color: Colors.red,
        isVisible: false,
        lineWidth: 3.5,
      );

      expect(channel.color, Colors.red);
      expect(channel.isVisible, false);
      expect(channel.lineWidth, 3.5);
    });

    test('copyWith should create a new channel with updated values', () {
      const original = ChartChannel(
        id: 'ch1',
        name: 'Temperature',
        fieldId: 'temp_field',
      );

      final updated = original.copyWith(
        name: 'Updated Name',
        color: Colors.green,
        isVisible: false,
      );

      expect(updated.id, 'ch1'); // unchanged
      expect(updated.name, 'Updated Name');
      expect(updated.fieldId, 'temp_field'); // unchanged
      expect(updated.color, Colors.green);
      expect(updated.isVisible, false);
    });

    test('toJson and fromJson should round-trip correctly', () {
      const original = ChartChannel(
        id: 'ch1',
        name: 'Temperature',
        fieldId: 'temp_field',
        color: Colors.blue,
        isVisible: true,
        lineWidth: 2.5,
      );

      final json = original.toJson();
      final restored = ChartChannel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.fieldId, original.fieldId);
      expect(restored.isVisible, original.isVisible);
      expect(restored.lineWidth, original.lineWidth);
    });
  });

  group('OscilloscopeConfig', () {
    test('should create config with default values', () {
      const config = OscilloscopeConfig();

      expect(config.channels, isEmpty);
      expect(config.timeWindowMs, 10000);
      expect(config.maxDataPoints, 1000);
      expect(config.autoScaleY, true);
      expect(config.gridEnabled, true);
      expect(config.showLegend, true);
    });

    test('should create config with custom values', () {
      const config = OscilloscopeConfig(
        timeWindowMs: 30000,
        maxDataPoints: 500,
        autoScaleY: false,
        minY: -10,
        maxY: 100,
        gridEnabled: false,
      );

      expect(config.timeWindowMs, 30000);
      expect(config.maxDataPoints, 500);
      expect(config.autoScaleY, false);
      expect(config.minY, -10);
      expect(config.maxY, 100);
      expect(config.gridEnabled, false);
    });

    test('copyWith should preserve unmodified values', () {
      const original = OscilloscopeConfig(
        timeWindowMs: 30000,
        maxDataPoints: 500,
      );

      final updated = original.copyWith(gridEnabled: false);

      expect(updated.timeWindowMs, 30000); // unchanged
      expect(updated.maxDataPoints, 500); // unchanged
      expect(updated.gridEnabled, false);
    });

    test('toJson and fromJson should round-trip correctly', () {
      const original = OscilloscopeConfig(
        timeWindowMs: 30000,
        maxDataPoints: 500,
        autoScaleY: false,
        minY: -10,
        maxY: 100,
      );

      final json = original.toJson();
      final restored = OscilloscopeConfig.fromJson(json);

      expect(restored.timeWindowMs, original.timeWindowMs);
      expect(restored.maxDataPoints, original.maxDataPoints);
      expect(restored.autoScaleY, original.autoScaleY);
      expect(restored.minY, original.minY);
      expect(restored.maxY, original.maxY);
    });
  });

  group('CursorInfo', () {
    test('should create cursor info', () {
      final info = CursorInfo(
        x: 100.0,
        y: 200.0,
        timestamp: 1000,
        channelValues: {'ch1': 42.5, 'ch2': 33.0},
      );

      expect(info.x, 100.0);
      expect(info.y, 200.0);
      expect(info.timestamp, 1000);
      expect(info.channelValues['ch1'], 42.5);
      expect(info.channelValues['ch2'], 33.0);
    });
  });

  group('ChannelColors', () {
    test('should return colors in order', () {
      expect(ChannelColors.getColor(0), Colors.blue);
      expect(ChannelColors.getColor(1), Colors.red);
      expect(ChannelColors.getColor(2), Colors.green);
    });

    test('should wrap around when index exceeds list length', () {
      final colorsCount = ChannelColors.colors.length;
      expect(ChannelColors.getColor(colorsCount), ChannelColors.getColor(0));
      expect(
        ChannelColors.getColor(colorsCount + 1),
        ChannelColors.getColor(1),
      );
    });
  });
}
