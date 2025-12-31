import 'package:equatable/equatable.dart';

/// 脚本日志类型
enum ScriptLogType {
  /// 信息
  info,

  /// 警告
  warning,

  /// 错误
  error,

  /// 调试
  debug,
}

/// 脚本日志实体
class ScriptLog extends Equatable {
  /// 日志类型
  final ScriptLogType type;

  /// 日志消息
  final String message;

  /// 时间戳
  final DateTime timestamp;

  /// 脚本ID（可选）
  final String? scriptId;

  const ScriptLog({
    required this.type,
    required this.message,
    required this.timestamp,
    this.scriptId,
  });

  factory ScriptLog.info(String message, {String? scriptId}) {
    return ScriptLog(
      type: ScriptLogType.info,
      message: message,
      timestamp: DateTime.now(),
      scriptId: scriptId,
    );
  }

  factory ScriptLog.warning(String message, {String? scriptId}) {
    return ScriptLog(
      type: ScriptLogType.warning,
      message: message,
      timestamp: DateTime.now(),
      scriptId: scriptId,
    );
  }

  factory ScriptLog.error(String message, {String? scriptId}) {
    return ScriptLog(
      type: ScriptLogType.error,
      message: message,
      timestamp: DateTime.now(),
      scriptId: scriptId,
    );
  }

  factory ScriptLog.debug(String message, {String? scriptId}) {
    return ScriptLog(
      type: ScriptLogType.debug,
      message: message,
      timestamp: DateTime.now(),
      scriptId: scriptId,
    );
  }

  @override
  List<Object?> get props => [type, message, timestamp, scriptId];
}
