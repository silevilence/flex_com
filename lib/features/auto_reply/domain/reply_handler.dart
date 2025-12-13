import 'dart:convert';
import 'dart:typed_data';

import '../../../core/utils/hex_utils.dart';
import 'match_reply_config.dart';
import 'sequential_reply_config.dart';

/// 回复结果
///
/// 包含处理器返回的响应数据和相关信息
class ReplyResult {
  const ReplyResult({
    required this.responseData,
    this.matchedRuleId,
    this.matchedRuleName,
  });

  /// 要发送的响应数据（原始字节）
  final Uint8List responseData;

  /// 匹配的规则 ID（仅匹配回复模式）
  final String? matchedRuleId;

  /// 匹配的规则名称（用于日志）
  final String? matchedRuleName;
}

/// 回复处理器接口
///
/// 所有回复模式必须实现此接口。
/// 设计要点：
/// - 新增回复模式只需实现此接口
/// - 处理器内部维护模式特定的状态
/// - 统一的输入输出格式
abstract class ReplyHandler {
  /// 处理接收到的数据，返回响应结果
  ///
  /// [receivedData] 接收到的原始字节数据
  /// 返回 [ReplyResult] 如果需要回复，否则返回 null
  ReplyResult? processReceivedData(Uint8List receivedData);

  /// 重置处理器状态
  void reset();
}

/// 匹配回复处理器
///
/// 检测接收数据中是否包含预设的特征码，匹配成功则返回对应的响应数据
class MatchReplyHandler implements ReplyHandler {
  MatchReplyHandler({required this.config});

  /// 匹配回复配置
  final MatchReplyConfig config;

  @override
  ReplyResult? processReceivedData(Uint8List receivedData) {
    for (final rule in config.rules) {
      // 跳过禁用的规则
      if (!rule.enabled) continue;

      // 将触发模式转换为字节
      final triggerBytes = _patternToBytes(
        rule.triggerPattern,
        rule.triggerMode,
      );
      if (triggerBytes == null || triggerBytes.isEmpty) continue;

      // 检查接收数据是否包含触发模式
      if (_containsPattern(receivedData, triggerBytes)) {
        // 将响应数据转换为字节
        final responseBytes = _patternToBytes(
          rule.responseData,
          rule.responseMode,
        );
        if (responseBytes == null) continue;

        return ReplyResult(
          responseData: responseBytes,
          matchedRuleId: rule.id,
          matchedRuleName: rule.name,
        );
      }
    }
    return null;
  }

  @override
  void reset() {
    // 匹配回复是无状态的，无需重置
  }

  /// 将字符串模式转换为字节数组
  Uint8List? _patternToBytes(String pattern, DataMode mode) {
    try {
      if (mode == DataMode.hex) {
        return HexUtils.hexStringToBytes(pattern);
      } else {
        // ASCII 模式
        return Uint8List.fromList(utf8.encode(pattern));
      }
    } catch (_) {
      return null;
    }
  }

  /// 检查数据中是否包含指定模式
  bool _containsPattern(Uint8List data, Uint8List pattern) {
    if (pattern.isEmpty) return false;
    if (data.length < pattern.length) return false;

    outer:
    for (var i = 0; i <= data.length - pattern.length; i++) {
      for (var j = 0; j < pattern.length; j++) {
        if (data[i + j] != pattern[j]) {
          continue outer;
        }
      }
      return true;
    }
    return false;
  }
}

/// 顺序回复处理器
///
/// 每次收到数据后按顺序发送预设列表中的下一帧
class SequentialReplyHandler implements ReplyHandler {
  SequentialReplyHandler({required SequentialReplyConfig config})
    : _config = config,
      _currentIndex = config.currentIndex;

  final SequentialReplyConfig _config;
  int _currentIndex;

  /// 获取当前帧索引
  int get currentIndex => _currentIndex;

  /// 获取帧总数
  int get frameCount => _config.frames.length;

  @override
  ReplyResult? processReceivedData(Uint8List receivedData) {
    if (_config.frames.isEmpty) return null;

    // 检查索引是否超出范围
    if (_currentIndex >= _config.frames.length) {
      if (_config.loopEnabled) {
        _currentIndex = 0;
      } else {
        return null;
      }
    }

    final frame = _config.frames[_currentIndex];

    // 将帧数据转换为字节
    final responseBytes = _frameToBytes(frame);
    if (responseBytes == null) {
      // 跳过无效帧
      _currentIndex++;
      // 检查跳过后是否需要循环
      if (_currentIndex >= _config.frames.length && _config.loopEnabled) {
        _currentIndex = 0;
      }
      return null;
    }

    // 移动到下一帧
    _currentIndex++;
    // 检查是否需要循环到开头
    if (_currentIndex >= _config.frames.length && _config.loopEnabled) {
      _currentIndex = 0;
    }

    return ReplyResult(
      responseData: responseBytes,
      matchedRuleId: frame.id,
      matchedRuleName: frame.name,
    );
  }

  @override
  void reset() {
    _currentIndex = 0;
  }

  /// 跳转到指定索引
  void jumpTo(int index) {
    if (index >= 0 && index < _config.frames.length) {
      _currentIndex = index;
    }
  }

  /// 将帧转换为字节数组
  Uint8List? _frameToBytes(SequentialReplyFrame frame) {
    try {
      if (frame.mode == DataMode.hex) {
        return HexUtils.hexStringToBytes(frame.data);
      } else {
        return Uint8List.fromList(utf8.encode(frame.data));
      }
    } catch (_) {
      return null;
    }
  }
}
