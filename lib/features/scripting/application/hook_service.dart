import 'dart:async';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../connection/application/connection_providers.dart';
import '../../serial/application/serial_data_providers.dart';
import '../data/hook_binding_data_source.dart';
import '../data/hook_binding_repository_impl.dart';
import '../data/script_data_source.dart';
import '../data/script_repository_impl.dart';
import '../domain/script_hook.dart';
import '../domain/script_interfaces.dart';
import '../domain/script_log.dart';
import 'hook_engine.dart';
import 'script_api_bridge.dart';

part 'hook_service.g.dart';

/// Hook 服务状态
class HookServiceState {
  final List<ScriptHookBinding> bindings;
  final bool isProcessing;
  final List<ScriptLog> logs;
  final String? lastError;

  /// 当前激活的 Pipeline Hook (Rx)
  final ScriptHookBinding? activeRxHook;

  /// 当前激活的 Pipeline Hook (Tx)
  final ScriptHookBinding? activeTxHook;

  /// 当前激活的 Reply Hook
  final ScriptHookBinding? activeReplyHook;

  const HookServiceState({
    this.bindings = const [],
    this.isProcessing = false,
    this.logs = const [],
    this.lastError,
    this.activeRxHook,
    this.activeTxHook,
    this.activeReplyHook,
  });

  HookServiceState copyWith({
    List<ScriptHookBinding>? bindings,
    bool? isProcessing,
    List<ScriptLog>? logs,
    String? lastError,
    bool clearError = false,
    ScriptHookBinding? activeRxHook,
    bool clearRxHook = false,
    ScriptHookBinding? activeTxHook,
    bool clearTxHook = false,
    ScriptHookBinding? activeReplyHook,
    bool clearReplyHook = false,
  }) {
    return HookServiceState(
      bindings: bindings ?? this.bindings,
      isProcessing: isProcessing ?? this.isProcessing,
      logs: logs ?? this.logs,
      lastError: clearError ? null : (lastError ?? this.lastError),
      activeRxHook: clearRxHook ? null : (activeRxHook ?? this.activeRxHook),
      activeTxHook: clearTxHook ? null : (activeTxHook ?? this.activeTxHook),
      activeReplyHook: clearReplyHook
          ? null
          : (activeReplyHook ?? this.activeReplyHook),
    );
  }

  /// 获取指定类型的绑定列表
  List<ScriptHookBinding> getBindingsByType(HookType type) {
    return bindings.where((b) => b.hookType == type).toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));
  }
}

/// Hook 服务 Provider
@Riverpod(keepAlive: true)
class HookService extends _$HookService {
  late final IHookBindingRepository _bindingRepository;
  late final IScriptRepository _scriptRepository;
  late final HookEngine _hookEngine;
  StreamSubscription<ScriptLog>? _logSubscription;

  @override
  HookServiceState build() {
    _initializeService();
    return const HookServiceState();
  }

  void _initializeService() {
    // 初始化仓库
    _bindingRepository = HookBindingRepositoryImpl(HookBindingJsonDataSource());
    _scriptRepository = ScriptRepositoryImpl(ScriptJsonDataSource());

    // 创建 API 桥接器
    final apiBridge = ScriptApiBridge(onSend: _handleSend, onLog: _handleLog);

    // 创建 Hook 引擎
    _hookEngine = HookEngine(apiBridge);
    _hookEngine.initialize();

    // 监听日志
    _logSubscription = _hookEngine.logStream.listen(_addLog);

    // 加载绑定
    _loadBindings();

    ref.onDispose(() {
      _logSubscription?.cancel();
      _hookEngine.dispose();
    });
  }

  Future<void> _loadBindings() async {
    try {
      final bindings = await _bindingRepository.getAllBindings();
      state = state.copyWith(bindings: bindings);
      _updateActiveHooks();
    } catch (e) {
      _addLog(ScriptLog.error('Failed to load hook bindings: $e'));
    }
  }

  /// 更新激活的 Hook
  void _updateActiveHooks() {
    // 调试日志：显示所有绑定
    _addLog(
      ScriptLog.debug(
        '_updateActiveHooks: Total bindings: ${state.bindings.length}',
      ),
    );
    for (final b in state.bindings) {
      _addLog(
        ScriptLog.debug(
          '  Binding: ${b.hookType.name}, enabled=${b.enabled}, scriptId=${b.scriptId}',
        ),
      );
    }

    final rxHooks =
        state.bindings
            .where((b) => b.hookType == HookType.rxPreProcessor && b.enabled)
            .toList()
          ..sort((a, b) => a.priority.compareTo(b.priority));

    final txHooks =
        state.bindings
            .where((b) => b.hookType == HookType.txPostProcessor && b.enabled)
            .toList()
          ..sort((a, b) => a.priority.compareTo(b.priority));

    final replyHooks =
        state.bindings
            .where((b) => b.hookType == HookType.replyHook && b.enabled)
            .toList()
          ..sort((a, b) => a.priority.compareTo(b.priority));

    _addLog(
      ScriptLog.debug(
        'Active hooks - Rx: ${rxHooks.length}, Tx: ${txHooks.length}, Reply: ${replyHooks.length}',
      ),
    );

    state = state.copyWith(
      activeRxHook: rxHooks.isNotEmpty ? rxHooks.first : null,
      clearRxHook: rxHooks.isEmpty,
      activeTxHook: txHooks.isNotEmpty ? txHooks.first : null,
      clearTxHook: txHooks.isEmpty,
      activeReplyHook: replyHooks.isNotEmpty ? replyHooks.first : null,
      clearReplyHook: replyHooks.isEmpty,
    );
  }

