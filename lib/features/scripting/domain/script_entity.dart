import 'package:equatable/equatable.dart';

/// 脚本实体
class ScriptEntity extends Equatable {
  /// 脚本唯一ID
  final String id;

  /// 脚本名称
  final String name;

  /// 脚本内容（Lua代码）
  final String content;

  /// 脚本描述
  final String? description;

  /// 创建时间
  final DateTime createdAt;

  /// 最后修改时间
  final DateTime updatedAt;

  /// 是否启用
  final bool isEnabled;

  const ScriptEntity({
    required this.id,
    required this.name,
    required this.content,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.isEnabled = true,
  });

  /// 创建空脚本
  factory ScriptEntity.empty() {
    final now = DateTime.now();
    return ScriptEntity(
      id: '',
      name: 'New Script',
      content: '',
      createdAt: now,
      updatedAt: now,
      isEnabled: true,
    );
  }

  /// 复制并修改
  ScriptEntity copyWith({
    String? id,
    String? name,
    String? content,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEnabled,
  }) {
    return ScriptEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      content: content ?? this.content,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    content,
    description,
    createdAt,
    updatedAt,
    isEnabled,
  ];
}
