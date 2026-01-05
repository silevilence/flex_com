import 'dart:async';
import 'dart:typed_data';

import 'package:lua_dardo/lua.dart';

import '../../../core/utils/hex_utils.dart';
import '../domain/script_entity.dart';
import '../domain/script_hook.dart';
import '../domain/script_log.dart';
import 'script_api_bridge.dart';

/// Hook 引擎 - 专门用于执行 Hook 脚本
///
/// 与 LuaScriptEngine 不同，HookEngine 专注于：
/// 1. 支持数据输入/输出的脚本执行
/// 2. 在脚本中暴露接收到的数据
/// 3. 收集脚本的返回值作为处理结果
class HookEngine {
  LuaState? _luaState;
  final ScriptApiBridge _apiBridge;
  final StreamController<ScriptLog> _logController =
      StreamController<ScriptLog>.broadcast();

  /// 脚本中设置的响应数据
  Uint8List? _responseData;

  /// 脚本中设置的处理后数据
  Uint8List? _processedData;

  /// 是否应该继续处理
  bool _shouldContinue = true;

  HookEngine(this._apiBridge);

  /// 初始化引擎
  Future<void> initialize() async {
    _luaState = LuaState.newState();
    _luaState!.openLibs();
    _registerApiBridge();
  }

  /// 获取日志流
  Stream<ScriptLog> get logStream => _logController.stream;

  /// 注册 API 桥接器和 Hook 专用 API
  void _registerApiBridge() {
    if (_luaState == null) return;

    final ls = _luaState!;

    // 创建 FCom 全局表
    ls.newTable();

    // 注册基础 API
    ls.pushDartFunction(_luaSend);
    ls.setField(-2, 'send');

    ls.pushDartFunction(_luaLog);
    ls.setField(-2, 'log');

    ls.pushDartFunction(_luaCrc16);
    ls.setField(-2, 'crc16');

    ls.pushDartFunction(_luaCrc32);
    ls.setField(-2, 'crc32');

    ls.pushDartFunction(_luaChecksum);
    ls.setField(-2, 'checksum');

    ls.pushDartFunction(_luaGetTimestamp);
    ls.setField(-2, 'getTimestamp');

    ls.pushDartFunction(_luaHexToBytes);
    ls.setField(-2, 'hexToBytes');

    ls.pushDartFunction(_luaBytesToHex);
    ls.setField(-2, 'bytesToHex');

    // Hook 专用 API
    ls.pushDartFunction(_luaSetResponse);
    ls.setField(-2, 'setResponse');

    ls.pushDartFunction(_luaSetProcessedData);
    ls.setField(-2, 'setProcessedData');

    ls.pushDartFunction(_luaSkipReply);
    ls.setField(-2, 'skipReply');

    ls.pushDartFunction(_luaGetData);
    ls.setField(-2, 'getData');

    // 设置为全局变量
    ls.setGlobal('FCom');
  }

