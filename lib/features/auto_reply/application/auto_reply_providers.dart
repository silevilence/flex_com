import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/auto_reply_config_service.dart';
import '../domain/auto_reply_config.dart';
import '../domain/auto_reply_mode.dart';
import '../domain/match_reply_config.dart';
import '../domain/reply_handler.dart';
import '../domain/sequential_reply_config.dart';

part 'auto_reply_providers.g.dart';

/// 辅助方法：安全获取 AsyncValue 的值
T? _getValueOrNull<T>(AsyncValue<T> asyncValue) {
  return asyncValue.when(
    data: (data) => data,
    loading: () => null,
    error: (_, __) => null,
  );
}

/// 自动回复配置服务 Provider
@Riverpod(keepAlive: true)
AutoReplyConfigService autoReplyConfigService(Ref ref) {
  return AutoReplyConfigService();
}

/// 全局自动回复配置 Provider
@Riverpod(keepAlive: true)
class AutoReplyConfigNotifier extends _$AutoReplyConfigNotifier {
  @override
  Future<AutoReplyConfig> build() async {
    final service = ref.watch(autoReplyConfigServiceProvider);
    return service.loadGlobalConfig();
  }

  AutoReplyConfigService get _service =>
      ref.read(autoReplyConfigServiceProvider);

  /// 切换启用状态
  Future<void> toggleEnabled() async {
    final current = _getValueOrNull(state) ?? const AutoReplyConfig();
    final updated = current.copyWith(enabled: !current.enabled);
    state = AsyncData(updated);
    await _service.saveGlobalConfig(updated);
  }

  /// 设置启用状态
  Future<void> setEnabled(bool enabled) async {
    final current = _getValueOrNull(state) ?? const AutoReplyConfig();
    final updated = current.copyWith(enabled: enabled);
    state = AsyncData(updated);
    await _service.saveGlobalConfig(updated);
  }

  /// 设置全局延迟
  Future<void> setGlobalDelay(int delayMs) async {
    final current = _getValueOrNull(state) ?? const AutoReplyConfig();
    final updated = current.copyWith(globalDelayMs: delayMs);
    state = AsyncData(updated);
    await _service.saveGlobalConfig(updated);
  }

  /// 设置活动模式
  Future<void> setActiveMode(AutoReplyMode mode) async {
    final current = _getValueOrNull(state) ?? const AutoReplyConfig();
    final updated = current.copyWith(activeMode: mode);
    state = AsyncData(updated);
    await _service.saveGlobalConfig(updated);
  }
}

/// 匹配回复配置 Provider
@Riverpod(keepAlive: true)
class MatchReplyConfigNotifier extends _$MatchReplyConfigNotifier {
  @override
  Future<MatchReplyConfig> build() async {
    final service = ref.watch(autoReplyConfigServiceProvider);
    return service.loadMatchReplyConfig();
  }

  AutoReplyConfigService get _service =>
      ref.read(autoReplyConfigServiceProvider);

  /// 添加规则
  Future<void> addRule(MatchReplyRule rule) async {
    final current = _getValueOrNull(state) ?? const MatchReplyConfig();
    final updated = current.copyWith(rules: [...current.rules, rule]);
    state = AsyncData(updated);
    await _service.saveMatchReplyConfig(updated);
  }

  /// 更新规则
  Future<void> updateRule(MatchReplyRule rule) async {
    final current = _getValueOrNull(state) ?? const MatchReplyConfig();
    final index = current.rules.indexWhere((r) => r.id == rule.id);
    if (index == -1) return;

    final newRules = [...current.rules];
    newRules[index] = rule;
    final updated = current.copyWith(rules: newRules);
    state = AsyncData(updated);
    await _service.saveMatchReplyConfig(updated);
  }

  /// 删除规则
  Future<void> deleteRule(String ruleId) async {
    final current = _getValueOrNull(state) ?? const MatchReplyConfig();
    final newRules = current.rules.where((r) => r.id != ruleId).toList();
    final updated = current.copyWith(rules: newRules);
    state = AsyncData(updated);
    await _service.saveMatchReplyConfig(updated);
  }

  /// 切换规则启用状态
  Future<void> toggleRuleEnabled(String ruleId) async {
    final current = _getValueOrNull(state) ?? const MatchReplyConfig();
    final index = current.rules.indexWhere((r) => r.id == ruleId);
    if (index == -1) return;

    final rule = current.rules[index];
    final updatedRule = rule.copyWith(enabled: !rule.enabled);
    await updateRule(updatedRule);
  }

  /// 重新排序规则
  Future<void> reorderRules(int oldIndex, int newIndex) async {
    final current = _getValueOrNull(state) ?? const MatchReplyConfig();
    if (oldIndex < 0 ||
        oldIndex >= current.rules.length ||
        newIndex < 0 ||
        newIndex >= current.rules.length) {
      return;
    }

    final newRules = [...current.rules];
    final rule = newRules.removeAt(oldIndex);
    newRules.insert(newIndex, rule);
    final updated = current.copyWith(rules: newRules);
    state = AsyncData(updated);
    await _service.saveMatchReplyConfig(updated);
  }
}

