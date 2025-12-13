import 'package:equatable/equatable.dart';

/// 数据模式枚举
///
/// 用于指定触发模式和响应数据的编码方式
enum DataMode {
  /// 十六进制模式
  hex,

  /// ASCII 文本模式
  ascii;

  /// UI 显示名称
  String get displayName {
    switch (this) {
      case DataMode.hex:
        return 'HEX';
      case DataMode.ascii:
        return 'ASCII';
    }
  }
}

/// 匹配回复规则
///
/// 定义单条匹配规则，包含触发条件和响应内容
class MatchReplyRule extends Equatable {
  const MatchReplyRule({
    required this.id,
    required this.name,
    required this.triggerPattern,
    required this.responseData,
    this.triggerMode = DataMode.hex,
    this.responseMode = DataMode.hex,
    this.enabled = true,
  });

  /// 规则唯一标识符
  final String id;

  /// 规则名称（用于 UI 显示）
  final String name;

  /// 触发模式（包含匹配的数据）
  final String triggerPattern;

  /// 触发数据的编码模式
  final DataMode triggerMode;

  /// 响应数据
  final String responseData;

  /// 响应数据的编码模式
  final DataMode responseMode;

  /// 是否启用此规则
  final bool enabled;

  /// 创建副本并更新指定字段
  MatchReplyRule copyWith({
    String? id,
    String? name,
    String? triggerPattern,
    DataMode? triggerMode,
    String? responseData,
    DataMode? responseMode,
    bool? enabled,
  }) {
    return MatchReplyRule(
      id: id ?? this.id,
      name: name ?? this.name,
      triggerPattern: triggerPattern ?? this.triggerPattern,
      triggerMode: triggerMode ?? this.triggerMode,
      responseData: responseData ?? this.responseData,
      responseMode: responseMode ?? this.responseMode,
      enabled: enabled ?? this.enabled,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'triggerPattern': triggerPattern,
      'triggerMode': triggerMode.name,
      'responseData': responseData,
      'responseMode': responseMode.name,
      'enabled': enabled,
    };
  }

  /// 从 JSON 创建
  factory MatchReplyRule.fromJson(Map<String, dynamic> json) {
    return MatchReplyRule(
      id: json['id'] as String,
      name: json['name'] as String,
      triggerPattern: json['triggerPattern'] as String,
      triggerMode: DataMode.values.firstWhere(
        (m) => m.name == json['triggerMode'],
        orElse: () => DataMode.hex,
      ),
      responseData: json['responseData'] as String,
      responseMode: DataMode.values.firstWhere(
        (m) => m.name == json['responseMode'],
        orElse: () => DataMode.hex,
      ),
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    triggerPattern,
    triggerMode,
    responseData,
    responseMode,
    enabled,
  ];
}

/// 匹配回复模式配置
///
/// 包含所有匹配规则的配置容器
class MatchReplyConfig extends Equatable {
  const MatchReplyConfig({this.rules = const []});

  /// 匹配规则列表
  final List<MatchReplyRule> rules;

  /// 创建副本并更新指定字段
  MatchReplyConfig copyWith({List<MatchReplyRule>? rules}) {
    return MatchReplyConfig(rules: rules ?? this.rules);
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {'rules': rules.map((r) => r.toJson()).toList()};
  }

  /// 从 JSON 创建
  factory MatchReplyConfig.fromJson(Map<String, dynamic> json) {
    final rulesList = json['rules'] as List<dynamic>?;
    return MatchReplyConfig(
      rules:
          rulesList
              ?.whereType<Map<String, dynamic>>()
              .map((e) => MatchReplyRule.fromJson(e))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [rules];
}
