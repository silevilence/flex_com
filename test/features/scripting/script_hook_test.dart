import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flex_com/features/scripting/domain/script_hook.dart';

void main() {
  group('HookType', () {
    test('应有正确的显示名称', () {
      expect(HookType.rxPreProcessor.displayName, 'Rx 预处理器');
      expect(HookType.txPostProcessor.displayName, 'Tx 后处理器');
      expect(HookType.replyHook.displayName, '脚本回复');
      expect(HookType.taskHook.displayName, '手动任务');
    });

    test('应有正确的描述', () {
      expect(HookType.rxPreProcessor.description, contains('接收'));
      expect(HookType.txPostProcessor.description, contains('发送'));
      expect(HookType.replyHook.description, contains('脚本'));
      expect(HookType.taskHook.description, contains('手动'));
    });
  });

  group('HookExecutionResult', () {
    test('success 工厂方法应正确创建成功结果', () {
      final result = HookExecutionResult.success(
        processedData: Uint8List.fromList([1, 2, 3]),
        durationMs: 100,
      );

      expect(result.success, isTrue);
      expect(result.processedData, isNotNull);
      expect(result.durationMs, 100);
      expect(result.shouldContinue, isTrue);
    });

    test('failure 工厂方法应正确创建失败结果', () {
      final result = HookExecutionResult.failure(
        errorMessage: 'Test error',
        durationMs: 50,
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, 'Test error');
      expect(result.durationMs, 50);
      expect(result.shouldContinue, isFalse);
    });

    test('skip 工厂方法应正确创建跳过结果', () {
      final result = HookExecutionResult.skip(durationMs: 10);

      expect(result.success, isTrue);
      expect(result.shouldContinue, isFalse);
      expect(result.durationMs, 10);
    });
  });

  group('ScriptHookBinding', () {
    test('应正确创建绑定', () {
      final binding = ScriptHookBinding(
        id: 'binding-1',
        scriptId: 'script-1',
        hookType: HookType.rxPreProcessor,
        enabled: true,
        priority: 50,
        createdAt: DateTime(2024, 1, 1),
        description: 'Test binding',
      );

      expect(binding.id, 'binding-1');
      expect(binding.scriptId, 'script-1');
      expect(binding.hookType, HookType.rxPreProcessor);
      expect(binding.enabled, isTrue);
      expect(binding.priority, 50);
      expect(binding.description, 'Test binding');
    });

    test('copyWith 应正确复制并修改', () {
      final binding = ScriptHookBinding(
        id: 'binding-1',
        scriptId: 'script-1',
        hookType: HookType.rxPreProcessor,
        enabled: true,
        priority: 100,
        createdAt: DateTime(2024, 1, 1),
      );

      final modified = binding.copyWith(enabled: false, priority: 50);

      expect(modified.id, 'binding-1');
      expect(modified.enabled, isFalse);
      expect(modified.priority, 50);
    });

    test('toJson 和 fromJson 应正确序列化', () {
      final binding = ScriptHookBinding(
        id: 'binding-1',
        scriptId: 'script-1',
        hookType: HookType.txPostProcessor,
        enabled: true,
        priority: 100,
        createdAt: DateTime(2024, 1, 1, 12, 0, 0),
        description: 'Test',
      );

      final json = binding.toJson();
      final restored = ScriptHookBinding.fromJson(json);

      expect(restored.id, binding.id);
      expect(restored.scriptId, binding.scriptId);
      expect(restored.hookType, binding.hookType);
      expect(restored.enabled, binding.enabled);
      expect(restored.priority, binding.priority);
      expect(restored.description, binding.description);
    });

    test('fromJson 应处理缺失字段', () {
      final json = <String, dynamic>{
        'id': 'binding-1',
        'scriptId': 'script-1',
        'hookType': 'replyHook',
      };

      final binding = ScriptHookBinding.fromJson(json);

      expect(binding.enabled, isTrue);
      expect(binding.priority, 100);
      expect(binding.description, isNull);
    });

    test('Equatable 应正确比较对象', () {
      final binding1 = ScriptHookBinding(
        id: 'binding-1',
        scriptId: 'script-1',
        hookType: HookType.taskHook,
        createdAt: DateTime(2024, 1, 1),
      );

      final binding2 = ScriptHookBinding(
        id: 'binding-1',
        scriptId: 'script-1',
        hookType: HookType.taskHook,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(binding1, equals(binding2));
    });
  });

  group('PipelineHookContext', () {
    test('应正确创建上下文', () {
      final data = Uint8List.fromList([0x01, 0x02, 0x03]);
      final timestamp = DateTime.now();

      final context = PipelineHookContext(
        rawData: data,
        isRx: true,
        timestamp: timestamp,
      );

      expect(context.rawData, data);
      expect(context.isRx, isTrue);
      expect(context.timestamp, timestamp);
    });
  });

  group('ReplyHookContext', () {
    test('应正确创建上下文', () {
      final data = Uint8List.fromList([0xAA, 0xBB]);
      final timestamp = DateTime.now();

      final context = ReplyHookContext(
        receivedData: data,
        timestamp: timestamp,
        globalDelayMs: 100,
      );

      expect(context.receivedData, data);
      expect(context.timestamp, timestamp);
      expect(context.globalDelayMs, 100);
    });

    test('globalDelayMs 应有默认值', () {
      final context = ReplyHookContext(
        receivedData: Uint8List(0),
        timestamp: DateTime.now(),
      );

      expect(context.globalDelayMs, 0);
    });
  });

  group('TaskHookConfig', () {
    test('应有正确的默认值', () {
      const config = TaskHookConfig();

      expect(config.showInToolbar, isFalse);
      expect(config.shortcutKey, isNull);
      expect(config.confirmBeforeRun, isFalse);
    });

    test('toJson 和 fromJson 应正确序列化', () {
      const config = TaskHookConfig(
        showInToolbar: true,
        shortcutKey: 'Ctrl+T',
        confirmBeforeRun: true,
      );

      final json = config.toJson();
      final restored = TaskHookConfig.fromJson(json);

      expect(restored.showInToolbar, isTrue);
      expect(restored.shortcutKey, 'Ctrl+T');
      expect(restored.confirmBeforeRun, isTrue);
    });

    test('Equatable 应正确比较对象', () {
      const config1 = TaskHookConfig(showInToolbar: true);
      const config2 = TaskHookConfig(showInToolbar: true);
      const config3 = TaskHookConfig(showInToolbar: false);

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });
  });
}
