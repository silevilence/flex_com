import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flex_com/features/scripting/domain/script_hook.dart';
import 'package:flex_com/features/scripting/data/hook_binding_data_source.dart';
import 'package:flex_com/features/scripting/data/hook_binding_repository_impl.dart';

void main() {
  late Directory tempDir;
  late IHookBindingDataSource dataSource;
  late HookBindingRepositoryImpl repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hook_binding_test_');

    // 创建自定义的数据源，使用临时目录
    dataSource = _TestHookBindingDataSource(tempDir.path);
    repository = HookBindingRepositoryImpl(dataSource);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('HookBindingJsonDataSource', () {
    test('空文件应返回空列表', () async {
      final bindings = await dataSource.getAllBindings();
      expect(bindings, isEmpty);
    });

    test('应能保存和读取绑定', () async {
      final binding = ScriptHookBinding(
        id: 'test-binding-1',
        scriptId: 'script-1',
        hookType: HookType.rxPreProcessor,
        enabled: true,
        priority: 100,
        createdAt: DateTime.now(),
        description: 'Test binding',
      );

      await dataSource.saveBinding(binding);

      final bindings = await dataSource.getAllBindings();
      expect(bindings.length, 1);
      expect(bindings.first.id, 'test-binding-1');
      expect(bindings.first.scriptId, 'script-1');
      expect(bindings.first.hookType, HookType.rxPreProcessor);
    });

    test('应能更新现有绑定', () async {
      final binding = ScriptHookBinding(
        id: 'test-binding-1',
        scriptId: 'script-1',
        hookType: HookType.rxPreProcessor,
        enabled: true,
        priority: 100,
        createdAt: DateTime.now(),
      );

      await dataSource.saveBinding(binding);

      final updated = binding.copyWith(enabled: false, priority: 50);
      await dataSource.saveBinding(updated);

      final bindings = await dataSource.getAllBindings();
      expect(bindings.length, 1);
      expect(bindings.first.enabled, isFalse);
      expect(bindings.first.priority, 50);
    });

    test('应能删除绑定', () async {
      final binding1 = ScriptHookBinding(
        id: 'binding-1',
        scriptId: 'script-1',
        hookType: HookType.rxPreProcessor,
        createdAt: DateTime.now(),
      );
      final binding2 = ScriptHookBinding(
        id: 'binding-2',
        scriptId: 'script-2',
        hookType: HookType.txPostProcessor,
        createdAt: DateTime.now(),
      );

      await dataSource.saveBinding(binding1);
      await dataSource.saveBinding(binding2);

      await dataSource.deleteBinding('binding-1');

      final bindings = await dataSource.getAllBindings();
      expect(bindings.length, 1);
      expect(bindings.first.id, 'binding-2');
    });

    test('应能按脚本 ID 获取绑定', () async {
      final binding1 = ScriptHookBinding(
        id: 'binding-1',
        scriptId: 'script-1',
        hookType: HookType.rxPreProcessor,
        createdAt: DateTime.now(),
      );
      final binding2 = ScriptHookBinding(
        id: 'binding-2',
        scriptId: 'script-1',
        hookType: HookType.txPostProcessor,
        createdAt: DateTime.now(),
      );
      final binding3 = ScriptHookBinding(
        id: 'binding-3',
        scriptId: 'script-2',
        hookType: HookType.taskHook,
        createdAt: DateTime.now(),
      );

      await dataSource.saveBinding(binding1);
      await dataSource.saveBinding(binding2);
      await dataSource.saveBinding(binding3);

      final script1Bindings = await dataSource.getBindingsByScriptId(
        'script-1',
      );
      expect(script1Bindings.length, 2);
      expect(script1Bindings.every((b) => b.scriptId == 'script-1'), isTrue);
    });

    test('应能按 Hook 类型获取绑定并按优先级排序', () async {
      final binding1 = ScriptHookBinding(
        id: 'binding-1',
        scriptId: 'script-1',
        hookType: HookType.rxPreProcessor,
        priority: 100,
        createdAt: DateTime.now(),
      );
      final binding2 = ScriptHookBinding(
        id: 'binding-2',
        scriptId: 'script-2',
        hookType: HookType.rxPreProcessor,
        priority: 50,
        createdAt: DateTime.now(),
      );
      final binding3 = ScriptHookBinding(
        id: 'binding-3',
        scriptId: 'script-3',
        hookType: HookType.txPostProcessor,
        priority: 10,
        createdAt: DateTime.now(),
      );

      await dataSource.saveBinding(binding1);
      await dataSource.saveBinding(binding2);
      await dataSource.saveBinding(binding3);

      final rxBindings = await dataSource.getBindingsByHookType(
        HookType.rxPreProcessor,
      );
      expect(rxBindings.length, 2);
      // 应按优先级排序（数值小的在前）
      expect(rxBindings.first.priority, 50);
      expect(rxBindings.last.priority, 100);
    });
  });

  group('HookBindingRepositoryImpl', () {
    test('getEnabledBindingsByHookType 应只返回启用的绑定', () async {
      final binding1 = ScriptHookBinding(
        id: 'binding-1',
        scriptId: 'script-1',
        hookType: HookType.replyHook,
        enabled: true,
        priority: 100,
        createdAt: DateTime.now(),
      );
      final binding2 = ScriptHookBinding(
        id: 'binding-2',
        scriptId: 'script-2',
        hookType: HookType.replyHook,
        enabled: false,
        priority: 50,
        createdAt: DateTime.now(),
      );

      await repository.saveBinding(binding1);
      await repository.saveBinding(binding2);

      final enabledBindings = await repository.getEnabledBindingsByHookType(
        HookType.replyHook,
      );
      expect(enabledBindings.length, 1);
      expect(enabledBindings.first.enabled, isTrue);
    });

    test('updateBindingEnabled 应正确更新启用状态', () async {
      final binding = ScriptHookBinding(
        id: 'binding-1',
        scriptId: 'script-1',
        hookType: HookType.taskHook,
        enabled: true,
        createdAt: DateTime.now(),
      );

      await repository.saveBinding(binding);
      await repository.updateBindingEnabled('binding-1', false);

      final bindings = await repository.getAllBindings();
      expect(bindings.first.enabled, isFalse);
    });

    test('updateBindingPriority 应正确更新优先级', () async {
      final binding = ScriptHookBinding(
        id: 'binding-1',
        scriptId: 'script-1',
        hookType: HookType.taskHook,
        priority: 100,
        createdAt: DateTime.now(),
      );

      await repository.saveBinding(binding);
      await repository.updateBindingPriority('binding-1', 10);

      final bindings = await repository.getAllBindings();
      expect(bindings.first.priority, 10);
    });

    test('deleteBindingsByScriptId 应删除脚本的所有绑定', () async {
      final binding1 = ScriptHookBinding(
        id: 'binding-1',
        scriptId: 'script-1',
        hookType: HookType.rxPreProcessor,
        createdAt: DateTime.now(),
      );
      final binding2 = ScriptHookBinding(
        id: 'binding-2',
        scriptId: 'script-1',
        hookType: HookType.txPostProcessor,
        createdAt: DateTime.now(),
      );
      final binding3 = ScriptHookBinding(
        id: 'binding-3',
        scriptId: 'script-2',
        hookType: HookType.taskHook,
        createdAt: DateTime.now(),
      );

      await repository.saveBinding(binding1);
      await repository.saveBinding(binding2);
      await repository.saveBinding(binding3);

      await repository.deleteBindingsByScriptId('script-1');

      final bindings = await repository.getAllBindings();
      expect(bindings.length, 1);
      expect(bindings.first.scriptId, 'script-2');
    });
  });
}

/// 测试用数据源，使用自定义目录
class _TestHookBindingDataSource implements IHookBindingDataSource {
  final String _dirPath;
  static const String _fileName = 'hook_bindings.json';

  _TestHookBindingDataSource(this._dirPath);

  File get _file => File('$_dirPath/$_fileName');

  @override
  Future<List<ScriptHookBinding>> getAllBindings() async {
    try {
      if (!await _file.exists()) {
        return [];
      }

      final content = await _file.readAsString();
      if (content.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(content) as List<dynamic>;
      return jsonList
          .map((e) => ScriptHookBinding.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveBinding(ScriptHookBinding binding) async {
    final bindings = await getAllBindings();
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

    if (!await _file.parent.exists()) {
      await _file.parent.create(recursive: true);
    }

    await _file.writeAsString(content);
  }
}
