import 'package:equatable/equatable.dart';

/// 校验类型枚举
enum ChecksumType {
  /// 无校验
  none,

  /// 简单校验和 (所有字节求和取低 8 位)
  checksum8,

  /// CRC16-MODBUS
  crc16Modbus,
}

/// 校验类型扩展
extension ChecksumTypeExtension on ChecksumType {
  String get displayName {
    switch (this) {
      case ChecksumType.none:
        return '无';
      case ChecksumType.checksum8:
        return 'Checksum';
      case ChecksumType.crc16Modbus:
        return 'CRC16';
    }
  }
}

/// 发送辅助设置
class SendSettings extends Equatable {
  const SendSettings({
    this.appendNewline = false,
    this.checksumType = ChecksumType.none,
    this.cyclicSendEnabled = false,
    this.cyclicIntervalMs = 1000,
  });

  /// 是否自动追加换行符 (\r\n)
  final bool appendNewline;

  /// 校验类型
  final ChecksumType checksumType;

  /// 是否启用定时循环发送
  final bool cyclicSendEnabled;

  /// 循环发送间隔 (毫秒)
  final int cyclicIntervalMs;

  /// 最小循环间隔 (毫秒)
  static const int minIntervalMs = 10;

  /// 最大循环间隔 (毫秒)
  static const int maxIntervalMs = 60000;

  SendSettings copyWith({
    bool? appendNewline,
    ChecksumType? checksumType,
    bool? cyclicSendEnabled,
    int? cyclicIntervalMs,
  }) {
    return SendSettings(
      appendNewline: appendNewline ?? this.appendNewline,
      checksumType: checksumType ?? this.checksumType,
      cyclicSendEnabled: cyclicSendEnabled ?? this.cyclicSendEnabled,
      cyclicIntervalMs: cyclicIntervalMs ?? this.cyclicIntervalMs,
    );
  }

  @override
  List<Object?> get props => [
    appendNewline,
    checksumType,
    cyclicSendEnabled,
    cyclicIntervalMs,
  ];
}
