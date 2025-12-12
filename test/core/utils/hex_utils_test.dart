import 'dart:typed_data';

import 'package:flex_com/core/utils/hex_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HexUtils', () {
    group('hexStringToBytes', () {
      test('converts simple hex string to bytes', () {
        final bytes = HexUtils.hexStringToBytes('48656C6C6F');
        expect(
          bytes,
          equals(Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F])),
        );
      });

      test('converts hex string with spaces to bytes', () {
        final bytes = HexUtils.hexStringToBytes('48 65 6C 6C 6F');
        expect(
          bytes,
          equals(Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F])),
        );
      });

      test('handles lowercase hex', () {
        final bytes = HexUtils.hexStringToBytes('48 65 6c 6c 6f');
        expect(
          bytes,
          equals(Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F])),
        );
      });

      test('handles empty string', () {
        final bytes = HexUtils.hexStringToBytes('');
        expect(bytes, equals(Uint8List(0)));
      });

      test('handles whitespace only string', () {
        final bytes = HexUtils.hexStringToBytes('   ');
        expect(bytes, equals(Uint8List(0)));
      });

      test('throws FormatException for invalid hex characters', () {
        expect(
          () => HexUtils.hexStringToBytes('48 GG 6C'),
          throwsFormatException,
        );
      });

      test('throws FormatException for odd number of characters', () {
        expect(() => HexUtils.hexStringToBytes('486'), throwsFormatException);
      });

      test('handles single byte', () {
        final bytes = HexUtils.hexStringToBytes('FF');
        expect(bytes, equals(Uint8List.fromList([0xFF])));
      });

      test('handles leading zeros', () {
        final bytes = HexUtils.hexStringToBytes('00 01 0A');
        expect(bytes, equals(Uint8List.fromList([0x00, 0x01, 0x0A])));
      });
    });

    group('bytesToHexString', () {
      test('converts bytes to uppercase hex string with spaces', () {
        final hex = HexUtils.bytesToHexString(
          Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]),
        );
        expect(hex, equals('48 65 6C 6C 6F'));
      });

      test('handles empty byte array', () {
        final hex = HexUtils.bytesToHexString(Uint8List(0));
        expect(hex, equals(''));
      });

      test('handles single byte', () {
        final hex = HexUtils.bytesToHexString(Uint8List.fromList([0xFF]));
        expect(hex, equals('FF'));
      });

      test('pads single digit values with leading zero', () {
        final hex = HexUtils.bytesToHexString(
          Uint8List.fromList([0x00, 0x01, 0x0A]),
        );
        expect(hex, equals('00 01 0A'));
      });

      test('supports lowercase output', () {
        final hex = HexUtils.bytesToHexString(
          Uint8List.fromList([0xAB, 0xCD]),
          uppercase: false,
        );
        expect(hex, equals('ab cd'));
      });
    });

    group('isValidHexString', () {
      test('returns true for valid hex string', () {
        expect(HexUtils.isValidHexString('48 65 6C 6C 6F'), isTrue);
      });

      test('returns true for empty string', () {
        expect(HexUtils.isValidHexString(''), isTrue);
      });

      test('returns false for invalid characters', () {
        expect(HexUtils.isValidHexString('GG HH'), isFalse);
      });

      test('returns false for odd number of characters', () {
        expect(HexUtils.isValidHexString('486'), isFalse);
      });
    });

    group('asciiStringToBytes', () {
      test('converts ASCII string to bytes', () {
        final bytes = HexUtils.asciiStringToBytes('Hello');
        expect(bytes, equals(Uint8List.fromList([72, 101, 108, 108, 111])));
      });

      test('handles empty string', () {
        final bytes = HexUtils.asciiStringToBytes('');
        expect(bytes, equals(Uint8List(0)));
      });
    });

    group('bytesToAsciiString', () {
      test('converts bytes to ASCII string', () {
        final ascii = HexUtils.bytesToAsciiString(
          Uint8List.fromList([72, 101, 108, 108, 111]),
        );
        expect(ascii, equals('Hello'));
      });

      test('replaces non-printable characters with dot', () {
        final ascii = HexUtils.bytesToAsciiString(
          Uint8List.fromList([0x00, 0x48, 0x1F, 0x7F]),
        );
        expect(ascii, equals('.H..'));
      });

      test('handles empty byte array', () {
        final ascii = HexUtils.bytesToAsciiString(Uint8List(0));
        expect(ascii, equals(''));
      });
    });

    group('roundtrip conversions', () {
      test('hex string roundtrip', () {
        const original = '48 65 6C 6C 6F';
        final bytes = HexUtils.hexStringToBytes(original);
        final result = HexUtils.bytesToHexString(bytes);
        expect(result, equals(original));
      });

      test('ascii string roundtrip', () {
        const original = 'Hello World';
        final bytes = HexUtils.asciiStringToBytes(original);
        final result = HexUtils.bytesToAsciiString(bytes);
        expect(result, equals(original));
      });
    });
  });
}
