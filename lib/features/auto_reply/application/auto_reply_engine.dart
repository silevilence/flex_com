import 'dart:async';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../connection/application/connection_providers.dart';
import '../../scripting/application/hook_service.dart';
import '../../serial/application/serial_data_providers.dart';
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
/// 监听连接数据流，自动处理接收到的数据并发送回复
@Riverpod(keepAlive: true)
class AutoReplyEngine extends _$AutoReplyEngine {
  StreamSubscription<Uint8List>? _subscription;

  @override
  AutoReplyEngineState build() {
    // 监听连接状态变化（使用 listen 而非 watch，避免重建）
    ref.listen<UnifiedConnectionState>(unifiedConnectionProvider, (
      previous,
      next,
    ) {
      _handleConnectionChange(previous, next);
    }, fireImmediately: true);

    ref.onDispose(() {
      _subscription?.cancel();
      _subscription = null;
    });

    return const AutoReplyEngineState();
  }

  void _handleConnectionChange(
    UnifiedConnectionState? previous,
    UnifiedConnectionState next,
  ) {
    final wasConnected = previous?.isConnected ?? false;
    final isConnected = next.isConnected;

    // 只在连接状态实际变化时重新订阅
    if (wasConnected != isConnected) {
      _subscription?.cancel();
      _subscription = null;

      if (isConnected) {
        final notifier = ref.read(unifiedConnectionProvider.notifier);
        final stream = notifier.dataStream;
        if (stream != null) {
          _subscription = stream.listen(
            (data) {
              // IMPORTANT: Copy data immediately before async processing
              // libserialport may reuse/free the buffer after callback returns
              final dataCopy = Uint8List.fromList(data);
              _onDataReceived(dataCopy);
            },
            onError: (Object error) {
              // 忽略流错误以防止崩溃
            },
          );
        }
      }
    }
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

    // 脚本模式使用 HookService 处理
    if (globalConfig.activeMode == AutoReplyMode.scriptReply) {
      await _processScriptReply(data, globalConfig);
      return;
    }

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
      case AutoReplyMode.scriptReply:
        // 脚本模式不使用传统 Handler，返回 null
        return null;
    }
  }

  /// 处理脚本回复模式
  Future<void> _processScriptReply(
    Uint8List data,
    AutoReplyConfig globalConfig,
  ) async {
    state = state.copyWith(isProcessing: true);

    try {
      final hookService = ref.read(hookServiceProvider.notifier);
      final responseData = await hookService.processReplyHook(
        data,
        globalDelayMs: globalConfig.globalDelayMs,
      );

      if (responseData != null) {
        // 应用延迟
        if (globalConfig.globalDelayMs > 0) {
          await Future<void>.delayed(
            Duration(milliseconds: globalConfig.globalDelayMs),
          );
        }

        // 发送回复
        await _sendReply(responseData);

        // 更新统计
        state = state.copyWith(
          stats: state.stats.copyWith(
            totalReplied: state.stats.totalReplied + 1,
            lastMatchedRule: '脚本回复',
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

  /// 发送回复数据
  Future<void> _sendReply(Uint8List data) async {
    final connectionState = ref.read(unifiedConnectionProvider);
    if (!connectionState.isConnected) return;

    await ref.read(unifiedConnectionProvider.notifier).send(data);

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
