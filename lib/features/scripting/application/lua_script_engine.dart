import 'dart:async';
import 'package:lua_dardo/lua.dart';
import '../domain/script_entity.dart';
import '../domain/script_interfaces.dart';
import '../domain/script_log.dart';

/// Lua脚本引擎实现
class LuaScriptEngine implements IScriptEngine {
  LuaState? _luaState;
  final IScriptApiBridge _apiBridge;
  final StreamController<ScriptLog> _logController =
      StreamController<ScriptLog>.broadcast();
  bool _isExecuting = false;

  LuaScriptEngine(this._apiBridge);

  @override
  Future<void> initialize() async {
    _luaState = LuaState.newState();
    _luaState!.openLibs();
    _registerApiBridge();
  }

  /// 注册API桥接器到Lua环境
  void _registerApiBridge() {
    if (_luaState == null) return;

    final ls = _luaState!;

    // 创建FCom全局表并注册函数
    ls.newTable();

    // 注册send函数到表中
    ls.pushDartFunction(_luaSend);
    ls.setField(-2, 'send');

    // 注册log函数到表中
    ls.pushDartFunction(_luaLog);
    ls.setField(-2, 'log');

    // 注册delay函数到表中
    ls.pushDartFunction(_luaDelay);
    ls.setField(-2, 'delay');

    // 注册crc16函数到表中
    ls.pushDartFunction(_luaCrc16);
    ls.setField(-2, 'crc16');

    // 注册crc32函数到表中
    ls.pushDartFunction(_luaCrc32);
    ls.setField(-2, 'crc32');

    // 注册checksum函数到表中
    ls.pushDartFunction(_luaChecksum);
    ls.setField(-2, 'checksum');

    // 注册getTimestamp函数到表中
    ls.pushDartFunction(_luaGetTimestamp);
    ls.setField(-2, 'getTimestamp');

    // 将表设置为全局变量FCom
    ls.setGlobal('FCom');
  }

  /// Lua send函数实现
  int _luaSend(LuaState ls) {
    try {
      if (ls.isString(1)) {
        final data = ls.toStr(1);
        if (data != null) {
          _apiBridge.send(data);
        }
      }
    } catch (e) {
      _logError('send() error: $e');
    }
    return 0;
  }

  /// Lua log函数实现
  int _luaLog(LuaState ls) {
    try {
      final message = ls.toStr(1) ?? '';
      final level = ls.toStr(2) ?? 'info';
      _apiBridge.log(message, level: level);
    } catch (e) {
      _logError('log() error: $e');
    }
    return 0;
  }

  /// Lua delay函数实现（注意：Lua中不能真正异步，这里仅做标记）
  int _luaDelay(LuaState ls) {
    try {
      final ms = ls.toInteger(1);
      // 在Lua中模拟延迟（简化处理，实际使用时可能需要协程支持）
      _logController.add(ScriptLog.debug('Delay requested: ${ms}ms'));
    } catch (e) {
      _logError('delay() error: $e');
    }
    return 0;
  }

  /// Lua crc16函数实现
  int _luaCrc16(LuaState ls) {
    try {
      final data = ls.toStr(1) ?? '';
      final result = _apiBridge.crc16(data);
      ls.pushString(result);
      return 1;
    } catch (e) {
      _logError('crc16() error: $e');
      ls.pushNil();
      return 1;
    }
  }

  /// Lua crc32函数实现
  int _luaCrc32(LuaState ls) {
    try {
      final data = ls.toStr(1) ?? '';
      final result = _apiBridge.crc32(data);
      ls.pushString(result);
      return 1;
    } catch (e) {
      _logError('crc32() error: $e');
      ls.pushNil();
      return 1;
    }
  }

  /// Lua checksum函数实现
  int _luaChecksum(LuaState ls) {
    try {
      final data = ls.toStr(1) ?? '';
      final result = _apiBridge.checksum(data);
      ls.pushString(result);
      return 1;
    } catch (e) {
      _logError('checksum() error: $e');
      ls.pushNil();
      return 1;
    }
  }

  /// Lua getTimestamp函数实现
  int _luaGetTimestamp(LuaState ls) {
    try {
      final timestamp = _apiBridge.getTimestamp();
      ls.pushInteger(timestamp);
      return 1;
    } catch (e) {
      _logError('getTimestamp() error: $e');
      ls.pushNil();
      return 1;
    }
  }

  @override
  Future<ScriptExecutionResult> execute(ScriptEntity script) async {
    if (_luaState == null) {
      return ScriptExecutionResult.failure(
        errorMessage: 'Engine not initialized',
        durationMs: 0,
      );
    }

    if (_isExecuting) {
      return ScriptExecutionResult.failure(
        errorMessage: 'Another script is already executing',
        durationMs: 0,
      );
    }

    _isExecuting = true;
    final startTime = DateTime.now();

    try {
      _logController.add(
        ScriptLog.info('Executing script: ${script.name}', scriptId: script.id),
      );

      final status = _luaState!.loadString(script.content);
      if (status != ThreadStatus.luaOk) {
        final error = _luaState!.toStr(-1) ?? 'Unknown error';
        _luaState!.pop(1);
        throw Exception('Script load failed: $error');
      }

      // 执行脚本
      final pcallStatus = _luaState!.pCall(0, 0, 0);
      if (pcallStatus != ThreadStatus.luaOk) {
        final error = _luaState!.toStr(-1) ?? 'Unknown error';
        _luaState!.pop(1);
        throw Exception('Script execution failed: $error');
      }

      final duration = DateTime.now().difference(startTime).inMilliseconds;
      _logController.add(
        ScriptLog.info(
          'Script executed successfully in ${duration}ms',
          scriptId: script.id,
        ),
      );

      return ScriptExecutionResult.success(durationMs: duration);
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      _logError('Execution error: $e', scriptId: script.id);
      return ScriptExecutionResult.failure(
        errorMessage: e.toString(),
        durationMs: duration,
      );
    } finally {
      _isExecuting = false;
    }
  }

  @override
  Future<void> stop() async {
    _logController.add(ScriptLog.warning('Stop requested'));
  }

  @override
  Future<void> dispose() async {
    await stop();
    _luaState = null;
    await _logController.close();
  }

  @override
  Stream<ScriptLog> get logStream => _logController.stream;

  @override
  bool get isExecuting => _isExecuting;

  /// 记录错误日志
  void _logError(String message, {String? scriptId}) {
    _logController.add(ScriptLog.error(message, scriptId: scriptId));
  }
}
