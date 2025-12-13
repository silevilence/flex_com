import 'package:equatable/equatable.dart';

/// 算法分类
enum AlgorithmCategory {
  /// 校验和算法
  checksum,

  /// CRC 算法
  crc,

  /// XOR 算法
  xor,

  /// 摘要/哈希算法
  digest,
}

/// 算法类型标识
class AlgorithmType extends Equatable {
  const AlgorithmType({
    required this.id,
    required this.name,
    required this.category,
    this.description = '',
  });

  /// 算法唯一标识符
  final String id;

  /// 算法显示名称
  final String name;

  /// 算法分类
  final AlgorithmCategory category;

  /// 算法描述
  final String description;

  @override
  List<Object?> get props => [id];
}

/// 预定义的算法类型
class AlgorithmTypes {
  AlgorithmTypes._();

  // ===== Checksum 算法 =====
  static const sum8 = AlgorithmType(
    id: 'sum8',
    name: 'Sum8',
    category: AlgorithmCategory.checksum,
    description: '所有字节求和取低 8 位',
  );

  static const sum16 = AlgorithmType(
    id: 'sum16',
    name: 'Sum16',
    category: AlgorithmCategory.checksum,
    description: '所有字节求和取低 16 位',
  );

  // ===== XOR 算法 =====
  static const xor8 = AlgorithmType(
    id: 'xor8',
    name: 'XOR8',
    category: AlgorithmCategory.xor,
    description: '所有字节异或',
  );

  // ===== CRC 算法 =====
  static const crc8 = AlgorithmType(
    id: 'crc8',
    name: 'CRC-8',
    category: AlgorithmCategory.crc,
    description: 'CRC-8 标准 (多项式: 0x07, 初值: 0x00)',
  );

  static const crc8Maxim = AlgorithmType(
    id: 'crc8_maxim',
    name: 'CRC-8/MAXIM',
    category: AlgorithmCategory.crc,
    description: 'CRC-8 Maxim/Dallas (多项式: 0x31, 初值: 0x00, 输入/输出反转)',
  );

  static const crc16Modbus = AlgorithmType(
    id: 'crc16_modbus',
    name: 'CRC-16/MODBUS',
    category: AlgorithmCategory.crc,
    description: 'CRC-16 MODBUS (多项式: 0x8005, 初值: 0xFFFF, 输入/输出反转)',
  );

  static const crc16Ccitt = AlgorithmType(
    id: 'crc16_ccitt',
    name: 'CRC-16/CCITT-FALSE',
    category: AlgorithmCategory.crc,
    description: 'CRC-16 CCITT-FALSE (多项式: 0x1021, 初值: 0xFFFF)',
  );

  static const crc16XModem = AlgorithmType(
    id: 'crc16_xmodem',
    name: 'CRC-16/XMODEM',
    category: AlgorithmCategory.crc,
    description: 'CRC-16 XMODEM (多项式: 0x1021, 初值: 0x0000)',
  );

  static const crc32 = AlgorithmType(
    id: 'crc32',
    name: 'CRC-32',
    category: AlgorithmCategory.crc,
    description: 'CRC-32 标准 (多项式: 0x04C11DB7, 初值: 0xFFFFFFFF)',
  );

  // ===== 摘要算法 =====
  static const md5 = AlgorithmType(
    id: 'md5',
    name: 'MD5',
    category: AlgorithmCategory.digest,
    description: 'MD5 消息摘要算法 (128 位)',
  );

  static const sha1 = AlgorithmType(
    id: 'sha1',
    name: 'SHA-1',
    category: AlgorithmCategory.digest,
    description: 'SHA-1 安全散列算法 (160 位)',
  );

  static const sha256 = AlgorithmType(
    id: 'sha256',
    name: 'SHA-256',
    category: AlgorithmCategory.digest,
    description: 'SHA-256 安全散列算法 (256 位)',
  );

  /// 所有支持的算法
  static const all = <AlgorithmType>[
    sum8,
    sum16,
    xor8,
    crc8,
    crc8Maxim,
    crc16Modbus,
    crc16Ccitt,
    crc16XModem,
    crc32,
    md5,
    sha1,
    sha256,
  ];

  /// 按分类获取算法
  static List<AlgorithmType> byCategory(AlgorithmCategory category) {
    return all.where((a) => a.category == category).toList();
  }

  /// 根据 ID 获取算法类型
  static AlgorithmType? findById(String id) {
    for (final type in all) {
      if (type.id == id) return type;
    }
    return null;
  }
}
