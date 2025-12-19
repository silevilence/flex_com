import 'dart:convert';
import 'dart:io';

import '../../../core/utils/app_paths.dart';
import '../domain/auto_reply_config.dart';
import '../domain/match_reply_config.dart';
import '../domain/sequential_reply_config.dart';

/// 自动回复配置的完整数据包
///
/// 用于一次性加载所有配置
class AutoReplyAllConfigs {
  const AutoReplyAllConfigs({
    required this.globalConfig,
    required this.matchReplyConfig,
    required this.sequentialReplyConfig,
  });

  /// 全局配置
  final AutoReplyConfig globalConfig;

  /// 匹配回复配置
  final MatchReplyConfig matchReplyConfig;

  /// 顺序回复配置
  final SequentialReplyConfig sequentialReplyConfig;
}

/// 自动回复配置服务
///
/// 负责将自动回复相关的所有配置持久化到 config.json 文件中。
/// 配置结构：
/// ```json
/// {
///   "serialPort": { ... },
///   "autoReply": {
///     "global": { "enabled": false, "globalDelayMs": 0, "activeMode": "matchReply" },
///     "matchReply": { "rules": [...] },
///     "sequentialReply": { "frames": [...], "currentIndex": 0, "loopEnabled": false }
///   }
/// }
/// ```
class AutoReplyConfigService {
  AutoReplyConfigService({String? configPath}) : _configPath = configPath;

  final String? _configPath;
  String? _cachedConfigPath;

  /// 获取配置文件路径
  Future<String> getConfigFilePath() async {
    if (_configPath != null) {
      return _configPath;
    }
    _cachedConfigPath ??= await AppPaths.getConfigFilePath();
    return _cachedConfigPath!;
  }

  /// 读取完整的配置文件内容
  Future<Map<String, dynamic>> _readConfigFile() async {
    try {
      final configPath = await getConfigFilePath();
      final file = File(configPath);
      if (!await file.exists()) {
        return {};
      }
      final contents = await file.readAsString();
      return jsonDecode(contents) as Map<String, dynamic>;
    } catch (e) {
      // 文件不存在或解析失败，返回空配置
      return {};
    }
  }

  /// 写入完整的配置文件内容
  Future<bool> _writeConfigFile(Map<String, dynamic> config) async {
    try {
      final configPath = await getConfigFilePath();
      final file = File(configPath);
      final encoder = const JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(config));
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Failed to save config: $e');
      return false;
    }
  }

  /// 获取 autoReply 配置节点
  Map<String, dynamic> _getAutoReplySection(Map<String, dynamic> config) {
    return config['autoReply'] as Map<String, dynamic>? ?? {};
  }

  /// 加载全局配置
  Future<AutoReplyConfig> loadGlobalConfig() async {
    final config = await _readConfigFile();
    final autoReply = _getAutoReplySection(config);
    final globalSection = autoReply['global'] as Map<String, dynamic>?;

    if (globalSection == null) {
      return const AutoReplyConfig();
    }
    return AutoReplyConfig.fromJson(globalSection);
  }

  /// 保存全局配置
  Future<bool> saveGlobalConfig(AutoReplyConfig config) async {
    final fullConfig = await _readConfigFile();
    final autoReply = _getAutoReplySection(fullConfig);

    autoReply['global'] = config.toJson();
    fullConfig['autoReply'] = autoReply;

    return _writeConfigFile(fullConfig);
  }

  /// 加载匹配回复配置
  Future<MatchReplyConfig> loadMatchReplyConfig() async {
    final config = await _readConfigFile();
    final autoReply = _getAutoReplySection(config);
    final matchSection = autoReply['matchReply'] as Map<String, dynamic>?;

    if (matchSection == null) {
      return const MatchReplyConfig();
    }
    return MatchReplyConfig.fromJson(matchSection);
  }

  /// 保存匹配回复配置
  Future<bool> saveMatchReplyConfig(MatchReplyConfig config) async {
    final fullConfig = await _readConfigFile();
    final autoReply = _getAutoReplySection(fullConfig);

    autoReply['matchReply'] = config.toJson();
    fullConfig['autoReply'] = autoReply;

    return _writeConfigFile(fullConfig);
  }

  /// 加载顺序回复配置
  Future<SequentialReplyConfig> loadSequentialReplyConfig() async {
    final config = await _readConfigFile();
    final autoReply = _getAutoReplySection(config);
    final seqSection = autoReply['sequentialReply'] as Map<String, dynamic>?;

    if (seqSection == null) {
      return const SequentialReplyConfig();
    }
    return SequentialReplyConfig.fromJson(seqSection);
  }

  /// 保存顺序回复配置
  Future<bool> saveSequentialReplyConfig(SequentialReplyConfig config) async {
    final fullConfig = await _readConfigFile();
    final autoReply = _getAutoReplySection(fullConfig);

    autoReply['sequentialReply'] = config.toJson();
    fullConfig['autoReply'] = autoReply;

    return _writeConfigFile(fullConfig);
  }

  /// 一次性加载所有自动回复配置
  Future<AutoReplyAllConfigs> loadAllConfigs() async {
    final config = await _readConfigFile();
    final autoReply = _getAutoReplySection(config);

    final globalSection = autoReply['global'] as Map<String, dynamic>?;
    final matchSection = autoReply['matchReply'] as Map<String, dynamic>?;
    final seqSection = autoReply['sequentialReply'] as Map<String, dynamic>?;

    return AutoReplyAllConfigs(
      globalConfig: globalSection != null
          ? AutoReplyConfig.fromJson(globalSection)
          : const AutoReplyConfig(),
      matchReplyConfig: matchSection != null
          ? MatchReplyConfig.fromJson(matchSection)
          : const MatchReplyConfig(),
      sequentialReplyConfig: seqSection != null
          ? SequentialReplyConfig.fromJson(seqSection)
          : const SequentialReplyConfig(),
    );
  }

  /// 一次性保存所有自动回复配置
  Future<bool> saveAllConfigs(AutoReplyAllConfigs configs) async {
    final fullConfig = await _readConfigFile();

    fullConfig['autoReply'] = {
      'global': configs.globalConfig.toJson(),
      'matchReply': configs.matchReplyConfig.toJson(),
      'sequentialReply': configs.sequentialReplyConfig.toJson(),
    };

    return _writeConfigFile(fullConfig);
  }
}
