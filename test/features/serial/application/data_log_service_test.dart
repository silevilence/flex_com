import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:flex_com/features/serial/application/data_log_service.dart';
import 'package:flex_com/features/serial/domain/serial_data_entry.dart';

void main() {
  late DataLogService logService;
  late Directory tempDir;

  setUp(() async {
    logService = DataLogService();
    tempDir = await Directory.systemTemp.createTemp('flex_com_test_');
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('DataLogService', () {
    group('generateFileName', () {
      test('should generate .txt filename for text mode', () {
        final fileName = logService.generateFileName(isBinary: false);

        expect(fileName, startsWith('serial_log_'));
        expect(fileName, endsWith('.txt'));
        expect(fileName.length, greaterThan(20));
      });

      test('should generate .bin filename for binary mode', () {
        final fileName = logService.generateFileName(isBinary: true);

        expect(fileName, startsWith('serial_log_'));
        expect(fileName, endsWith('.bin'));
        expect(fileName.length, greaterThan(20));
      });
    });

    group('saveAsText', () {
      test('should save entries as hex text', () async {
        final entries = [
          SerialDataEntry(
            data: Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]),
            direction: DataDirection.received,
            timestamp: DateTime(2025, 1, 1, 12, 30, 45, 123),
          ),
          SerialDataEntry(
            data: Uint8List.fromList([0x57, 0x6F, 0x72, 0x6C, 0x64]),
            direction: DataDirection.sent,
            timestamp: DateTime(2025, 1, 1, 12, 30, 46, 456),
          ),
        ];

        final filePath = '${tempDir.path}/test_hex.txt';
        await logService.saveAsText(entries, filePath, asHex: true);

        final content = await File(filePath).readAsString();
        expect(content, contains('[RX]'));
        expect(content, contains('[TX]'));
        expect(content, contains('48 65 6C 6C 6F'));
        expect(content, contains('57 6F 72 6C 64'));
        expect(content, contains('2025-01-01 12:30:45.123'));
      });

      test('should save entries as ASCII text', () async {
        final entries = [
          SerialDataEntry(
            data: Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]),
            direction: DataDirection.received,
            timestamp: DateTime(2025, 1, 1, 12, 30, 45, 123),
          ),
        ];

        final filePath = '${tempDir.path}/test_ascii.txt';
        await logService.saveAsText(entries, filePath, asHex: false);

        final content = await File(filePath).readAsString();
        expect(content, contains('Hello'));
      });

      test('should handle empty entries', () async {
        final filePath = '${tempDir.path}/test_empty.txt';
        await logService.saveAsText([], filePath);

        final content = await File(filePath).readAsString();
        expect(content, isEmpty);
      });
    });

    group('saveAsBinary', () {
      test('should save entries in binary format', () async {
        final entries = [
          SerialDataEntry(
            data: Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]),
            direction: DataDirection.received,
            timestamp: DateTime(2025, 1, 1, 12, 30, 45, 123),
          ),
        ];

        final filePath = '${tempDir.path}/test.bin';
        await logService.saveAsBinary(entries, filePath);

        final bytes = await File(filePath).readAsBytes();
        // Direction (1) + Timestamp (8) + Length (4) + Data (5) = 18 bytes
        expect(bytes.length, 18);

        // Direction byte should be 0x00 for received
        expect(bytes[0], 0x00);

        // Data should be at the end
        expect(bytes.sublist(13), [0x48, 0x65, 0x6C, 0x6C, 0x6F]);
      });

      test('should save sent entries with direction byte 0x01', () async {
        final entries = [
          SerialDataEntry(
            data: Uint8List.fromList([0x41, 0x42]),
            direction: DataDirection.sent,
            timestamp: DateTime.now(),
          ),
        ];

        final filePath = '${tempDir.path}/test_sent.bin';
        await logService.saveAsBinary(entries, filePath);

        final bytes = await File(filePath).readAsBytes();
        expect(bytes[0], 0x01);
      });
    });

    group('saveRawBinary', () {
      test('should save raw data without headers', () async {
        final entries = [
          SerialDataEntry(
            data: Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]),
            direction: DataDirection.received,
            timestamp: DateTime.now(),
          ),
          SerialDataEntry(
            data: Uint8List.fromList([0x57, 0x6F, 0x72, 0x6C, 0x64]),
            direction: DataDirection.sent,
            timestamp: DateTime.now(),
          ),
        ];

        final filePath = '${tempDir.path}/test_raw.bin';
        await logService.saveRawBinary(entries, filePath);

        final bytes = await File(filePath).readAsBytes();
        expect(bytes.length, 10);
        expect(bytes, [
          0x48,
          0x65,
          0x6C,
          0x6C,
          0x6F,
          0x57,
          0x6F,
          0x72,
          0x6C,
          0x64,
        ]);
      });

      test('should filter by direction', () async {
        final entries = [
          SerialDataEntry(
            data: Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]),
            direction: DataDirection.received,
            timestamp: DateTime.now(),
          ),
          SerialDataEntry(
            data: Uint8List.fromList([0x57, 0x6F, 0x72, 0x6C, 0x64]),
            direction: DataDirection.sent,
            timestamp: DateTime.now(),
          ),
        ];

        final filePath = '${tempDir.path}/test_rx_only.bin';
        await logService.saveRawBinary(
          entries,
          filePath,
          directionFilter: DataDirection.received,
        );

        final bytes = await File(filePath).readAsBytes();
        expect(bytes.length, 5);
        expect(bytes, [0x48, 0x65, 0x6C, 0x6C, 0x6F]);
      });
    });
  });
}
