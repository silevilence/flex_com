import 'dart:convert';
import 'dart:io';

import '../../../core/utils/app_paths.dart';
import '../domain/script_hook.dart';

/// Hook 绑定数据源接口
abstract class IHookBindingDataSource {
  /// 获取所有 Hook 绑定
  Future<List<ScriptHookBinding>> getAllBindings();

  /// 保存 Hook 绑定
  Future<void> saveBinding(ScriptHookBinding binding);

  /// 删除 Hook 绑定
  Future<void> deleteBinding(String bindingId);

  /// 保存所有绑定
  Future<void> saveAllBindings(List<ScriptHookBinding> bindings);

  /// 根据脚本 ID 获取绑定
  Future<List<ScriptHookBinding>> getBindingsByScriptId(String scriptId);

  /// 根据 Hook 类型获取绑定
  Future<List<ScriptHookBinding>> getBindingsByHookType(HookType hookType);
}

/// Hook 绑定 JSON 数据源实现
class HookBindingJsonDataSource implements IHookBindingDataSource {
  static const String _fileName = 'hook_bindings.json';

  Future<File> get _file async {
    final configDir = await AppPaths.getConfigDir();
    return File('$configDir/$_fileName');
  }

  @override
  Future<List<ScriptHookBinding>> getAllBindings() async {
    try {
      final file = await _file;
      if (!await file.exists()) {
        return [];
      }

      final content = await file.readAsString();
      if (content.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(content) as List<dynamic>;
      return jsonList
          .map((e) => ScriptHookBinding.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // 如果解析失败，返回空列表
      return [];
    }
  }

  @override
  Future<void> saveBinding(ScriptHookBinding binding) async {
    final bindings = await getAllBindings();

    // 查找是否已存在
    final existingIndex = bindings.indexWhere((b) => b.id == binding.id);
    if (existingIndex >= 0) {
      bindings[existingIndex] = binding;
    } else {
      bindings.add(binding);
    }

    await _saveToFile(bindings);
  }

  @override
  Future<void> deleteBinding(String bindingId) async {
    final bindings = await getAllBindings();
    bindings.removeWhere((b) => b.id == bindingId);
    await _saveToFile(bindings);
  }

  @override
  Future<void> saveAllBindings(List<ScriptHookBinding> bindings) async {
    await _saveToFile(bindings);
  }

  @override
  Future<List<ScriptHookBinding>> getBindingsByScriptId(String scriptId) async {
    final bindings = await getAllBindings();
    return bindings.where((b) => b.scriptId == scriptId).toList();
  }

  @override
  Future<List<ScriptHookBinding>> getBindingsByHookType(
    HookType hookType,
  ) async {
    final bindings = await getAllBindings();
    return bindings.where((b) => b.hookType == hookType).toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));
  }

  Future<void> _saveToFile(List<ScriptHookBinding> bindings) async {
    final jsonList = bindings.map((b) => b.toJson()).toList();
    final content = const JsonEncoder.withIndent('  ').convert(jsonList);

    final file = await _file;
    // 确保目录存在
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }

    await file.writeAsString(content);
  }
}