  /// 创建新的 Hook 绑定
  Future<void> createBinding({
    required String scriptId,
    required HookType hookType,
    String? description,
    int priority = 100,
  }) async {
    final binding = ScriptHookBinding(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      scriptId: scriptId,
      hookType: hookType,
      enabled: true,
      priority: priority,
      createdAt: DateTime.now(),
      description: description,
    );

    await _bindingRepository.saveBinding(binding);
    await _loadBindings();
    _addLog(ScriptLog.info('Hook binding created: ${hookType.displayName}'));
  }

  /// 删除 Hook 绑定
  Future<void> deleteBinding(String bindingId) async {
    await _bindingRepository.deleteBinding(bindingId);
    await _loadBindings();
    _addLog(ScriptLog.info('Hook binding deleted'));
  }

  /// 更新绑定启用状态
  Future<void> setBindingEnabled(String bindingId, bool enabled) async {
    await _bindingRepository.updateBindingEnabled(bindingId, enabled);
    await _loadBindings();
  }

  /// 更新绑定优先级
  Future<void> setBindingPriority(String bindingId, int priority) async {
    await _bindingRepository.updateBindingPriority(bindingId, priority);
    await _loadBindings();
  }

  /// 刷新绑定列表
  Future<void> refreshBindings() async {
    await _loadBindings();
  }

  /// 更新完整绑定
  Future<void> updateBinding(ScriptHookBinding binding) async {
    await _bindingRepository.saveBinding(binding);
    await _loadBindings();
    _addLog(
      ScriptLog.info('Hook binding updated: ${binding.hookType.displayName}'),
    );
  }

  /// 执行任务 Hook（通过绑定 ID）
  Future<HookExecutionResult> executeTaskHook(String bindingId) async {
    return executeTask(bindingId);
  }

