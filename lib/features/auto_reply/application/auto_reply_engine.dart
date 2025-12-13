import 'dart:async';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../serial/application/serial_data_providers.dart';
import '../../serial/application/serial_providers.dart';
import '../domain/auto_reply_config.dart';
import '../domain/auto_reply_mode.dart';
import '../domain/reply_handler.dart';
import 'auto_reply_providers.dart';

part 'auto_reply_engine.g.dart';

/// 自动回复统计信息
class AutoReplyStats {
  const AutoReplyStats({
    this.totalReceived = 0,
    this.totalReplied = 0,
    this.lastMatchedRule,
    this.lastReplyTime,
  });

  final int totalReceived;
  final int totalReplied;
  final String? lastMatchedRule;
  final DateTime? lastReplyTime;

  AutoReplyStats copyWith({
    int? totalReceived,
    int? totalReplied,
    String? lastMatchedRule,
    DateTime? lastReplyTime,
  }) {
    return AutoReplyStats(
      totalReceived: totalReceived ?? this.totalReceived,
      totalReplied: totalReplied ?? this.totalReplied,
      lastMatchedRule: lastMatchedRule ?? this.lastMatchedRule,
      lastReplyTime: lastReplyTime ?? this.lastReplyTime,
    );
  }
}

/// 自动回复引擎状态
class AutoReplyEngineState {
  const AutoReplyEngineState({
    this.isProcessing = false,
    this.stats = const AutoReplyStats(),
    this.lastError,
  });

  final bool isProcessing;
  final AutoReplyStats stats;
  final String? lastError;

  AutoReplyEngineState copyWith({
    bool? isProcessing,
    AutoReplyStats? stats,
    String? lastError,
    bool clearError = false,
  }) {
    return AutoReplyEngineState(
      isProcessing: isProcessing ?? this.isProcessing,
      stats: stats ?? this.stats,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }
}

/// 辅助方法：安全获取 AsyncValue 的值
T? _getValueOrNull<T>(AsyncValue<T> asyncValue) {
  return asyncValue.when(
    data: (data) => data,
    loading: () => null,
    error: (_, __) => null,
  );
}

/// 自动回复引擎 Provider
///
/// 监听串口数据流，自动处理接收到的数据并发送回复
@Riverpod(keepAlive: true)
class AutoReplyEngine extends _$AutoReplyEngine {
  StreamSubscription<Uint8List>? _subscription;

  @override
  AutoReplyEngineState build() {
    // 监听串口数据流
    final repository = ref.watch(serialRepositoryProvider);

    _subscription?.cancel();
    _subscription = repository.dataStream.listen(_onDataReceived);

    ref.onDispose(() {
      _subscription?.cancel();
      _subscription = null;
    });

    return const AutoReplyEngineState();
  }

  /// 处理接收到的数据
  Future<void> _onDataReceived(Uint8List data) async {
    // 获取全局配置
    final globalConfigAsync = ref.read(autoReplyConfigProvider);
    final globalConfig = _getValueOrNull(globalConfigAsync);

    // 检查是否启用
    if (globalConfig == null || !globalConfig.enabled) {
      return;
    }

    // 更新统计
    state = state.copyWith(
      stats: state.stats.copyWith(totalReceived: state.stats.totalReceived + 1),
    );

    // 获取处理器
    final handler = _getHandler(globalConfig);
    if (handler == null) return;

    // 标记处理中
    state = state.copyWith(isProcessing: true);

    try {
      // 处理数据
      final result = handler.processReceivedData(data);

      if (result != null) {
        // 应用延迟
        if (globalConfig.globalDelayMs > 0) {
          await Future<void>.delayed(
            Duration(milliseconds: globalConfig.globalDelayMs),
          );
        }

        // 发送回复
        await _sendReply(result.responseData);

        // 更新顺序索引（如果是顺序回复模式）
        if (handler is SequentialReplyHandler) {
          await ref
              .read(sequentialReplyConfigProvider.notifier)
              .setCurrentIndex(handler.currentIndex);
        }

        // 更新统计
        state = state.copyWith(
          stats: state.stats.copyWith(
            totalReplied: state.stats.totalReplied + 1,
            lastMatchedRule: result.matchedRuleName,
            lastReplyTime: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      state = state.copyWith(lastError: e.toString());
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }

  /// 获取当前活动的处理器
  ReplyHandler? _getHandler(AutoReplyConfig globalConfig) {
    switch (globalConfig.activeMode) {
      case AutoReplyMode.matchReply:
        final matchConfigAsync = ref.read(matchReplyConfigProvider);
        final matchConfig = _getValueOrNull(matchConfigAsync);
        if (matchConfig == null) return null;
        return MatchReplyHandler(config: matchConfig);
      case AutoReplyMode.sequentialReply:
        final seqConfigAsync = ref.read(sequentialReplyConfigProvider);
        final seqConfig = _getValueOrNull(seqConfigAsync);
        if (seqConfig == null) return null;
        return SequentialReplyHandler(config: seqConfig);
    }
  }

  /// 发送回复数据
  Future<void> _sendReply(Uint8List data) async {
    final connectionState = ref.read(serialConnectionProvider);
    if (!connectionState.isConnected) return;

    await ref.read(serialConnectionProvider.notifier).sendData(data);

    // 记录发送日志
    ref.read(serialDataLogProvider.notifier).addSentData(data);
  }

  /// 重置统计
  void resetStats() {
    state = state.copyWith(stats: const AutoReplyStats(), lastError: null);
  }

  /// 手动触发处理（用于测试）
  Future<void> manualProcess(Uint8List data) async {
    await _onDataReceived(data);
  }
}

/// 自动回复统计 Provider（只读）
@riverpod
AutoReplyStats autoReplyStats(Ref ref) {
  return ref.watch(autoReplyEngineProvider).stats;
}

/// 自动回复是否正在处理 Provider
@riverpod
bool autoReplyProcessing(Ref ref) {
  return ref.watch(autoReplyEngineProvider).isProcessing;
}
