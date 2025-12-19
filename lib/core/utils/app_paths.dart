import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// 应用程序路径管理工具
///
/// 提供统一的配置文件路径获取方法，确保配置文件存储在
/// 正确的用户数据目录中，避免权限问题。
class AppPaths {
  AppPaths._();

  static String? _cachedConfigDir;
  static bool _migrationChecked = false;

  /// 获取配置文件目录
  ///
  /// 在 Windows 上返回: %APPDATA%\com.example\flex_com
  /// 在 macOS 上返回: ~/Library/Application Support/com.example.flex_com
  /// 在 Linux 上返回: ~/.local/share/com.example.flex_com
  static Future<String> getConfigDir() async {
    if (_cachedConfigDir != null) {
      return _cachedConfigDir!;
    }

    final appSupportDir = await getApplicationSupportDirectory();
    final configDir = appSupportDir;

    // 确保目录存在
    if (!await configDir.exists()) {
      await configDir.create(recursive: true);
    }

    _cachedConfigDir = configDir.path;

    // 执行一次性迁移检查
    if (!_migrationChecked) {
      _migrationChecked = true;
      await _migrateOldConfigFiles();
    }

    return _cachedConfigDir!;
  }

  /// 迁移旧版本配置文件
  ///
  /// 旧版本将配置保存在 FlexCom 子目录下，需要迁移到根目录
  static Future<void> _migrateOldConfigFiles() async {
    if (_cachedConfigDir == null) return;

    final oldDir = Directory(
      '$_cachedConfigDir${Platform.pathSeparator}FlexCom',
    );
    if (!await oldDir.exists()) return;

    // ignore: avoid_print
    print('[AppPaths] 发现旧配置目录，开始迁移...');

    // 迁移 config.json
    final oldConfigFile = File(
      '${oldDir.path}${Platform.pathSeparator}config.json',
    );
    final newConfigFile = File(
      '$_cachedConfigDir${Platform.pathSeparator}config.json',
    );
    if (await oldConfigFile.exists() && !await newConfigFile.exists()) {
      await oldConfigFile.copy(newConfigFile.path);
      // ignore: avoid_print
      print('[AppPaths] 已迁移 config.json');
    }

    // 迁移 commands.json
    final oldCommandsFile = File(
      '${oldDir.path}${Platform.pathSeparator}commands.json',
    );
    final newCommandsFile = File(
      '$_cachedConfigDir${Platform.pathSeparator}commands.json',
    );
    if (await oldCommandsFile.exists() && !await newCommandsFile.exists()) {
      await oldCommandsFile.copy(newCommandsFile.path);
      // ignore: avoid_print
      print('[AppPaths] 已迁移 commands.json');
    }

    // 删除旧目录（可选，保留以防万一）
    // await oldDir.delete(recursive: true);
  }

  /// 获取主配置文件路径 (config.json)
  ///
  /// 存储串口配置、自动回复配置等
  static Future<String> getConfigFilePath() async {
    final configDir = await getConfigDir();
    return '$configDir${Platform.pathSeparator}config.json';
  }

  /// 获取指令列表文件路径 (commands.json)
  static Future<String> getCommandsFilePath() async {
    final configDir = await getConfigDir();
    return '$configDir${Platform.pathSeparator}commands.json';
  }

  /// 清除缓存的目录路径（主要用于测试）
  static void clearCache() {
    _cachedConfigDir = null;
  }
}
