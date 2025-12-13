import 'package:equatable/equatable.dart';

import 'auto_reply_mode.dart';

/// 自动回复全局配置
///
/// 包含自动回复功能的全局设置，如总开关、全局延迟、当前激活模式等。
/// 此配置独立于各模式的具体配置，用于控制整体行为。
class AutoReplyConfig extends Equatable {
  const AutoReplyConfig({
    this.enabled = false,
    this.globalDelayMs = 0,
    this.activeMode = AutoReplyMode.matchReply,
  });

  /// 自动回复总开关
  final bool enabled;

  /// 全局回复延迟（毫秒）
  /// 收到数据后等待指定时间再发送回复
  final int globalDelayMs;

  /// 当前激活的回复模式
  final AutoReplyMode activeMode;

  /// 创建副本并更新指定字段
  AutoReplyConfig copyWith({
    bool? enabled,
    int? globalDelayMs,
    AutoReplyMode? activeMode,
  }) {
    return AutoReplyConfig(
      enabled: enabled ?? this.enabled,
      globalDelayMs: globalDelayMs ?? this.globalDelayMs,
      activeMode: activeMode ?? this.activeMode,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'globalDelayMs': globalDelayMs,
      'activeMode': activeMode.name,
    };
  }

  /// 从 JSON 创建
  factory AutoReplyConfig.fromJson(Map<String, dynamic> json) {
    return AutoReplyConfig(
      enabled: json['enabled'] as bool? ?? false,
      globalDelayMs: json['globalDelayMs'] as int? ?? 0,
      activeMode: AutoReplyMode.values.firstWhere(
        (m) => m.name == json['activeMode'],
        orElse: () => AutoReplyMode.matchReply,
      ),
    );
  }

  @override
  List<Object?> get props => [enabled, globalDelayMs, activeMode];

  @override
  String toString() {
    return 'AutoReplyConfig(enabled: $enabled, globalDelayMs: $globalDelayMs, '
        'activeMode: $activeMode)';
  }
}
