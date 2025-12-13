import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../domain/algorithm_strategy.dart';
import '../domain/algorithm_type.dart';

// =============================================================================
// Checksum 策略
// =============================================================================

/// Sum8 策略: 所有字节求和取低 8 位
class Sum8Strategy implements AlgorithmStrategy {
  const Sum8Strategy();

  @override
  AlgorithmType get type => AlgorithmTypes.sum8;

  @override
  Uint8List calculate(Uint8List data) {
    var sum = 0;
    for (final byte in data) {
      sum += byte;
    }
    return Uint8List.fromList([sum & 0xFF]);
  }

  @override
  String formatResult(Uint8List result, {bool uppercase = true}) {
    final hex = result[0].toRadixString(16).padLeft(2, '0');
    return uppercase ? hex.toUpperCase() : hex;
  }
}

/// Sum16 策略: 所有字节求和取低 16 位
class Sum16Strategy implements AlgorithmStrategy {
  const Sum16Strategy();

  @override
  AlgorithmType get type => AlgorithmTypes.sum16;

  @override
  Uint8List calculate(Uint8List data) {
    var sum = 0;
    for (final byte in data) {
      sum += byte;
    }
    sum &= 0xFFFF;
    return Uint8List.fromList([(sum >> 8) & 0xFF, sum & 0xFF]);
  }

  @override
  String formatResult(Uint8List result, {bool uppercase = true}) {
    final hex = result.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return uppercase ? hex.toUpperCase() : hex;
  }
}

// =============================================================================
// XOR 策略
// =============================================================================

/// XOR8 策略: 所有字节异或
class Xor8Strategy implements AlgorithmStrategy {
  const Xor8Strategy();

  @override
  AlgorithmType get type => AlgorithmTypes.xor8;

  @override
  Uint8List calculate(Uint8List data) {
    var xorResult = 0;
    for (final byte in data) {
      xorResult ^= byte;
    }
    return Uint8List.fromList([xorResult & 0xFF]);
  }

  @override
  String formatResult(Uint8List result, {bool uppercase = true}) {
    final hex = result[0].toRadixString(16).padLeft(2, '0');
    return uppercase ? hex.toUpperCase() : hex;
  }
}

// =============================================================================
// CRC 策略
// =============================================================================

/// CRC-8 标准策略
/// 多项式: 0x07, 初值: 0x00, 输入不反转, 输出不反转, 无异或输出
class Crc8Strategy implements AlgorithmStrategy {
  const Crc8Strategy();

  @override
  AlgorithmType get type => AlgorithmTypes.crc8;

  @override
  Uint8List calculate(Uint8List data) {
    var crc = 0x00;
    for (final byte in data) {
      crc ^= byte;
      for (var i = 0; i < 8; i++) {
        if ((crc & 0x80) != 0) {
          crc = ((crc << 1) ^ 0x07) & 0xFF;
        } else {
          crc = (crc << 1) & 0xFF;
        }
      }
    }
    return Uint8List.fromList([crc]);
  }

  @override
  String formatResult(Uint8List result, {bool uppercase = true}) {
    final hex = result[0].toRadixString(16).padLeft(2, '0');
    return uppercase ? hex.toUpperCase() : hex;
  }
}

/// CRC-8/MAXIM (Dallas/Maxim) 策略
/// 多项式: 0x31, 初值: 0x00, 输入反转, 输出反转, 无异或输出
class Crc8MaximStrategy implements AlgorithmStrategy {
  const Crc8MaximStrategy();

  @override
  AlgorithmType get type => AlgorithmTypes.crc8Maxim;

  @override
  Uint8List calculate(Uint8List data) {
    var crc = 0x00;
    for (final byte in data) {
      crc ^= byte;
      for (var i = 0; i < 8; i++) {
        if ((crc & 0x01) != 0) {
          crc = ((crc >> 1) ^ 0x8C) & 0xFF; // 0x8C 是 0x31 的反转
        } else {
          crc = (crc >> 1) & 0xFF;
        }
      }
    }
    return Uint8List.fromList([crc]);
  }

  @override
  String formatResult(Uint8List result, {bool uppercase = true}) {
    final hex = result[0].toRadixString(16).padLeft(2, '0');
    return uppercase ? hex.toUpperCase() : hex;
  }
}

/// CRC-16/MODBUS 策略
/// 多项式: 0x8005, 初值: 0xFFFF, 输入反转, 输出反转, 无异或输出
class Crc16ModbusStrategy implements AlgorithmStrategy {
  const Crc16ModbusStrategy();

  @override
  AlgorithmType get type => AlgorithmTypes.crc16Modbus;

  @override
  Uint8List calculate(Uint8List data) {
    var crc = 0xFFFF;
    for (final byte in data) {
      crc ^= byte;
      for (var i = 0; i < 8; i++) {
        if ((crc & 0x0001) != 0) {
          crc = (crc >> 1) ^ 0xA001; // 0xA001 是 0x8005 的反转
        } else {
          crc >>= 1;
        }
      }
    }
    // 返回大端序 (高字节在前)
    return Uint8List.fromList([(crc >> 8) & 0xFF, crc & 0xFF]);
  }

  @override
  String formatResult(Uint8List result, {bool uppercase = true}) {
    final hex = result.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return uppercase ? hex.toUpperCase() : hex;
  }
}

/// CRC-16/CCITT-FALSE 策略
/// 多项式: 0x1021, 初值: 0xFFFF, 输入不反转, 输出不反转, 无异或输出
class Crc16CcittStrategy implements AlgorithmStrategy {
  const Crc16CcittStrategy();

  @override
  AlgorithmType get type => AlgorithmTypes.crc16Ccitt;