  /// 执行 Pipeline Hook
  ///
  /// [script] 脚本实体
  /// [context] Pipeline 上下文（包含原始数据）
  Future<HookExecutionResult> executePipelineHook(
    ScriptEntity script,
    PipelineHookContext context,
  ) async {
    if (_luaState == null) {
      return HookExecutionResult.failure(
        errorMessage: 'Engine not initialized',
        durationMs: 0,
      );
    }

    _processedData = null;
    _shouldContinue = true;

    final startTime = DateTime.now();

    try {
      // 设置输入数据到 Lua 全局变量
      _setInputData(context.rawData, context.isRx);

      // 加载并执行脚本
      final status = _luaState!.loadString(script.content);
      if (status != ThreadStatus.luaOk) {
        final error = _luaState!.toStr(-1) ?? 'Unknown error';
        _luaState!.pop(1);
        throw Exception('Script load failed: $error');
      }

      final pcallStatus = _luaState!.pCall(0, 0, 0);
      if (pcallStatus != ThreadStatus.luaOk) {
        final error = _luaState!.toStr(-1) ?? 'Unknown error';
        _luaState!.pop(1);
        throw Exception('Script execution failed: $error');
      }

      final duration = DateTime.now().difference(startTime).inMilliseconds;

      return HookExecutionResult.success(
        processedData: _processedData ?? context.rawData,
        durationMs: duration,
        shouldContinue: _shouldContinue,
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      _logController.add(ScriptLog.error('Pipeline hook error: $e'));
      return HookExecutionResult.failure(
        errorMessage: e.toString(),
        durationMs: duration,
      );
    }
  }

  /// 执行 Reply Hook
  ///
  /// [script] 脚本实体
  /// [context] Reply 上下文（包含接收数据）
  Future<HookExecutionResult> executeReplyHook(
    ScriptEntity script,
    ReplyHookContext context,
  ) async {
    if (_luaState == null) {
      return HookExecutionResult.failure(
        errorMessage: 'Engine not initialized',
        durationMs: 0,
      );
    }

    _responseData = null;
    _shouldContinue = true;

    final startTime = DateTime.now();

    try {
      // 设置接收数据到 Lua 全局变量
      _setInputData(context.receivedData, true);

      // 加载并执行脚本
      final status = _luaState!.loadString(script.content);
      if (status != ThreadStatus.luaOk) {
        final error = _luaState!.toStr(-1) ?? 'Unknown error';
        _luaState!.pop(1);
        throw Exception('Script load failed: $error');
      }

      final pcallStatus = _luaState!.pCall(0, 0, 0);
      if (pcallStatus != ThreadStatus.luaOk) {
        final error = _luaState!.toStr(-1) ?? 'Unknown error';
        _luaState!.pop(1);
        throw Exception('Script execution failed: $error');
      }

      final duration = DateTime.now().difference(startTime).inMilliseconds;

      if (!_shouldContinue || _responseData == null) {
        return HookExecutionResult.skip(durationMs: duration);
      }

      return HookExecutionResult.success(
        responseData: _responseData,
        durationMs: duration,
        shouldContinue: _shouldContinue,
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      _logController.add(ScriptLog.error('Reply hook error: $e'));
      return HookExecutionResult.failure(
        errorMessage: e.toString(),
        durationMs: duration,
      );
    }
  }

  /// 执行 Task Hook
  ///
  /// [script] 脚本实体
  Future<HookExecutionResult> executeTaskHook(ScriptEntity script) async {
    if (_luaState == null) {
      return HookExecutionResult.failure(
        errorMessage: 'Engine not initialized',
        durationMs: 0,
      );
    }

    final startTime = DateTime.now();

    try {
      _logController.add(
        ScriptLog.info('Executing task: ${script.name}', scriptId: script.id),
      );

      final status = _luaState!.loadString(script.content);
      if (status != ThreadStatus.luaOk) {
        final error = _luaState!.toStr(-1) ?? 'Unknown error';
        _luaState!.pop(1);
        throw Exception('Script load failed: $error');
      }

      final pcallStatus = _luaState!.pCall(0, 0, 0);
      if (pcallStatus != ThreadStatus.luaOk) {
        final error = _luaState!.toStr(-1) ?? 'Unknown error';
        _luaState!.pop(1);
        throw Exception('Script execution failed: $error');
      }

      final duration = DateTime.now().difference(startTime).inMilliseconds;
      _logController.add(
        ScriptLog.info('Task completed in ${duration}ms', scriptId: script.id),
      );

      return HookExecutionResult.success(durationMs: duration);
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      _logController.add(ScriptLog.error('Task error: $e'));
      return HookExecutionResult.failure(
        errorMessage: e.toString(),
        durationMs: duration,
      );
    }
  }

  /// 设置输入数据到 Lua 环境
  void _setInputData(Uint8List data, bool isRx) {
    if (_luaState == null) return;

    final ls = _luaState!;

    // 创建 FCom.input 表
    ls.getGlobal('FCom');

    // 创建 input 表
    ls.newTable();

    // 设置 raw (原始字节数组)
    ls.newTable();
    for (var i = 0; i < data.length; i++) {
      ls.pushInteger(i + 1); // Lua 索引从 1 开始
      ls.pushInteger(data[i]);
      ls.setTable(-3);
    }
    ls.setField(-2, 'raw');

    // 设置 hex (Hex 字符串)
    ls.pushString(HexUtils.bytesToHexString(data, uppercase: true));
    ls.setField(-2, 'hex');

    // 设置 length
    ls.pushInteger(data.length);
    ls.setField(-2, 'length');

    // 设置 isRx
    ls.pushBoolean(isRx);
    ls.setField(-2, 'isRx');

    // 将 input 表设置到 FCom
    ls.setField(-2, 'input');

    ls.pop(1); // 弹出 FCom
  }

  // Lua 函数实现

  int _luaSend(LuaState ls) {
    try {
      if (ls.isString(1)) {
        final data = ls.toStr(1);
        if (data != null) {
          _apiBridge.send(data);
        }
      }
    } catch (e) {
      _logController.add(ScriptLog.error('send() error: $e'));
    }
    return 0;
  }

  int _luaLog(LuaState ls) {
    try {
      final message = ls.toStr(1) ?? '';
      final level = ls.toStr(2) ?? 'info';
      _apiBridge.log(message, level: level);
    } catch (e) {
      _logController.add(ScriptLog.error('log() error: $e'));
    }
    return 0;
  }

  int _luaCrc16(LuaState ls) {
    try {
      final data = ls.toStr(1) ?? '';
      final result = _apiBridge.crc16(data);
      ls.pushString(result);
      return 1;
    } catch (e) {
      _logController.add(ScriptLog.error('crc16() error: $e'));
      ls.pushNil();
      return 1;
    }
  }

  int _luaCrc32(LuaState ls) {
    try {
      final data = ls.toStr(1) ?? '';
      final result = _apiBridge.crc32(data);
      ls.pushString(result);
      return 1;
    } catch (e) {
      _logController.add(ScriptLog.error('crc32() error: $e'));
      ls.pushNil();
      return 1;
    }
  }

  int _luaChecksum(LuaState ls) {
    try {
      final data = ls.toStr(1) ?? '';
      final result = _apiBridge.checksum(data);
      ls.pushString(result);
      return 1;
    } catch (e) {
      _logController.add(ScriptLog.error('checksum() error: $e'));
      ls.pushNil();
      return 1;
    }
  }

  int _luaGetTimestamp(LuaState ls) {
    try {
      final timestamp = _apiBridge.getTimestamp();
      ls.pushInteger(timestamp);
      return 1;
    } catch (e) {
      _logController.add(ScriptLog.error('getTimestamp() error: $e'));
      ls.pushNil();
      return 1;
    }
  }

  int _luaHexToBytes(LuaState ls) {
    try {
      final hex = ls.toStr(1) ?? '';
      final bytes = HexUtils.hexStringToBytes(hex);

      // 返回 Lua 表
      ls.newTable();
      for (var i = 0; i < bytes.length; i++) {
        ls.pushInteger(i + 1);
        ls.pushInteger(bytes[i]);
        ls.setTable(-3);
      }
      return 1;
    } catch (e) {
      _logController.add(ScriptLog.error('hexToBytes() error: $e'));
      ls.pushNil();
      return 1;
    }
  }

  int _luaBytesToHex(LuaState ls) {
    try {
      if (!ls.isTable(1)) {
        ls.pushString('');
        return 1;
      }

      final bytes = <int>[];
      ls.pushNil();
      while (ls.next(1)) {
        if (ls.isInteger(-1)) {
          bytes.add(ls.toInteger(-1));
        }
        ls.pop(1);
      }

      // 生成无空格的 Hex 字符串（更适合脚本处理）
      final hex = bytes
          .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
          .join();
      ls.pushString(hex);
      return 1;
    } catch (e) {
      _logController.add(ScriptLog.error('bytesToHex() error: $e'));
      ls.pushString('');
      return 1;
    }
  }

  /// Hook 专用: 设置响应数据（用于 Reply Hook）
  int _luaSetResponse(LuaState ls) {
    try {
      if (ls.isString(1)) {
        // Hex 字符串
        final hex = ls.toStr(1) ?? '';
        _responseData = HexUtils.hexStringToBytes(hex);
      } else if (ls.isTable(1)) {
        // 字节数组
        final bytes = <int>[];
        ls.pushNil();
        while (ls.next(1)) {
          if (ls.isInteger(-1)) {
            bytes.add(ls.toInteger(-1));
          }
          ls.pop(1);
        }
        _responseData = Uint8List.fromList(bytes);
      }
      _logController.add(ScriptLog.debug('Response set: $_responseData'));
    } catch (e) {
      _logController.add(ScriptLog.error('setResponse() error: $e'));
    }
    return 0;
  }

  /// Hook 专用: 设置处理后数据（用于 Pipeline Hook）
  int _luaSetProcessedData(LuaState ls) {
    try {
      if (ls.isString(1)) {
        final hex = ls.toStr(1) ?? '';
        _processedData = HexUtils.hexStringToBytes(hex);
      } else if (ls.isTable(1)) {
        final bytes = <int>[];
        ls.pushNil();
        while (ls.next(1)) {
          if (ls.isInteger(-1)) {
            bytes.add(ls.toInteger(-1));
          }
          ls.pop(1);
        }
        _processedData = Uint8List.fromList(bytes);
      }
      _logController.add(
        ScriptLog.debug('Processed data set: $_processedData'),
      );
    } catch (e) {
      _logController.add(ScriptLog.error('setProcessedData() error: $e'));
    }
    return 0;
  }

  /// Hook 专用: 跳过回复（用于 Reply Hook）
  int _luaSkipReply(LuaState ls) {
    _shouldContinue = false;
    _logController.add(ScriptLog.debug('Reply skipped by script'));
    return 0;
  }

  /// Hook 专用: 获取输入数据
  ///
  /// 返回 Lua 表，包含 raw (字节数组)、hex (十六进制字符串)、length (长度)、isRx (是否接收)
  int _luaGetData(LuaState ls) {
    // 获取 FCom.input 表并返回
    ls.getGlobal('FCom');
    ls.getField(-1, 'input');
    ls.remove(-2); // 移除 FCom 表，只保留 input
    return 1;
  }

  /// 释放资源
  Future<void> dispose() async {
    _luaState = null;
    await _logController.close();
  }
}
