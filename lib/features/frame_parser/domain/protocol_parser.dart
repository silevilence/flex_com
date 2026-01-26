import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import 'frame_config.dart';
import 'parser_types.dart';

/// 解析后的字段值
///
/// 包含字段的原始字节数据和解析后的值
class ParsedField extends Equatable {
  const ParsedField({
    required this.definition,
    required this.rawBytes,
    required this.value,
    this.displayValue,
  });

  /// 字段定义
  final FieldDefinition definition;

  /// 原始字节数据
  final Uint8List rawBytes;

  /// 解析后的值（可能是 int, double, String, Uint8List 等）
  final dynamic value;

  /// 显示值（应用了比例因子和偏移量后的值，带单位）
  final String? displayValue;

  @override
  List<Object?> get props => [definition, rawBytes, value, displayValue];
}

/// 解析结果
///
/// 包含帧解析的完整结果
class ParsedFrame extends Equatable {
  const ParsedFrame({
    required this.config,
    required this.rawData,
    required this.fields,
    this.isValid = true,
    this.checksumValid,
    this.errorMessage,
  });

  /// 使用的帧配置
  final FrameConfig config;

  /// 原始帧数据
  final Uint8List rawData;

  /// 解析后的字段列表
  final List<ParsedField> fields;

  /// 帧是否有效
  final bool isValid;

  /// 校验是否通过（null 表示无校验）
  final bool? checksumValid;

  /// 错误信息
  final String? errorMessage;

  /// 获取指定字段的值
  ParsedField? getField(String fieldId) {
    try {
      return fields.firstWhere((f) => f.definition.id == fieldId);
    } catch (_) {
      return null;
    }
  }

  /// 获取所有字段的键值对映射
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    for (final field in fields) {
      map[field.definition.id] = field.value;
    }
    return map;
  }

  @override
  List<Object?> get props => [
    config,
    rawData,
    fields,
    isValid,
    checksumValid,
    errorMessage,
  ];
}

/// 协议解析器接口
///
/// 所有协议解析器必须实现此接口。
/// 设计要点：
/// - 新增协议只需实现此接口
/// - 解析器可以是无状态的（单帧解析）或有状态的（多帧组装）
abstract class IProtocolParser {
  /// 解析器名称
  String get name;

  /// 解析器描述
  String get description;

  /// 解析帧数据
  ///
  /// [data] 原始字节数据
  /// [config] 帧配置（可选，某些解析器可能使用内置配置）
  /// 返回 [ParsedFrame] 解析结果
  ParsedFrame parse(Uint8List data, {FrameConfig? config});

  /// 验证帧数据是否符合配置
  ///
  /// [data] 原始字节数据
  /// [config] 帧配置
  /// 返回是否有效
  bool validate(Uint8List data, FrameConfig config);

  /// 从数据流中查找帧
  ///
  /// [buffer] 数据缓冲区
  /// [config] 帧配置
  /// 返回找到的帧起始和结束索引，未找到返回 null
  ({int start, int end})? findFrame(Uint8List buffer, FrameConfig config);
}