  /// 处理接收数据 (Rx Pipeline Hook)
  ///
  /// 返回处理后的数据，如果没有激活的 Hook 则返回原始数据
  Future<Uint8List> processRxData(Uint8List rawData) async {
    final rxHook = state.activeRxHook;
    if (rxHook == null) {
      _addLog(ScriptLog.info('[Rx] No active hook'));
      return rawData;
    }

    _addLog(ScriptLog.info('[Rx] Found hook: ${rxHook.scriptId}'));

    final script = await _scriptRepository.getScriptById(rxHook.scriptId);
    if (script == null || !script.isEnabled) {
      _addLog(ScriptLog.info('[Rx] Script not found or disabled'));
      return rawData;
    }

    _addLog(ScriptLog.info('[Rx] Executing: ${script.name}'));
    state = state.copyWith(isProcessing: true);

    try {
      final context = PipelineHookContext(
        rawData: rawData,
        isRx: true,
        timestamp: DateTime.now(),
      );

      final result = await _hookEngine.executePipelineHook(script, context);

      if (result.success && result.processedData != null) {
        return result.processedData!;
      }
      return rawData;
    } catch (e) {
      _addLog(ScriptLog.error('Rx hook error: $e'));
      return rawData;
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }

  /// 处理发送数据 (Tx Pipeline Hook)
  ///
  /// 返回处理后的数据，如果没有激活的 Hook 则返回原始数据
  Future<Uint8List> processTxData(Uint8List rawData) async {
    final txHook = state.activeTxHook;
    if (txHook == null) {
      _addLog(ScriptLog.info('[Tx] No active hook'));
      return rawData;
    }

    _addLog(ScriptLog.info('[Tx] Found hook: ${txHook.scriptId}'));

    final script = await _scriptRepository.getScriptById(txHook.scriptId);
    if (script == null || !script.isEnabled) {
      _addLog(ScriptLog.info('[Tx] Script not found or disabled'));
      return rawData;
    }

    _addLog(ScriptLog.info('[Tx] Executing: ${script.name}'));
    state = state.copyWith(isProcessing: true);

    try {
      final context = PipelineHookContext(
        rawData: rawData,
        isRx: false,
        timestamp: DateTime.now(),
      );

      final result = await _hookEngine.executePipelineHook(script, context);

      if (result.success && result.processedData != null) {
        return result.processedData!;
      }
      return rawData;
    } catch (e) {
      _addLog(ScriptLog.error('Tx hook error: $e'));
      return rawData;
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }

  /// 处理回复 (Reply Hook)
  ///
  /// 返回要发送的响应数据，如果不需要回复则返回 null
  Future<Uint8List?> processReplyHook(
    Uint8List receivedData, {
    int globalDelayMs = 0,
  }) async {
    final replyHook = state.activeReplyHook;
    if (replyHook == null) {
      _addLog(ScriptLog.debug('processReplyHook: No active Reply hook'));
      return null;
    }

    _addLog(
      ScriptLog.debug(
        'processReplyHook: Found active Reply hook: ${replyHook.scriptId}',
      ),
    );

    final script = await _scriptRepository.getScriptById(replyHook.scriptId);
    if (script == null || !script.isEnabled) {
      _addLog(
        ScriptLog.debug('processReplyHook: Script not found or disabled'),
      );
      return null;
    }

    state = state.copyWith(isProcessing: true);

    try {
      final context = ReplyHookContext(
        receivedData: receivedData,
        timestamp: DateTime.now(),
        globalDelayMs: globalDelayMs,
      );

      final result = await _hookEngine.executeReplyHook(script, context);

      if (result.success &&
          result.shouldContinue &&
          result.responseData != null) {
        return result.responseData;
      }
      return null;
    } catch (e) {
      _addLog(ScriptLog.error('Reply hook error: $e'));
      return null;
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }

  /// 执行手动任务 (Task Hook)
  Future<HookExecutionResult> executeTask(String bindingId) async {
    final binding = state.bindings.firstWhere(
      (b) => b.id == bindingId,
      orElse: () => throw Exception('Binding not found'),
    );

    if (binding.hookType != HookType.taskHook) {
      return HookExecutionResult.failure(
        errorMessage: 'Not a task hook',
        durationMs: 0,
      );
    }

    final script = await _scriptRepository.getScriptById(binding.scriptId);
    if (script == null) {
      return HookExecutionResult.failure(
        errorMessage: 'Script not found',
        durationMs: 0,
      );
    }

    state = state.copyWith(isProcessing: true);

    try {
      final result = await _hookEngine.executeTaskHook(script);
      return result;
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }

  /// 根据脚本 ID 执行任务
  Future<HookExecutionResult> executeTaskByScriptId(String scriptId) async {
    final script = await _scriptRepository.getScriptById(scriptId);
    if (script == null) {
      return HookExecutionResult.failure(
        errorMessage: 'Script not found',
        durationMs: 0,
      );
    }

    state = state.copyWith(isProcessing: true);

    try {
      final result = await _hookEngine.executeTaskHook(script);
      return result;
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }

  /// 获取指定脚本的所有绑定
  List<ScriptHookBinding> getBindingsForScript(String scriptId) {
    return state.bindings.where((b) => b.scriptId == scriptId).toList();
  }

  /// 获取指定类型的所有绑定
  List<ScriptHookBinding> getBindingsByType(HookType type) {
    return state.getBindingsByType(type);
  }

  /// 清除日志
  void clearLogs() {
    state = state.copyWith(logs: []);
  }

  void _handleSend(Uint8List data) {
    _addLog(
      ScriptLog.debug(
        'Hook send: ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ').toUpperCase()}',
      ),
    );

    final connectionState = ref.read(unifiedConnectionProvider);
    if (connectionState.isConnected) {
      ref
          .read(unifiedConnectionProvider.notifier)
          .send(data)
          .then((_) {
            ref.read(serialDataLogProvider.notifier).addSentData(data);
          })
          .catchError((Object e) {
            _addLog(ScriptLog.error('Send failed: $e'));
          });
    } else {
      _addLog(ScriptLog.warning('Not connected, cannot send'));
    }
  }

  void _handleLog(String message, String level) {
    ScriptLog log;
    switch (level) {
      case 'warning':
        log = ScriptLog.warning(message);
      case 'error':
        log = ScriptLog.error(message);
      case 'debug':
        log = ScriptLog.debug(message);
      default:
        log = ScriptLog.info(message);
    }
    _addLog(log);
  }

  void _addLog(ScriptLog log) {
    final newLogs = [...state.logs, log];
    if (newLogs.length > 1000) {
      newLogs.removeRange(0, newLogs.length - 1000);
    }
    state = state.copyWith(logs: newLogs);
  }
}

/// Hook 绑定列表 Provider (只读)
@riverpod
List<ScriptHookBinding> hookBindings(Ref ref) {
  return ref.watch(hookServiceProvider).bindings;
}

/// 指定类型的 Hook 绑定 Provider
@riverpod
List<ScriptHookBinding> hookBindingsByType(Ref ref, HookType type) {
  return ref.watch(hookServiceProvider).getBindingsByType(type);
}

/// 是否有激活的 Rx Hook
@riverpod
bool hasActiveRxHook(Ref ref) {
  return ref.watch(hookServiceProvider).activeRxHook != null;
}

/// 是否有激活的 Tx Hook
@riverpod
bool hasActiveTxHook(Ref ref) {
  return ref.watch(hookServiceProvider).activeTxHook != null;
}

/// 是否有激活的 Reply Hook
@riverpod
bool hasActiveReplyHook(Ref ref) {
  return ref.watch(hookServiceProvider).activeReplyHook != null;
}

/// Hook 日志 Provider
@riverpod
List<ScriptLog> hookLogs(Ref ref) {
  return ref.watch(hookServiceProvider).logs;
}
