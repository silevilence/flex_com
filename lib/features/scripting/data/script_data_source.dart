import 'dart:convert';
import 'dart:io';
import '../../../core/utils/app_paths.dart';
import '../domain/script_entity.dart';

/// 脚本DTO（Data Transfer Object）
class ScriptDto {
  final String id;
  final String name;
  final String content;
  final String? description;
  final String createdAt;
  final String updatedAt;
  final bool isEnabled;

  const ScriptDto({
    required this.id,
    required this.name,
    required this.content,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.isEnabled,
  });

  /// 从JSON创建
  factory ScriptDto.fromJson(Map<String, dynamic> json) {
    return ScriptDto(
      id: json['id'] as String,
      name: json['name'] as String,
      content: json['content'] as String,
      description: json['description'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  /// 转为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'content': content,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isEnabled': isEnabled,
    };
  }

  /// 从实体转换
  factory ScriptDto.fromEntity(ScriptEntity entity) {
    return ScriptDto(
      id: entity.id,
      name: entity.name,
      content: entity.content,
      description: entity.description,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
      isEnabled: entity.isEnabled,
    );
  }

  /// 转为实体
  ScriptEntity toEntity() {
    return ScriptEntity(
      id: id,
      name: name,
      content: content,
      description: description,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      isEnabled: isEnabled,
    );
  }
}

/// 脚本JSON数据源
class ScriptJsonDataSource {
  static const String _fileName = 'scripts.json';

  /// 自定义目录路径（用于测试）
  final String? customDir;

  ScriptJsonDataSource({this.customDir});

  /// 获取脚本文件路径
  Future<String> _getScriptsFilePath() async {
    final String dir;
    if (customDir != null) {
      dir = customDir!;
    } else {
      dir = await AppPaths.getConfigDir();
    }
    return '$dir${Platform.pathSeparator}$_fileName';
  }

  /// 读取所有脚本
  Future<List<ScriptDto>> readScripts() async {
    try {
      final filePath = await _getScriptsFilePath();
      final file = File(filePath);

      if (!await file.exists()) {
        return [];
      }

      final content = await file.readAsString();
      if (content.isEmpty) {
        return [];
      }

      final json = jsonDecode(content) as Map<String, dynamic>;
      final scriptsJson = json['scripts'] as List<dynamic>?;

      if (scriptsJson == null) {
        return [];
      }

      return scriptsJson
          .map((item) => ScriptDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to read scripts: $e');
    }
  }

  /// 写入所有脚本
  Future<void> writeScripts(List<ScriptDto> scripts) async {
    try {
      final filePath = await _getScriptsFilePath();
      final file = File(filePath);

      // 确保目录存在
      await file.parent.create(recursive: true);

      final json = {
        'scripts': scripts.map((script) => script.toJson()).toList(),
      };

      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(json),
      );
    } catch (e) {
      throw Exception('Failed to write scripts: $e');
    }
  }
}
