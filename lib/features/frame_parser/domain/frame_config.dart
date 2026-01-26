import 'package:equatable/equatable.dart';

import 'parser_types.dart';

/// 帧结构配置
///
/// 定义一种协议帧的完整结构，包括帧头、帧尾、校验位和数据字段
class FrameConfig extends Equatable {
  const FrameConfig({
    required this.id,
    required this.name,
    this.description = '',
    this.header = const [],
    this.footer = const [],
    this.checksumType = ChecksumType.none,
    this.checksumStartByte = 0,
    this.checksumEndByte,
    this.checksumEndianness = Endianness.big,
    this.fields = const [],
    this.minLength,
    this.maxLength,
  });

  /// 配置唯一标识符
  final String id;

  /// 配置名称
  final String name;

  /// 配置描述
  final String description;

  /// 帧头字节序列（用于帧同步）
  final List<int> header;

  /// 帧尾字节序列（可选）
  final List<int> footer;

  /// 校验类型
  final ChecksumType checksumType;

  /// 校验计算起始字节索引
  final int checksumStartByte;

  /// 校验计算结束字节索引（null 表示到校验位之前）
  final int? checksumEndByte;

  /// 校验位字节序
  final Endianness checksumEndianness;

  /// 数据字段定义列表
  final List<FieldDefinition> fields;

  /// 最小帧长度（用于帧验证）
  final int? minLength;

  /// 最大帧长度（用于帧验证）
  final int? maxLength;

  /// 计算校验位所在的位置（从帧尾往前数）
  int get checksumPosition {
    return footer.length + checksumType.byteSize;
  }

  FrameConfig copyWith({
    String? id,
    String? name,
    String? description,
    List<int>? header,
    List<int>? footer,
    ChecksumType? checksumType,
    int? checksumStartByte,
    int? checksumEndByte,
    Endianness? checksumEndianness,
    List<FieldDefinition>? fields,
    int? minLength,
    int? maxLength,
    bool clearChecksumEndByte = false,
    bool clearMinLength = false,
    bool clearMaxLength = false,
  }) {
    return FrameConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      header: header ?? this.header,
      footer: footer ?? this.footer,
      checksumType: checksumType ?? this.checksumType,
      checksumStartByte: checksumStartByte ?? this.checksumStartByte,
      checksumEndByte: clearChecksumEndByte
          ? null
          : (checksumEndByte ?? this.checksumEndByte),
      checksumEndianness: checksumEndianness ?? this.checksumEndianness,
      fields: fields ?? this.fields,
      minLength: clearMinLength ? null : (minLength ?? this.minLength),
      maxLength: clearMaxLength ? null : (maxLength ?? this.maxLength),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'header': header,
      'footer': footer,
      'checksumType': checksumType.name,
      'checksumStartByte': checksumStartByte,
      if (checksumEndByte != null) 'checksumEndByte': checksumEndByte,
      'checksumEndianness': checksumEndianness.name,
      'fields': fields.map((f) => f.toJson()).toList(),
      if (minLength != null) 'minLength': minLength,
      if (maxLength != null) 'maxLength': maxLength,
    };
  }

  factory FrameConfig.fromJson(Map<String, dynamic> json) {
    return FrameConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      header:
          (json['header'] as List<dynamic>?)?.map((e) => e as int).toList() ??
          [],
      footer:
          (json['footer'] as List<dynamic>?)?.map((e) => e as int).toList() ??
          [],
      checksumType: ChecksumType.values.firstWhere(
        (t) => t.name == json['checksumType'],
        orElse: () => ChecksumType.none,
      ),
      checksumStartByte: json['checksumStartByte'] as int? ?? 0,
      checksumEndByte: json['checksumEndByte'] as int?,
      checksumEndianness: Endianness.values.firstWhere(
        (e) => e.name == json['checksumEndianness'],
        orElse: () => Endianness.big,
      ),
      fields:
          (json['fields'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => FieldDefinition.fromJson(e))
              .toList() ??
          [],
      minLength: json['minLength'] as int?,
      maxLength: json['maxLength'] as int?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    header,
    footer,
    checksumType,
    checksumStartByte,
    checksumEndByte,
    checksumEndianness,
    fields,
    minLength,
    maxLength,
  ];
}

/// 预定义的帧配置示例
class FrameConfigTemplates {
  FrameConfigTemplates._();

  /// Modbus RTU 响应帧模板
  static FrameConfig modbusRtu({String id = 'modbus_rtu'}) => FrameConfig(
    id: id,
    name: 'Modbus RTU',
    description: 'Modbus RTU 协议帧',
    checksumType: ChecksumType.crc16Modbus,
    checksumStartByte: 0,
    checksumEndianness: Endianness.little,
    fields: [
      const FieldDefinition(
        id: 'slave_addr',
        name: '从机地址',
        startByte: 0,
        dataType: DataType.uint8,
      ),
      const FieldDefinition(
        id: 'func_code',
        name: '功能码',
        startByte: 1,
        dataType: DataType.uint8,
      ),
    ],
  );

  /// 简单帧头帧尾协议模板
  static FrameConfig simpleHeaderFooter({String id = 'simple_hf'}) =>
      FrameConfig(
        id: id,
        name: '帧头帧尾协议',
        description: '固定帧头帧尾的简单协议',
        header: [0xAA, 0x55],
        footer: [0x0D, 0x0A],
        checksumType: ChecksumType.sum8,
        checksumStartByte: 2,
      );
}
