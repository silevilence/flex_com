import 'package:flutter_test/flutter_test.dart';

import 'package:flex_com/features/visualization/domain/chart_types.dart';
import 'package:flex_com/features/visualization/domain/oscilloscope_state.dart';

void main() {
  group('OscilloscopeState', () {
    test('should create state with default values', () {
      const state = OscilloscopeState();

      expect(state.config, isA<OscilloscopeConfig>());
      expect(state.channelData, isEmpty);
      expect(state.isRunning, false);
      expect(state.isPaused, false);
      expect(state.cursorInfo, isNull);
      expect(state.startTime, isNull);
    });

    test('getChannelData should return empty list for unknown channel', () {
      const state = OscilloscopeState();
      expect(state.getChannelData('unknown'), isEmpty);
    });

    test('getChannelData should return data for known channel', () {
      const points = [
        ChartDataPoint(timestamp: 1000, value: 10.0),
        ChartDataPoint(timestamp: 2000, value: 20.0),
      ];

      final state = OscilloscopeState(channelData: {'ch1': points});

      expect(state.getChannelData('ch1'), equals(points));
    });

    test('visibleChannels should filter by isVisible', () {
      const channels = [
        ChartChannel(
          id: 'ch1',
          name: 'Visible',
          fieldId: 'f1',
          isVisible: true,
        ),
        ChartChannel(
          id: 'ch2',
          name: 'Hidden',
          fieldId: 'f2',
          isVisible: false,
        ),
        ChartChannel(
          id: 'ch3',
          name: 'Also Visible',
          fieldId: 'f3',
          isVisible: true,
        ),
      ];

      final state = OscilloscopeState(
        config: OscilloscopeConfig(channels: channels),
      );

      expect(state.visibleChannels.length, 2);
      expect(state.visibleChannels.map((c) => c.id), ['ch1', 'ch3']);
    });

    group('calculateYRange', () {
      test('should return config values when autoScale is off', () {
        final state = OscilloscopeState(
          config: const OscilloscopeConfig(
            autoScaleY: false,
            minY: -50,
            maxY: 150,
          ),
        );

        final range = state.calculateYRange();
        expect(range.min, -50);
        expect(range.max, 150);
      });

      test('should return default range when no data', () {
        const state = OscilloscopeState(
          config: OscilloscopeConfig(autoScaleY: true),
        );

        final range = state.calculateYRange();
        expect(range.min, 0.0);
        expect(range.max, 100.0);
      });

      test('should calculate range from visible channel data', () {
        const channel = ChartChannel(
          id: 'ch1',
          name: 'Test',
          fieldId: 'f1',
          isVisible: true,
        );

        const points = [
          ChartDataPoint(timestamp: 1000, value: 10.0),
          ChartDataPoint(timestamp: 2000, value: 50.0),
          ChartDataPoint(timestamp: 3000, value: 30.0),
        ];

        final state = OscilloscopeState(
          config: const OscilloscopeConfig(
            channels: [channel],
            autoScaleY: true,
          ),
          channelData: {'ch1': points},
        );

        final range = state.calculateYRange();
        // Min: 10 - (50-10)*0.1 = 6
        // Max: 50 + (50-10)*0.1 = 54
        expect(range.min, closeTo(6.0, 0.01));
        expect(range.max, closeTo(54.0, 0.01));
      });

      test('should ignore hidden channels', () {
        const visibleChannel = ChartChannel(
          id: 'ch1',
          name: 'Visible',
          fieldId: 'f1',
          isVisible: true,
        );
        const hiddenChannel = ChartChannel(
          id: 'ch2',
          name: 'Hidden',
          fieldId: 'f2',
          isVisible: false,
        );

        final state = OscilloscopeState(
          config: const OscilloscopeConfig(
            channels: [visibleChannel, hiddenChannel],
            autoScaleY: true,
          ),
          channelData: {
            'ch1': [
              const ChartDataPoint(timestamp: 1000, value: 10.0),
              const ChartDataPoint(timestamp: 2000, value: 20.0),
            ],
            'ch2': [
              // Hidden channel with large values - should be ignored
              const ChartDataPoint(timestamp: 1000, value: 1000.0),
              const ChartDataPoint(timestamp: 2000, value: 2000.0),
            ],
          },
        );

        final range = state.calculateYRange();
        // Range should be based on ch1 only (10-20), not ch2
        expect(range.max, lessThan(100.0));
      });
    });

    group('copyWith', () {
      test('should preserve values when not specified', () {
        final original = OscilloscopeState(
          isRunning: true,
          isPaused: true,
          startTime: DateTime(2024, 1, 1),
        );

        final updated = original.copyWith(isRunning: false);

        expect(updated.isRunning, false);
        expect(updated.isPaused, true); // unchanged
        expect(updated.startTime, DateTime(2024, 1, 1)); // unchanged
      });

      test('clearCursorInfo should set cursorInfo to null', () {
        final original = OscilloscopeState(
          cursorInfo: const CursorInfo(x: 100, y: 200, timestamp: 1000),
        );

        final updated = original.copyWith(clearCursorInfo: true);

        expect(updated.cursorInfo, isNull);
      });

      test('clearStartTime should set startTime to null', () {
        final original = OscilloscopeState(startTime: DateTime(2024, 1, 1));

        final updated = original.copyWith(clearStartTime: true);

        expect(updated.startTime, isNull);
      });
    });
  });

  group('FieldInfo', () {
    test('should create field info', () {
      const info = FieldInfo(
        id: 'config:field',
        name: 'Temperature',
        typeName: 'int16',
        configName: 'Sensor Data',
      );

      expect(info.id, 'config:field');
      expect(info.name, 'Temperature');
      expect(info.typeName, 'int16');
      expect(info.configName, 'Sensor Data');
    });

    test('configName should be optional', () {
      const info = FieldInfo(
        id: 'config:field',
        name: 'Temperature',
        typeName: 'int16',
      );

      expect(info.configName, isNull);
    });
  });

  group('ChannelSelectorState', () {
    test('should create state with default values', () {
      const state = ChannelSelectorState();

      expect(state.availableFields, isEmpty);
      expect(state.selectedFieldIds, isEmpty);
    });

    test('copyWith should update values', () {
      const original = ChannelSelectorState(
        availableFields: [
          FieldInfo(id: 'f1', name: 'Field 1', typeName: 'int'),
        ],
        selectedFieldIds: {'f1'},
      );

      final updated = original.copyWith(selectedFieldIds: {'f1', 'f2'});

      expect(updated.availableFields.length, 1); // unchanged
      expect(updated.selectedFieldIds, {'f1', 'f2'});
    });
  });
}
