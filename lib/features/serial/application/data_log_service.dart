import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';

import '../domain/serial_data_entry.dart';

/// Service for saving serial communication logs to files.
class DataLogService {
  /// Generates a default filename based on current timestamp.
  String generateFileName({bool isBinary = false}) {
    final now = DateTime.now();
    final formatter = DateFormat('yyyyMMdd_HHmmss');
    final extension = isBinary ? 'bin' : 'txt';
    return 'serial_log_${formatter.format(now)}.$extension';
  }

  /// Saves log entries to a text file.
  ///
  /// Format: [Timestamp] [Direction] [Data]
  Future<void> saveAsText(
    List<SerialDataEntry> entries,
    String filePath, {
    bool asHex = true,
  }) async {
    final buffer = StringBuffer();
    final timeFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');

    for (final entry in entries) {
      final timestamp = timeFormat.format(entry.timestamp);
      final direction = entry.direction == DataDirection.received ? 'RX' : 'TX';
      final data = asHex ? entry.toHexString() : entry.toTextString();
      buffer.writeln('[$timestamp] [$direction] $data');
    }

    final file = File(filePath);
    await file.writeAsString(buffer.toString());
  }

  /// Saves log entries to a binary file.
  ///
  /// Format: Each entry is prefixed with a header containing:
  /// - 1 byte: Direction (0x00 = RX, 0x01 = TX)
  /// - 8 bytes: Timestamp (milliseconds since epoch, big-endian)
  /// - 4 bytes: Data length (big-endian)
  /// - N bytes: Raw data
  Future<void> saveAsBinary(
    List<SerialDataEntry> entries,
    String filePath,
  ) async {
    final file = File(filePath);
    final sink = file.openWrite();

    try {
      for (final entry in entries) {
        // Direction byte
        sink.add([entry.direction == DataDirection.received ? 0x00 : 0x01]);

        // Timestamp (8 bytes, big-endian)
        final timestamp = entry.timestamp.millisecondsSinceEpoch;
        sink.add(_int64ToBytes(timestamp));

        // Data length (4 bytes, big-endian)
        sink.add(_int32ToBytes(entry.data.length));

        // Raw data
        sink.add(entry.data);
      }
    } finally {
      await sink.close();
    }
  }

  /// Exports all raw data (without headers) to a binary file.
  ///
  /// Useful for analyzing raw communication data.
  Future<void> saveRawBinary(
    List<SerialDataEntry> entries,
    String filePath, {
    DataDirection? directionFilter,
  }) async {
    final file = File(filePath);
    final sink = file.openWrite();

    try {
      for (final entry in entries) {
        if (directionFilter == null || entry.direction == directionFilter) {
          sink.add(entry.data);
        }
      }
    } finally {
      await sink.close();
    }
  }

  Uint8List _int64ToBytes(int value) {
    return Uint8List(8)
      ..[0] = (value >> 56) & 0xFF
      ..[1] = (value >> 48) & 0xFF
      ..[2] = (value >> 40) & 0xFF
      ..[3] = (value >> 32) & 0xFF
      ..[4] = (value >> 24) & 0xFF
      ..[5] = (value >> 16) & 0xFF
      ..[6] = (value >> 8) & 0xFF
      ..[7] = value & 0xFF;
  }

  Uint8List _int32ToBytes(int value) {
    return Uint8List(4)
      ..[0] = (value >> 24) & 0xFF
      ..[1] = (value >> 16) & 0xFF
      ..[2] = (value >> 8) & 0xFF
      ..[3] = value & 0xFF;
  }
}
