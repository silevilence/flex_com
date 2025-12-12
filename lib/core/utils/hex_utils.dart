import 'dart:typed_data';

/// Utility class for converting between hex strings and byte data.
class HexUtils {
  HexUtils._();

  /// Converts a hex string to a Uint8List.
  ///
  /// The hex string can contain spaces, and each byte should be represented
  /// by two hex characters (e.g., "48 65 6C 6C 6F" or "48656C6C6F").
  ///
  /// Throws [FormatException] if the input is not valid hex.
  static Uint8List hexStringToBytes(String hexString) {
    // Remove all whitespace
    final cleaned = hexString.replaceAll(RegExp(r'\s+'), '');

    if (cleaned.isEmpty) {
      return Uint8List(0);
    }

    // Validate that the string contains only hex characters
    if (!RegExp(r'^[0-9A-Fa-f]+$').hasMatch(cleaned)) {
      throw FormatException('Invalid hex character in: $hexString');
    }

    // Ensure even number of characters
    if (cleaned.length % 2 != 0) {
      throw FormatException('Hex string must have even number of characters');
    }

    final bytes = <int>[];
    for (var i = 0; i < cleaned.length; i += 2) {
      final byteStr = cleaned.substring(i, i + 2);
      bytes.add(int.parse(byteStr, radix: 16));
    }

    return Uint8List.fromList(bytes);
  }

  /// Converts a Uint8List to a hex string with spaces.
  ///
  /// Example: [0x48, 0x65, 0x6C] -> "48 65 6C"
  static String bytesToHexString(Uint8List bytes, {bool uppercase = true}) {
    final hexBytes = bytes.map((byte) {
      final hex = byte.toRadixString(16).padLeft(2, '0');
      return uppercase ? hex.toUpperCase() : hex;
    });
    return hexBytes.join(' ');
  }

  /// Checks if a string is a valid hex string.
  static bool isValidHexString(String hexString) {
    try {
      hexStringToBytes(hexString);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Converts an ASCII string to a Uint8List.
  static Uint8List asciiStringToBytes(String text) {
    return Uint8List.fromList(text.codeUnits);
  }

  /// Converts a Uint8List to an ASCII string.
  ///
  /// Non-printable characters are replaced with a dot.
  static String bytesToAsciiString(Uint8List bytes) {
    return String.fromCharCodes(
      bytes.map(
        (byte) => (byte >= 32 && byte < 127) ? byte : '.'.codeUnitAt(0),
      ),
    );
  }
}
