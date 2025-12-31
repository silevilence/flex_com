import 'dart:typed_data';
import '../../../core/utils/checksum_utils.dart';
import '../../../core/utils/hex_utils.dart';
import '../domain/script_interfaces.dart';

/// 脚本API桥接器实现
class ScriptApiBridge implements IScriptApiBridge {
  /// 发送数据回调
  final void Function(Uint8List data)? onSend;

  /// 日志回调
  final void Function(String message, String level)? onLog;

  ScriptApiBridge({this.onSend, this.onLog});

  @override
  void send(dynamic data) {
    if (onSend == null) return;

    try {
      Uint8List bytes;
      if (data is String) {
        // 假设是Hex字符串
        bytes = HexUtils.hexStringToBytes(data);
      } else if (data is List<int>) {
        bytes = Uint8List.fromList(data);
      } else if (data is Uint8List) {
        bytes = data;
      } else {
        throw ArgumentError('Invalid data type for send()');
      }

      onSend!(bytes);
    } catch (e) {
      log('send() error: $e', level: 'error');
    }
  }

  @override
  void log(String message, {String level = 'info'}) {
    onLog?.call(message, level);
  }

  @override
  Future<void> delay(int ms) async {
    await Future.delayed(Duration(milliseconds: ms));
  }

  @override
  String crc16(dynamic data) {
    try {
      Uint8List bytes;
      if (data is String) {
        bytes = HexUtils.hexStringToBytes(data);
      } else if (data is List<int>) {
        bytes = Uint8List.fromList(data);
      } else if (data is Uint8List) {
        bytes = data;
      } else {
        throw ArgumentError('Invalid data type for crc16()');
      }

      final crc = ChecksumUtils.calculateCrc16Modbus(bytes);
      return crc.toRadixString(16).padLeft(4, '0').toUpperCase();
    } catch (e) {
      log('crc16() error: $e', level: 'error');
      return '0000';
    }
  }

  @override
  String crc32(dynamic data) {
    try {
      Uint8List bytes;
      if (data is String) {
        bytes = HexUtils.hexStringToBytes(data);
      } else if (data is List<int>) {
        bytes = Uint8List.fromList(data);
      } else if (data is Uint8List) {
        bytes = data;
      } else {
        throw ArgumentError('Invalid data type for crc32()');
      }

      // 使用简单的CRC32实现
      var crc = 0xFFFFFFFF;
      for (final byte in bytes) {
        crc ^= byte;
        for (var i = 0; i < 8; i++) {
          crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xEDB88320 : crc >> 1;
        }
      }
      return (~crc & 0xFFFFFFFF)
          .toRadixString(16)
          .padLeft(8, '0')
          .toUpperCase();
    } catch (e) {
      log('crc32() error: $e', level: 'error');
      return '00000000';
    }
  }

  @override
  String checksum(dynamic data) {
    try {
      Uint8List bytes;
      if (data is String) {
        bytes = HexUtils.hexStringToBytes(data);
      } else if (data is List<int>) {
        bytes = Uint8List.fromList(data);
      } else if (data is Uint8List) {
        bytes = data;
      } else {
        throw ArgumentError('Invalid data type for checksum()');
      }

      final sum = ChecksumUtils.calculateChecksum8(bytes);
      return sum.toRadixString(16).padLeft(2, '0').toUpperCase();
    } catch (e) {
      log('checksum() error: $e', level: 'error');
      return '00';
    }
  }

  @override
  int getTimestamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  @override
  Uint8List hexToBytes(String hex) {
    return HexUtils.hexStringToBytes(hex);
  }

  @override
  String bytesToHex(Uint8List bytes) {
    return HexUtils.bytesToHexString(bytes, uppercase: true);
  }
}
