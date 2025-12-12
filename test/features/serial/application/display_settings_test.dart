import 'package:flutter_test/flutter_test.dart';

import 'package:flex_com/features/serial/application/display_settings_providers.dart';

void main() {
  group('DisplaySettings', () {
    test('should have default values', () {
      const settings = DisplaySettings();

      expect(settings.showTimestamp, true);
      expect(settings.autoWrap, true);
    });

    test('should create with custom values', () {
      const settings = DisplaySettings(showTimestamp: false, autoWrap: false);

      expect(settings.showTimestamp, false);
      expect(settings.autoWrap, false);
    });

    test('copyWith should update specified fields only', () {
      const original = DisplaySettings();

      final updated = original.copyWith(showTimestamp: false);

      expect(updated.showTimestamp, false);
      expect(updated.autoWrap, true);
    });

    test('copyWith should preserve all fields when none specified', () {
      const original = DisplaySettings(showTimestamp: false, autoWrap: false);

      final copied = original.copyWith();

      expect(copied.showTimestamp, false);
      expect(copied.autoWrap, false);
    });
  });

  group('ByteCounter', () {
    test('should have default values of zero', () {
      const counter = ByteCounter();

      expect(counter.rxBytes, 0);
      expect(counter.txBytes, 0);
    });

    test('should create with custom values', () {
      const counter = ByteCounter(rxBytes: 100, txBytes: 50);

      expect(counter.rxBytes, 100);
      expect(counter.txBytes, 50);
    });

    test('copyWith should update rxBytes only', () {
      const original = ByteCounter(rxBytes: 10, txBytes: 20);

      final updated = original.copyWith(rxBytes: 100);

      expect(updated.rxBytes, 100);
      expect(updated.txBytes, 20);
    });

    test('copyWith should update txBytes only', () {
      const original = ByteCounter(rxBytes: 10, txBytes: 20);

      final updated = original.copyWith(txBytes: 200);

      expect(updated.rxBytes, 10);
      expect(updated.txBytes, 200);
    });

    test('copyWith should preserve all fields when none specified', () {
      const original = ByteCounter(rxBytes: 10, txBytes: 20);

      final copied = original.copyWith();

      expect(copied.rxBytes, 10);
      expect(copied.txBytes, 20);
    });
  });
}