  @override
  Uint8List calculate(Uint8List data) {
    var crc = 0xFFFF;
    for (final byte in data) {
      crc ^= (byte << 8);
      for (var i = 0; i < 8; i++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }
    return Uint8List.fromList([(crc >> 8) & 0xFF, crc & 0xFF]);
  }

  @override
  String formatResult(Uint8List result, {bool uppercase = true}) {
    final hex = result.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return uppercase ? hex.toUpperCase() : hex;
  }
}

/// CRC-16/XMODEM 策略
/// 多项式: 0x1021, 初值: 0x0000, 输入不反转, 输出不反转, 无异或输出
class Crc16XModemStrategy implements AlgorithmStrategy {
  const Crc16XModemStrategy();

  @override
  AlgorithmType get type => AlgorithmTypes.crc16XModem;

  @override
  Uint8List calculate(Uint8List data) {
    var crc = 0x0000;
    for (final byte in data) {
      crc ^= (byte << 8);
      for (var i = 0; i < 8; i++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }
    return Uint8List.fromList([(crc >> 8) & 0xFF, crc & 0xFF]);
  }

  @override
  String formatResult(Uint8List result, {bool uppercase = true}) {
    final hex = result.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return uppercase ? hex.toUpperCase() : hex;
  }
}

/// CRC-32 标准策略
/// 多项式: 0x04C11DB7, 初值: 0xFFFFFFFF, 输入反转, 输出反转, 异或输出: 0xFFFFFFFF
class Crc32Strategy implements AlgorithmStrategy {
  const Crc32Strategy();

  // 预计算的 CRC-32 查找表
  static final List<int> _table = _generateTable();

  static List<int> _generateTable() {
    final table = List<int>.filled(256, 0);
    for (var i = 0; i < 256; i++) {
      var crc = i;
      for (var j = 0; j < 8; j++) {
        if ((crc & 1) != 0) {
          crc = (crc >> 1) ^ 0xEDB88320; // 0xEDB88320 是 0x04C11DB7 的反转
        } else {
          crc >>= 1;
        }
      }
      table[i] = crc;
    }
    return table;
  }

  @override
  AlgorithmType get type => AlgorithmTypes.crc32;

  @override
  Uint8List calculate(Uint8List data) {
    var crc = 0xFFFFFFFF;
    for (final byte in data) {
      crc = _table[(crc ^ byte) & 0xFF] ^ (crc >> 8);
    }
    crc ^= 0xFFFFFFFF;
    // 返回大端序
    return Uint8List.fromList([
      (crc >> 24) & 0xFF,
      (crc >> 16) & 0xFF,
      (crc >> 8) & 0xFF,
      crc & 0xFF,
    ]);
  }

  @override
  String formatResult(Uint8List result, {bool uppercase = true}) {
    final hex = result.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return uppercase ? hex.toUpperCase() : hex;
  }
}

// =============================================================================
// 摘要算法策略
// =============================================================================

/// MD5 策略
class Md5Strategy implements AlgorithmStrategy {
  const Md5Strategy();

  @override
  AlgorithmType get type => AlgorithmTypes.md5;

  @override
  Uint8List calculate(Uint8List data) {
    final digest = md5.convert(data);
    return Uint8List.fromList(digest.bytes);
  }

  @override
  String formatResult(Uint8List result, {bool uppercase = true}) {
    final hex = result.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return uppercase ? hex.toUpperCase() : hex;
  }
}

/// SHA-1 策略
class Sha1Strategy implements AlgorithmStrategy {
  const Sha1Strategy();

  @override
  AlgorithmType get type => AlgorithmTypes.sha1;

  @override
  Uint8List calculate(Uint8List data) {
    final digest = sha1.convert(data);
    return Uint8List.fromList(digest.bytes);
  }

  @override
  String formatResult(Uint8List result, {bool uppercase = true}) {
    final hex = result.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return uppercase ? hex.toUpperCase() : hex;
  }
}

/// SHA-256 策略
class Sha256Strategy implements AlgorithmStrategy {
  const Sha256Strategy();

  @override
  AlgorithmType get type => AlgorithmTypes.sha256;

  @override
  Uint8List calculate(Uint8List data) {
    final digest = sha256.convert(data);
    return Uint8List.fromList(digest.bytes);
  }

  @override
  String formatResult(Uint8List result, {bool uppercase = true}) {
    final hex = result.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return uppercase ? hex.toUpperCase() : hex;
  }
}

// =============================================================================
// 算法注册表
// =============================================================================

/// 算法注册表 - 管理所有可用的算法策略
class AlgorithmRegistry {
  AlgorithmRegistry() {
    // 注册所有预定义算法
    _registerDefaultStrategies();
  }

  final Map<String, AlgorithmStrategy> _strategies = {};

  void _registerDefaultStrategies() {
    // Checksum
    register(const Sum8Strategy());
    register(const Sum16Strategy());

    // XOR
    register(const Xor8Strategy());

    // CRC
    register(const Crc8Strategy());
    register(const Crc8MaximStrategy());
    register(const Crc16ModbusStrategy());
    register(const Crc16CcittStrategy());
    register(const Crc16XModemStrategy());
    register(const Crc32Strategy());

    // Digest
    register(const Md5Strategy());
    register(const Sha1Strategy());
    register(const Sha256Strategy());
  }

  /// 注册算法策略
  void register(AlgorithmStrategy strategy) {
    _strategies[strategy.type.id] = strategy;
  }

  /// 获取算法策略
  AlgorithmStrategy? getStrategy(String algorithmId) {
    return _strategies[algorithmId];
  }

  /// 获取所有已注册的策略
  List<AlgorithmStrategy> get allStrategies => _strategies.values.toList();
}
