import 'dart:typed_data';
import '../domain/script_entity.dart';
import '../domain/script_log.dart';

/// 脚本执行结果
class ScriptExecutionResult {
  /// 是否成功
  final bool success;

  /// 返回值
  final dynamic returnValue;

  /// 错误信息（如果失败）
  final String? errorMessage;

  /// 执行时长（毫秒）
  final int durationMs;

  const ScriptExecutionResult({
    required this.success,
    this.returnValue,
    this.errorMessage,
    required this.durationMs,
  });

  factory ScriptExecutionResult.success({
    dynamic returnValue,
    required int durationMs,
  }) {
    return ScriptExecutionResult(
      success: true,
      returnValue: returnValue,
      durationMs: durationMs,
    );
  }

  factory ScriptExecutionResult.failure({
    required String errorMessage,
    required int durationMs,
  }) {
    return ScriptExecutionResult(
      success: false,
      errorMessage: errorMessage,
      durationMs: durationMs,
    );
  }
}

/// 脚本引擎接口
abstract class IScriptEngine {
  /// 初始化引擎
  Future<void> initialize();

  /// 执行脚本
  Future<ScriptExecutionResult> execute(ScriptEntity script);

  /// 停止脚本执行
  Future<void> stop();

  /// 释放资源
  Future<void> dispose();

  /// 获取日志流
  Stream<ScriptLog> get logStream;

  /// 是否正在执行
  bool get isExecuting;
}

/// 脚本API桥接器接口（暴露给Lua的全局API）
abstract class IScriptApiBridge {
  /// 发送数据
  /// @param data 数据（Hex字符串或字节数组）
  void send(dynamic data);

  /// 记录日志
  /// @param message 日志消息
  /// @param level 日志级别 ("info", "warning", "error", "debug")
  void log(String message, {String level = 'info'});

  /// 延迟执行
  /// @param ms 延迟毫秒数
  Future<void> delay(int ms);

  /// 计算CRC16
  /// @param data 数据（Hex字符串或字节数组）
  /// @return CRC16值（16进制字符串）
  String crc16(dynamic data);

  /// 计算CRC32
  /// @param data 数据（Hex字符串或字节数组）
  /// @return CRC32值（16进制字符串）
  String crc32(dynamic data);

  /// 计算校验和
  /// @param data 数据（Hex字符串或字节数组）
  /// @return 校验和（16进制字符串）
  String checksum(dynamic data);

  /// 获取当前时间戳（毫秒）
  int getTimestamp();

  /// Hex字符串转字节数组
  Uint8List hexToBytes(String hex);

  /// 字节数组转Hex字符串
  String bytesToHex(Uint8List bytes);
}

/// 脚本仓库接口
abstract class IScriptRepository {
  /// 获取所有脚本
  Future<List<ScriptEntity>> getAllScripts();

  /// 根据ID获取脚本
  Future<ScriptEntity?> getScriptById(String id);

  /// 保存脚本（新增或更新）
  Future<void> saveScript(ScriptEntity script);

  /// 删除脚本
  Future<void> deleteScript(String id);

  /// 监听脚本变化
  Stream<List<ScriptEntity>> watchScripts();
}
