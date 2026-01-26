import 'package:equatable/equatable.dart';

/// 字节序
enum Endianness {
  /// 小端序（低字节在前）
  little,

  /// 大端序（高字节在前）
  big;

  String get displayName {
    switch (this) {
      case Endianness.little:
        return 'Little Endian';
      case Endianness.big:
        return 'Big Endian';
    }
  }
}

/// 数据类型
enum DataType {
  /// 无符号 8 位整数
  uint8,

  /// 有符号 8 位整数
  int8,

  /// 无符号 16 位整数
  uint16,

  /// 有符号 16 位整数
  int16,

  /// 无符号 32 位整数
  uint32,

  /// 有符号 32 位整数
  int32,

  /// 32 位浮点数
  float32,

  /// 64 位浮点数
  float64,

  /// 原始字节数组
  bytes,

  /// ASCII 字符串
  ascii;

  String get displayName {
    switch (this) {
      case DataType.uint8:
        return 'UInt8';
      case DataType.int8:
        return 'Int8';
      case DataType.uint16:
        return 'UInt16';
      case DataType.int16:
        return 'Int16';
      case DataType.uint32:
        return 'UInt32';
      case DataType.int32:
        return 'Int32';
      case DataType.float32:
        return 'Float32';
      case DataType.float64:
        return 'Float64';
      case DataType.bytes:
        return 'Bytes';
      case DataType.ascii:
        return 'ASCII';
    }
  }

  /// 数据类型所占字节数（bytes 和 ascii 返回 0，表示可变长度）
  int get byteSize {
    switch (this) {
      case DataType.uint8:
      case DataType.int8:
        return 1;
      case DataType.uint16:
      case DataType.int16:
        return 2;
      case DataType.uint32:
      case DataType.int32:
      case DataType.float32:
        return 4;
      case DataType.float64:
        return 8;
      case DataType.bytes:
      case DataType.ascii:
        return 0;
    }
  }
}

/// 校验类型
enum ChecksumType {
  /// 无校验
  none,

  /// Sum8 校验和
  sum8,

  /// Sum16 校验和
  sum16,

  /// XOR8 异或校验
  xor8,

  /// CRC-8
  crc8,

  /// CRC-16 MODBUS
  crc16Modbus,

  /// CRC-16 CCITT
  crc16Ccitt,

  /// CRC-32
  crc32;

  String get displayName {
    switch (this) {
      case ChecksumType.none:
        return '无校验';
      case ChecksumType.sum8:
        return 'Sum8';
      case ChecksumType.sum16:
        return 'Sum16';
      case ChecksumType.xor8:
        return 'XOR8';
      case ChecksumType.crc8:
        return 'CRC-8';
      case ChecksumType.crc16Modbus:
        return 'CRC-16/MODBUS';
      case ChecksumType.crc16Ccitt:
        return 'CRC-16/CCITT';
      case ChecksumType.crc32:
        return 'CRC-32';
    }
  }

  /// 校验位所占字节数
  int get byteSize {
    switch (this) {
      case ChecksumType.none:
        return 0;
      case ChecksumType.sum8:
      case ChecksumType.xor8:
      case ChecksumType.crc8:
        return 1;
      case ChecksumType.sum16:
      case ChecksumType.crc16Modbus:
      case ChecksumType.crc16Ccitt:
        return 2;
      case ChecksumType.crc32:
        return 4;
    }
  }
}

/// 字段定义
///
/// 定义帧中的一个数据字段
class FieldDefinition extends Equatable {
  const FieldDefinition({
    required this.id,
    required this.name,
    required this.startByte,
    required this.dataType,
    this.length = 1,
    this.endianness = Endianness.big,
    this.bitMask,
    this.bitOffset,
    this.description = '',
    this.unit = '',
    this.scaleFactor = 1.0,
    this.offset = 0.0,
  });

  /// 字段唯一标识符
  final String id;

  /// 字段名称
  final String name;

  /// 起始字节索引（从 0 开始）
  final int startByte;

  /// 数据类型
  final DataType dataType;

  /// 字节长度（仅 bytes 和 ascii 类型需要）
  final int length;

  /// 字节序
  final Endianness endianness;

  /// 位掩码（用于位域提取，null 表示不使用）
  final int? bitMask;

  /// 位偏移（提取后右移的位数）
  final int? bitOffset;

  /// 字段描述
  final String description;

  /// 单位
  final String unit;

  /// 比例因子（原始值 * scaleFactor + offset = 实际值）
  final double scaleFactor;

  /// 偏移量
  final double offset;

  /// 计算字段实际占用的字节数
  int get byteLength {
    final typeSize = dataType.byteSize;
    return typeSize > 0 ? typeSize : length;
  }

  /// 是否为位域字段
  bool get isBitField => bitMask != null;

  FieldDefinition copyWith({
    String? id,
    String? name,
    int? startByte,
    DataType? dataType,
    int? length,
    Endianness? endianness,
    int? bitMask,
    int? bitOffset,
    String? description,
    String? unit,
    double? scaleFactor,
    double? offset,
    bool clearBitMask = false,
    bool clearBitOffset = false,
  }) {
    return FieldDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      startByte: startByte ?? this.startByte,
      dataType: dataType ?? this.dataType,
      length: length ?? this.length,
      endianness: endianness ?? this.endianness,
      bitMask: clearBitMask ? null : (bitMask ?? this.bitMask),
      bitOffset: clearBitOffset ? null : (bitOffset ?? this.bitOffset),
      description: description ?? this.description,
      unit: unit ?? this.unit,
      scaleFactor: scaleFactor ?? this.scaleFactor,
      offset: offset ?? this.offset,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startByte': startByte,
      'dataType': dataType.name,
      'length': length,
      'endianness': endianness.name,
      if (bitMask != null) 'bitMask': bitMask,
      if (bitOffset != null) 'bitOffset': bitOffset,
      'description': description,
      'unit': unit,
      'scaleFactor': scaleFactor,
      'offset': offset,
    };
  }

  factory FieldDefinition.fromJson(Map<String, dynamic> json) {
    return FieldDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      startByte: json['startByte'] as int,
      dataType: DataType.values.firstWhere(
        (t) => t.name == json['dataType'],
        orElse: () => DataType.uint8,
      ),
      length: json['length'] as int? ?? 1,
      endianness: Endianness.values.firstWhere(
        (e) => e.name == json['endianness'],
        orElse: () => Endianness.big,
      ),
      bitMask: json['bitMask'] as int?,
      bitOffset: json['bitOffset'] as int?,
      description: json['description'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      scaleFactor: (json['scaleFactor'] as num?)?.toDouble() ?? 1.0,
      offset: (json['offset'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    startByte,
    dataType,
    length,
    endianness,
    bitMask,
    bitOffset,
    description,
    unit,
    scaleFactor,
    offset,
  ];
}
