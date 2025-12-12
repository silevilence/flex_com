import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// Represents the direction of serial data.
enum DataDirection {
  /// Data received from the serial port
  received,

  /// Data sent through the serial port
  sent,
}

/// Represents a single entry of serial data.
///
/// This is used to display data in the receive/send log area.
class SerialDataEntry extends Equatable {
  const SerialDataEntry({
    required this.data,
    required this.direction,
    required this.timestamp,
  });

  /// Creates a new entry for received data.
  factory SerialDataEntry.received(Uint8List data) {
    return SerialDataEntry(
      data: data,
      direction: DataDirection.received,
      timestamp: DateTime.now(),
    );
  }

  /// Creates a new entry for sent data.
  factory SerialDataEntry.sent(Uint8List data) {
    return SerialDataEntry(
      data: data,
      direction: DataDirection.sent,
      timestamp: DateTime.now(),
    );
  }

  /// The raw byte data
  final Uint8List data;

  /// Direction of the data (received or sent)
  final DataDirection direction;

  /// When this data was received/sent
  final DateTime timestamp;

  /// Converts the data to a hex string.
  String toHexString() {
    return data
        .map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(' ');
  }

  /// Converts the data to an ASCII string.
  ///
  /// Non-printable characters are replaced with a dot.
  String toAsciiString() {
    return String.fromCharCodes(
      data.map((byte) => (byte >= 32 && byte < 127) ? byte : '.'.codeUnitAt(0)),
    );
  }

  /// Converts the data to a string, attempting to decode as UTF-8.
  ///
  /// Falls back to ASCII if UTF-8 decoding fails.
  String toTextString() {
    try {
      return String.fromCharCodes(data);
    } catch (_) {
      return toAsciiString();
    }
  }

  @override
  List<Object?> get props => [data, direction, timestamp];
}

/// Display mode for serial data.
enum DataDisplayMode {
  /// Display as hexadecimal
  hex,

  /// Display as ASCII text
  ascii,
}
