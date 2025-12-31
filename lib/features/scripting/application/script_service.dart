import 'dart:async';
import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../connection/application/connection_providers.dart';
import '../../serial/application/serial_data_providers.dart';
import '../data/script_data_source.dart';
import '../data/script_repository_impl.dart';
import '../domain/script_entity.dart';
import '../domain/script_interfaces.dart';
import '../domain/script_log.dart';
import 'lua_script_engine.dart';
import 'script_api_bridge.dart';

part 'script_service.g.dart';

/// 脚本服务状态
class ScriptServiceState {
  final List<ScriptEntity> scripts;
  final ScriptEntity? currentScript;
  final bool isExecuting;
  final List<ScriptLog> logs;

  const ScriptServiceState({
    this.scripts = const [],
    this.currentScript,
    this.isExecuting = false,
    this.logs = const [],
  });

  ScriptServiceState copyWith({
    List<ScriptEntity>? scripts,
    ScriptEntity? currentScript,
    bool? isExecuting,
    List<ScriptLog>? logs,
  }) {
    return ScriptServiceState(
      scripts: scripts ?? this.scripts,
      currentScript: currentScript ?? this.currentScript,
      isExecuting: isExecuting ?? this.isExecuting,
      logs: logs ?? this.logs,
    );
  }
}

/// 脚本服务Provider
@riverpod
class ScriptService extends _$ScriptService {
  late final IScriptRepository _repository;
  late final IScriptEngine _engine;
  StreamSubscription<ScriptLog>? _logSubscription;
  StreamSubscription<List<ScriptEntity>>? _scriptsSubscription;

  @override
  ScriptServiceState build() {
    _initializeService();
    return const ScriptServiceState();
  }

  /// 初始化服务
  void _initializeService() {
    // 创建仓库
    final dataSource = ScriptJsonDataSource();
    _repository = ScriptRepositoryImpl(dataSource);

    // 创建API桥接器
    final apiBridge = ScriptApiBridge(onSend: _handleSend, onLog: _handleLog);

    // 创建脚本引擎
    _engine = LuaScriptEngine(apiBridge);
    _engine.initialize();

    // 监听日志
    _logSubscription = _engine.logStream.listen((log) {
      final newLogs = [...state.logs, log];
      // 保留最近1000条日志
      if (newLogs.length > 1000) {
        newLogs.removeRange(0, newLogs.length - 1000);
      }
      state = state.copyWith(logs: newLogs);
    });

    // 监听脚本变化
    _scriptsSubscription = _repository.watchScripts().listen((scripts) {
      state = state.copyWith(scripts: scripts);
    });

    // 初始加载脚本
    _loadScripts();

    // 在dispose时清理
    ref.onDispose(() {
      _logSubscription?.cancel();
      _scriptsSubscription?.cancel();
      _engine.dispose();
    });
  }

  /// 加载脚本列表
  Future<void> _loadScripts() async {
    try {
      final scripts = await _repository.getAllScripts();
      state = state.copyWith(scripts: scripts);
    } catch (e) {
      _handleLog('Failed to load scripts: $e', 'error');
    }
  }

  /// 获取脚本列表
  List<ScriptEntity> getScripts() {
    return state.scripts;
  }

  /// 根据ID获取脚本
  Future<ScriptEntity?> getScriptById(String id) async {
    return _repository.getScriptById(id);
  }

  /// 保存脚本
  Future<void> saveScript(ScriptEntity script) async {
    try {
      await _repository.saveScript(script);
      _handleLog('Script saved: ${script.name}', 'info');
    } catch (e) {
      _handleLog('Failed to save script: $e', 'error');
      rethrow;
    }
  }

  /// 删除脚本
  Future<void> deleteScript(String id) async {
    try {
      await _repository.deleteScript(id);
      _handleLog('Script deleted', 'info');

      // 如果删除的是当前脚本，清除当前脚本
      if (state.currentScript?.id == id) {
        state = state.copyWith(currentScript: null);
      }
    } catch (e) {
      _handleLog('Failed to delete script: $e', 'error');
      rethrow;
    }
  }

  /// 执行脚本
  Future<ScriptExecutionResult> executeScript(String scriptId) async {
    if (state.isExecuting) {
      _handleLog('Another script is already executing', 'warning');
      return ScriptExecutionResult.failure(
        errorMessage: 'Another script is already executing',
        durationMs: 0,
      );
    }

    final script = await getScriptById(scriptId);
    if (script == null) {
      _handleLog('Script not found: $scriptId', 'error');
      return ScriptExecutionResult.failure(
        errorMessage: 'Script not found',
        durationMs: 0,
      );
    }

    if (!script.isEnabled) {
      _handleLog('Script is disabled: ${script.name}', 'warning');
      return ScriptExecutionResult.failure(
        errorMessage: 'Script is disabled',
        durationMs: 0,
      );
    }

    state = state.copyWith(currentScript: script, isExecuting: true);

    try {
      final result = await _engine.execute(script);
      return result;
    } finally {
      state = state.copyWith(isExecuting: false);
    }
  }

  /// 停止脚本执行
  Future<void> stopScript() async {
    await _engine.stop();
    state = state.copyWith(isExecuting: false);
  }

  /// 清除日志
  void clearLogs() {
    state = state.copyWith(logs: []);
  }

  /// 处理发送数据
  void _handleSend(Uint8List data) {
    _handleLog(
      '发送数据: ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ').toUpperCase()}',
      'debug',
    );

    // 每次发送时重新读取最新连接状态
    final connectionState = ref.read(unifiedConnectionProvider);
    if (connectionState.isConnected) {
      ref
          .read(unifiedConnectionProvider.notifier)
          .send(data)
          .then((_) {
            // 发送成功后记录到数据显示面板
            ref.read(serialDataLogProvider.notifier).addSentData(data);
            _handleLog('发送成功', 'info');
          })
          .catchError((e) {
            _handleLog('发送失败: $e', 'error');
          });
    } else {
      _handleLog('未连接，无法发送数据', 'warning');
    }
  }

  /// 处理日志
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

    final newLogs = [...state.logs, log];
    // 保留最近1000条日志
    if (newLogs.length > 1000) {
      newLogs.removeRange(0, newLogs.length - 1000);
    }
    state = state.copyWith(logs: newLogs);
  }
}
