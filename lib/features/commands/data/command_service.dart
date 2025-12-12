import 'dart:convert';
import 'dart:io';

import '../domain/command.dart';

/// 指令存储服务
///
/// 将用户的预设指令列表保存到 JSON 文件中，
/// 支持增删改查操作。
class CommandService {
  CommandService({String? commandsPath}) : _commandsPath = commandsPath;

  final String? _commandsPath;

  /// 获取指令文件路径
  String get commandsFilePath {
    if (_commandsPath != null) {
      return _commandsPath;
    }
    // 获取可执行文件所在目录
    final executablePath = Platform.resolvedExecutable;
    final executableDir = File(executablePath).parent.path;
    return '$executableDir${Platform.pathSeparator}commands.json';
  }

  /// 加载所有指令
  Future<List<Command>> loadCommands() async {
    try {
      final file = File(commandsFilePath);
      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();
      final json = jsonDecode(contents);

      if (json is! Map<String, dynamic>) {
        return [];
      }

      final commandsList = json['commands'] as List<dynamic>?;
      if (commandsList == null) {
        return [];
      }

      return commandsList
          .whereType<Map<String, dynamic>>()
          .map((e) => Command.fromJson(e))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('Failed to load commands: $e');
      return [];
    }
  }

  /// 保存所有指令
  Future<bool> saveCommands(List<Command> commands) async {
    try {
      final file = File(commandsFilePath);

      final data = {
        'version': 1,
        'commands': commands.map((e) => e.toJson()).toList(),
      };

      final encoder = const JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(data));

      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Failed to save commands: $e');
      return false;
    }
  }

  /// 添加指令
  Future<bool> addCommand(Command command) async {
    final commands = await loadCommands();
    commands.add(command);
    return saveCommands(commands);
  }

  /// 更新指令
  Future<bool> updateCommand(Command command) async {
    final commands = await loadCommands();
    final index = commands.indexWhere((e) => e.id == command.id);
    if (index == -1) {
      return false;
    }
    commands[index] = command;
    return saveCommands(commands);
  }

  /// 删除指令
  Future<bool> deleteCommand(String id) async {
    final commands = await loadCommands();
    final initialLength = commands.length;
    commands.removeWhere((e) => e.id == id);
    if (commands.length == initialLength) {
      return false; // 没有找到要删除的指令
    }
    return saveCommands(commands);
  }

  /// 根据 ID 获取指令
  Future<Command?> getCommand(String id) async {
    final commands = await loadCommands();
    try {
      return commands.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 检查指令文件是否存在
  Future<bool> commandsFileExists() async {
    final file = File(commandsFilePath);
    return file.exists();
  }

  /// 重新排序指令
  Future<bool> reorderCommands(int oldIndex, int newIndex) async {
    final commands = await loadCommands();
    if (oldIndex < 0 ||
        oldIndex >= commands.length ||
        newIndex < 0 ||
        newIndex >= commands.length) {
      return false;
    }

    final command = commands.removeAt(oldIndex);
    commands.insert(newIndex, command);
    return saveCommands(commands);
  }
}
