import 'dart:convert';
import 'dart:io';

import '../../../core/utils/app_paths.dart';
import '../domain/chart_types.dart';

/// 示波器配置仓库
///
/// 负责示波器配置的持久化存储和读取
class OscilloscopeConfigRepository {
  OscilloscopeConfigRepository._();

  static final OscilloscopeConfigRepository instance =
      OscilloscopeConfigRepository._();

  static const String _fileName = 'oscilloscope_config.json';

  /// 加载配置
  Future<OscilloscopeConfig> loadConfig() async {
    try {
      final file = File(await _getFilePath());
      if (!await file.exists()) {
        return const OscilloscopeConfig();
      }

      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return OscilloscopeConfig.fromJson(json);
    } catch (e) {
      return const OscilloscopeConfig();
    }
  }

  /// 保存配置
  Future<void> saveConfig(OscilloscopeConfig config) async {
    try {
      final file = File(await _getFilePath());
      final parent = file.parent;
      if (!await parent.exists()) {
        await parent.create(recursive: true);
      }

      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(config.toJson()),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<String> _getFilePath() async {
    final appDir = await AppPaths.getConfigDir();
    return '$appDir/$_fileName';
  }
}
