import 'dart:typed_data';

/// 校验计算工具类
class ChecksumUtils {
  ChecksumUtils._();

  /// 计算简单校验和 (所有字节求和取低 8 位)
  ///
  /// 返回单字节校验值
  static int calculateChecksum8(Uint8List data) {
    var sum = 0;
    for (final byte in data) {
      sum += byte;
    }
    return sum & 0xFF;
  }

  /// 计算 CRC16-MODBUS
  ///
  /// 多项式: 0xA001 (反转的 0x8005)
  /// 初始值: 0xFFFF
  /// 返回 2 字节 CRC (低字节在前)
  static int calculateCrc16Modbus(Uint8List data) {
    var crc = 0xFFFF;

    for (final byte in data) {
      crc ^= byte;
      for (var i = 0; i < 8; i++) {
        if ((crc & 0x0001) != 0) {
          crc = (crc >> 1) ^ 0xA001;
        } else {
          crc >>= 1;
        }
      }
    }

    return crc;
  }

  /// 将校验和附加到数据末尾
  ///
  /// 返回包含原始数据和校验和的新数据
  static Uint8List appendChecksum8(Uint8List data) {
    final checksum = calculateChecksum8(data);
    final result = Uint8List(data.length + 1);
    result.setRange(0, data.length, data);
    result[data.length] = checksum;
    return result;
  }

  /// 将 CRC16 附加到数据末尾
  ///
  /// CRC16 以低字节在前 (Little Endian) 的方式附加
  /// 返回包含原始数据和 CRC16 的新数据
  static Uint8List appendCrc16Modbus(Uint8List data) {
    final crc = calculateCrc16Modbus(data);
    final result = Uint8List(data.length + 2);
    result.setRange(0, data.length, data);
    // CRC16 低字节在前
    result[data.length] = crc & 0xFF;
    result[data.length + 1] = (crc >> 8) & 0xFF;
    return result;
  }
}
