import 'dart:convert';
import 'dart:io';

import '../../../core/utils/app_paths.dart';
import '../domain/frame_config.dart';

/// 帧配置仓库
///
/// 负责帧配置的持久化存储和读取
class FrameConfigRepository {
  FrameConfigRepository._();

  static final FrameConfigRepository instance = FrameConfigRepository._();

  static const String _fileName = 'frame_configs.json';

  /// 加载所有帧配置
  Future<List<FrameConfig>> loadConfigs() async {
    try {
      final file = File(await _getFilePath());
      if (!await file.exists()) {
        return [];
      }

      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final configsList = json['configs'] as List<dynamic>?;

      if (configsList == null) return [];

      return configsList
          .whereType<Map<String, dynamic>>()
          .map((e) => FrameConfig.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 保存所有帧配置
  Future<void> saveConfigs(List<FrameConfig> configs) async {
    try {
      final file = File(await _getFilePath());
      final parent = file.parent;
      if (!await parent.exists()) {
        await parent.create(recursive: true);
      }

      final json = {'configs': configs.map((c) => c.toJson()).toList()};

      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 添加配置
  Future<void> addConfig(FrameConfig config) async {
    final configs = await loadConfigs();
    configs.add(config);
    await saveConfigs(configs);
  }

  /// 更新配置
  Future<void> updateConfig(FrameConfig config) async {
    final configs = await loadConfigs();
    final index = configs.indexWhere((c) => c.id == config.id);
    if (index >= 0) {
      configs[index] = config;
      await saveConfigs(configs);
    }
  }

  /// 删除配置
  Future<void> deleteConfig(String configId) async {
    final configs = await loadConfigs();
    configs.removeWhere((c) => c.id == configId);
    await saveConfigs(configs);
  }

  /// 导出配置为 JSON 字符串
  String exportConfig(FrameConfig config) {
    return const JsonEncoder.withIndent('  ').convert(config.toJson());
  }

  /// 从 JSON 字符串导入配置
  FrameConfig? importConfig(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return FrameConfig.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Future<String> _getFilePath() async {
    final appDir = await AppPaths.getConfigDir();
    return '$appDir/$_fileName';
  }
}
