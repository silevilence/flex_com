import 'package:equatable/equatable.dart';

import '../../serial/domain/serial_data_entry.dart';

/// 表示一条预设指令
///
/// 每条指令包含名称、数据内容、发送模式等信息，
/// 可用于快速发送预设的串口数据。
class Command extends Equatable {
  Command({
    required this.id,
    required this.name,
    required this.data,
    this.mode = DataDisplayMode.hex,
    this.description = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// 唯一标识符
  final String id;

  /// 指令名称
  final String name;

  /// 指令数据（HEX 字符串或 ASCII 文本）
  final String data;

  /// 发送模式
  final DataDisplayMode mode;

  /// 描述信息（可选）
  final String description;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  /// 创建新指令
  factory Command.create({
    required String name,
    required String data,
    DataDisplayMode mode = DataDisplayMode.hex,
    String description = '',
  }) {
    final now = DateTime.now();
    return Command(
      id: _generateId(),
      name: name,
      data: data,
      mode: mode,
      description: description,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 从 JSON 创建
  factory Command.fromJson(Map<String, dynamic> json) {
    return Command(
      id: json['id'] as String,
      name: json['name'] as String,
      data: json['data'] as String,
      mode: DataDisplayMode.values.firstWhere(
        (e) => e.name == json['mode'],
        orElse: () => DataDisplayMode.hex,
      ),
      description: json['description'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'data': data,
      'mode': mode.name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 复制并修改
  Command copyWith({
    String? id,
    String? name,
    String? data,
    DataDisplayMode? mode,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Command(
      id: id ?? this.id,
      name: name ?? this.name,
      data: data ?? this.data,
      mode: mode ?? this.mode,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// 自增计数器用于确保 ID 唯一性
  static int _idCounter = 0;

  /// 生成唯一 ID
  static String _generateId() {
    final now = DateTime.now();
    _idCounter++;
    return '${now.millisecondsSinceEpoch}_${now.microsecond}_$_idCounter';
  }

  @override
  List<Object?> get props => [id, name, data, mode, description];
}
