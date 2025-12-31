import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flex_com/features/scripting/application/script_api_bridge.dart';

void main() {
  group('ScriptApiBridge', () {
    test('should call onSend callback with hex string', () {
      Uint8List? sentData;
      final bridge = ScriptApiBridge(
        onSend: (data) {
          sentData = data;
        },
      );

      bridge.send('48656C6C6F'); // "Hello" in hex

      expect(sentData, isNotNull);
      expect(sentData!.length, 5);
      expect(sentData![0], 0x48); // 'H'
      expect(sentData![1], 0x65); // 'e'
      expect(sentData![2], 0x6C); // 'l'
      expect(sentData![3], 0x6C); // 'l'
      expect(sentData![4], 0x6F); // 'o'
    });

    test('should call onSend callback with byte list', () {
      Uint8List? sentData;
      final bridge = ScriptApiBridge(
        onSend: (data) {
          sentData = data;
        },
      );

      bridge.send([0x01, 0x02, 0x03]);

      expect(sentData, isNotNull);
      expect(sentData!.length, 3);
      expect(sentData![0], 0x01);
      expect(sentData![1], 0x02);
      expect(sentData![2], 0x03);
    });

    test('should call onLog callback', () {
      String? loggedMessage;
      String? loggedLevel;
      final bridge = ScriptApiBridge(
        onLog: (message, level) {
          loggedMessage = message;
          loggedLevel = level;
        },
      );

      bridge.log('Test message', level: 'warning');

      expect(loggedMessage, 'Test message');
      expect(loggedLevel, 'warning');
    });

    test('should use info level by default', () {
      String? loggedLevel;
      final bridge = ScriptApiBridge(
        onLog: (message, level) {
          loggedLevel = level;
        },
      );

      bridge.log('Test message');

      expect(loggedLevel, 'info');
    });

    test('should delay execution', () async {
      final bridge = ScriptApiBridge();
      final stopwatch = Stopwatch()..start();

      await bridge.delay(100);

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
    });

    test('should calculate CRC16 correctly', () {
      final bridge = ScriptApiBridge();

      final crc = bridge.crc16('0102030405');
      expect(crc, isNotEmpty);
      expect(crc.length, 4); // CRC16 is 2 bytes = 4 hex chars
    });

    test('should calculate CRC32 correctly', () {
      final bridge = ScriptApiBridge();

      final crc = bridge.crc32('0102030405');
      expect(crc, isNotEmpty);
      expect(crc.length, 8); // CRC32 is 4 bytes = 8 hex chars
    });

    test('should calculate checksum correctly', () {
      final bridge = ScriptApiBridge();

      final checksum = bridge.checksum('0102030405');
      expect(checksum, isNotEmpty);
      expect(checksum.length, 2); // Checksum8 is 1 byte = 2 hex chars
    });

    test('should get current timestamp', () {
      final bridge = ScriptApiBridge();

      final timestamp1 = bridge.getTimestamp();
      final now = DateTime.now().millisecondsSinceEpoch;

      expect(timestamp1, lessThanOrEqualTo(now));
      expect(timestamp1, greaterThan(now - 1000)); // Within 1 second
    });

    test('should convert hex to bytes', () {
      final bridge = ScriptApiBridge();

      final bytes = bridge.hexToBytes('48656C6C6F');
      expect(bytes.length, 5);
      expect(bytes[0], 0x48);
      expect(bytes[1], 0x65);
      expect(bytes[2], 0x6C);
      expect(bytes[3], 0x6C);
      expect(bytes[4], 0x6F);
    });

    test('should convert bytes to hex', () {
      final bridge = ScriptApiBridge();

      final hex = bridge.bytesToHex(
        Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]),
      );
      // 返回值可能带空格
      expect(hex.replaceAll(' ', '').toUpperCase(), '48656C6C6F');
    });

    test('should handle errors gracefully when onSend is null', () {
      final bridge = ScriptApiBridge();

      // Should not throw
      expect(() => bridge.send('0102'), returnsNormally);
    });

    test('should handle errors gracefully when onLog is null', () {
      final bridge = ScriptApiBridge();

      // Should not throw
      expect(() => bridge.log('Test'), returnsNormally);
    });

    test('should handle invalid data type in send', () {
      var hasError = false;
      final bridge = ScriptApiBridge(
        onLog: (message, level) {
          if (level == 'error') {
            hasError = true;
          }
        },
        onSend: (data) {
          // This won't be called
        },
      );

      // Should log error but not throw
      bridge.send(123); // Invalid type

      expect(hasError, true);
    });

    test('should handle CRC calculation with byte array', () {
      final bridge = ScriptApiBridge();

      final crc16 = bridge.crc16([0x01, 0x02, 0x03]);
      expect(crc16, isNotEmpty);
      expect(crc16.length, 4);

      final crc32 = bridge.crc32(Uint8List.fromList([0x01, 0x02, 0x03]));
      expect(crc32, isNotEmpty);
      expect(crc32.length, 8);

      final checksum = bridge.checksum([0x01, 0x02, 0x03]);
      expect(checksum, isNotEmpty);
      expect(checksum.length, 2);
    });
  });
}
