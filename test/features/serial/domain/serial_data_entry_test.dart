import 'dart:typed_data';

import 'package:flex_com/features/serial/domain/serial_data_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SerialDataEntry', () {
    group('factory constructors', () {
      test('received creates entry with received direction', () {
        final data = Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]);
        final entry = SerialDataEntry.received(data);

        expect(entry.data, equals(data));
        expect(entry.direction, equals(DataDirection.received));
        expect(entry.timestamp, isNotNull);
      });

      test('sent creates entry with sent direction', () {
        final data = Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]);
        final entry = SerialDataEntry.sent(data);

        expect(entry.data, equals(data));
        expect(entry.direction, equals(DataDirection.sent));
        expect(entry.timestamp, isNotNull);
      });
    });

    group('toHexString', () {
      test('converts data to uppercase hex string with spaces', () {
        final data = Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]);
        final entry = SerialDataEntry.received(data);

        expect(entry.toHexString(), equals('48 65 6C 6C 6F'));
      });

      test('handles empty data', () {
        final entry = SerialDataEntry.received(Uint8List(0));

        expect(entry.toHexString(), equals(''));
      });

      test('pads single digit values', () {
        final data = Uint8List.fromList([0x00, 0x01, 0x0A]);
        final entry = SerialDataEntry.received(data);

        expect(entry.toHexString(), equals('00 01 0A'));
      });
    });

    group('toAsciiString', () {
      test('converts printable characters correctly', () {
        final data = Uint8List.fromList([72, 101, 108, 108, 111]); // "Hello"
        final entry = SerialDataEntry.received(data);

        expect(entry.toAsciiString(), equals('Hello'));
      });

      test('replaces non-printable characters with dot', () {
        final data = Uint8List.fromList([0x00, 0x48, 0x1F, 0x7F]);
        final entry = SerialDataEntry.received(data);

        expect(entry.toAsciiString(), equals('.H..'));
      });

      test('handles empty data', () {
        final entry = SerialDataEntry.received(Uint8List(0));

        expect(entry.toAsciiString(), equals(''));
      });
    });

    group('toTextString', () {
      test('converts valid text correctly', () {
        final data = Uint8List.fromList([72, 101, 108, 108, 111]); // "Hello"
        final entry = SerialDataEntry.received(data);

        expect(entry.toTextString(), equals('Hello'));
      });

      test('handles empty data', () {
        final entry = SerialDataEntry.received(Uint8List(0));

        expect(entry.toTextString(), equals(''));
      });
    });

    group('equality', () {
      test('equal entries are equal', () {
        final data = Uint8List.fromList([0x48, 0x65]);
        final timestamp = DateTime(2024, 1, 1, 12, 0, 0);

        final entry1 = SerialDataEntry(
          data: data,
          direction: DataDirection.received,
          timestamp: timestamp,
        );
        final entry2 = SerialDataEntry(
          data: data,
          direction: DataDirection.received,
          timestamp: timestamp,
        );

        expect(entry1, equals(entry2));
      });

      test('different direction means not equal', () {
        final data = Uint8List.fromList([0x48, 0x65]);
        final timestamp = DateTime(2024, 1, 1, 12, 0, 0);

        final entry1 = SerialDataEntry(
          data: data,
          direction: DataDirection.received,
          timestamp: timestamp,
        );
        final entry2 = SerialDataEntry(
          data: data,
          direction: DataDirection.sent,
          timestamp: timestamp,
        );

        expect(entry1, isNot(equals(entry2)));
      });
    });
  });

  group('DataDisplayMode', () {
    test('has correct values', () {
      expect(DataDisplayMode.values, hasLength(2));
      expect(DataDisplayMode.hex, isNotNull);
      expect(DataDisplayMode.ascii, isNotNull);
    });
  });
}