/// 顺序回复配置 Provider
@Riverpod(keepAlive: true)
class SequentialReplyConfigNotifier extends _$SequentialReplyConfigNotifier {
  @override
  Future<SequentialReplyConfig> build() async {
    final service = ref.watch(autoReplyConfigServiceProvider);
    return service.loadSequentialReplyConfig();
  }

  AutoReplyConfigService get _service =>
      ref.read(autoReplyConfigServiceProvider);

  /// 添加帧
  Future<void> addFrame(SequentialReplyFrame frame) async {
    final current = _getValueOrNull(state) ?? const SequentialReplyConfig();
    final updated = current.copyWith(frames: [...current.frames, frame]);
    state = AsyncData(updated);
    await _service.saveSequentialReplyConfig(updated);
  }

  /// 更新帧
  Future<void> updateFrame(SequentialReplyFrame frame) async {
    final current = _getValueOrNull(state) ?? const SequentialReplyConfig();
    final index = current.frames.indexWhere((f) => f.id == frame.id);
    if (index == -1) return;

    final newFrames = [...current.frames];
    newFrames[index] = frame;
    final updated = current.copyWith(frames: newFrames);
    state = AsyncData(updated);
    await _service.saveSequentialReplyConfig(updated);
  }

  /// 删除帧
  Future<void> deleteFrame(String frameId) async {
    final current = _getValueOrNull(state) ?? const SequentialReplyConfig();
    final newFrames = current.frames.where((f) => f.id != frameId).toList();
    final updated = current.copyWith(frames: newFrames);
    state = AsyncData(updated);
    await _service.saveSequentialReplyConfig(updated);
  }

  /// 设置当前索引
  Future<void> setCurrentIndex(int index) async {
    final current = _getValueOrNull(state) ?? const SequentialReplyConfig();
    if (index < 0 || index >= current.frames.length) return;
    final updated = current.copyWith(currentIndex: index);
    state = AsyncData(updated);
    await _service.saveSequentialReplyConfig(updated);
  }

  /// 重置到第一帧
  Future<void> resetToFirst() async {
    final current = _getValueOrNull(state) ?? const SequentialReplyConfig();
    final updated = current.copyWith(currentIndex: 0);
    state = AsyncData(updated);
    await _service.saveSequentialReplyConfig(updated);
  }

  /// 切换循环模式
  Future<void> toggleLoop() async {
    final current = _getValueOrNull(state) ?? const SequentialReplyConfig();
    final updated = current.copyWith(loopEnabled: !current.loopEnabled);
    state = AsyncData(updated);
    await _service.saveSequentialReplyConfig(updated);
  }

  /// 设置循环模式
  Future<void> setLoopEnabled(bool enabled) async {
    final current = _getValueOrNull(state) ?? const SequentialReplyConfig();
    final updated = current.copyWith(loopEnabled: enabled);
    state = AsyncData(updated);
    await _service.saveSequentialReplyConfig(updated);
  }

  /// 重新排序帧
  Future<void> reorderFrames(int oldIndex, int newIndex) async {
    final current = _getValueOrNull(state) ?? const SequentialReplyConfig();
    if (oldIndex < 0 ||
        oldIndex >= current.frames.length ||
        newIndex < 0 ||
        newIndex >= current.frames.length) {
      return;
    }

    final newFrames = [...current.frames];
    final frame = newFrames.removeAt(oldIndex);
    newFrames.insert(newIndex, frame);
    final updated = current.copyWith(frames: newFrames);
    state = AsyncData(updated);
    await _service.saveSequentialReplyConfig(updated);
  }
}

/// 当前活动的回复处理器 Provider
///
/// 根据全局配置自动选择对应的处理器实现
@riverpod
ReplyHandler? activeReplyHandler(Ref ref) {
  final globalConfigAsync = ref.watch(autoReplyConfigProvider);

  // 等待配置加载完成
  final globalConfig = _getValueOrNull(globalConfigAsync);
  if (globalConfig == null) return null;

  // 如果功能未启用，返回 null
  if (!globalConfig.enabled) return null;

  switch (globalConfig.activeMode) {
    case AutoReplyMode.matchReply:
      final matchConfigAsync = ref.watch(matchReplyConfigProvider);
      final matchConfig = _getValueOrNull(matchConfigAsync);
      if (matchConfig == null) return null;
      return MatchReplyHandler(config: matchConfig);
    case AutoReplyMode.sequentialReply:
      final seqConfigAsync = ref.watch(sequentialReplyConfigProvider);
      final seqConfig = _getValueOrNull(seqConfigAsync);
      if (seqConfig == null) return null;
      return SequentialReplyHandler(config: seqConfig);
    case AutoReplyMode.scriptReply:
      // 脚本回复模式由 HookService 处理，不使用传统 Handler
      return null;
  }
}
