import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// Hook 类型枚举
///
/// 定义脚本可挂载的 Hook 点类型
enum HookType {
  /// 接收数据预处理器
  /// 在数据到达应用层之前对原始接收数据进行处理（如解密、解封装）
  rxPreProcessor,

  /// 发送数据后处理器
  /// 在数据发送之前对数据进行处理（如加密、封包、添加校验）
  txPostProcessor,

  /// 自动回复脚本模式
  /// 接收到数据后执行脚本判断是否需要回复及回复内容
  replyHook,

  /// 手动任务
  /// 用户手动触发执行的一次性任务（如发包序列、压力测试）
  taskHook;

  /// UI 显示名称
  String get displayName {
    switch (this) {
      case HookType.rxPreProcessor:
        return 'Rx 预处理器';
      case HookType.txPostProcessor:
        return 'Tx 后处理器';
      case HookType.replyHook:
        return '脚本回复';
      case HookType.taskHook:
        return '手动任务';
    }
  }

  /// 描述
  String get description {
    switch (this) {
      case HookType.rxPreProcessor:
        return '接收数据到达前进行预处理（解密、解封装等）';
      case HookType.txPostProcessor:
        return '发送数据前进行后处理（加密、封包、校验等）';
      case HookType.replyHook:
        return '使用脚本实现复杂的条件判断应答逻辑';
      case HookType.taskHook:
        return '手动触发执行发包序列或自动化测试';
    }
  }
}

/// Hook 执行结果
class HookExecutionResult {
  /// 是否成功
  final bool success;

  /// 处理后的数据（对于 Pipeline Hook）
  final Uint8List? processedData;

  /// 要发送的响应数据（对于 Reply Hook）
  final Uint8List? responseData;

  /// 错误信息
  final String? errorMessage;

  /// 执行时长（毫秒）
  final int durationMs;

  /// 是否应该继续处理（用于 Reply Hook，返回 false 表示不回复）
  final bool shouldContinue;

  const HookExecutionResult({
    required this.success,
    this.processedData,
    this.responseData,
    this.errorMessage,
    required this.durationMs,
    this.shouldContinue = true,
  });

  factory HookExecutionResult.success({
    Uint8List? processedData,
    Uint8List? responseData,
    required int durationMs,
    bool shouldContinue = true,
  }) {
    return HookExecutionResult(
      success: true,
      processedData: processedData,
      responseData: responseData,
      durationMs: durationMs,
      shouldContinue: shouldContinue,
    );
  }

  factory HookExecutionResult.failure({
    required String errorMessage,
    required int durationMs,
  }) {
    return HookExecutionResult(
      success: false,
      errorMessage: errorMessage,
      durationMs: durationMs,
      shouldContinue: false,
    );
  }

  /// 创建跳过结果（不需要处理）
  factory HookExecutionResult.skip({required int durationMs}) {
    return HookExecutionResult(
      success: true,
      durationMs: durationMs,
      shouldContinue: false,
    );
  }
}

/// 脚本 Hook 配置
///
/// 将脚本绑定到特定 Hook 点
class ScriptHookBinding extends Equatable {
  /// 绑定唯一 ID
  final String id;

  /// 关联的脚本 ID
  final String scriptId;

  /// Hook 类型
  final HookType hookType;

  /// 是否启用
  final bool enabled;

  /// 优先级（数值越小优先级越高，用于同类型多个 Hook 排序）
  final int priority;

  /// 创建时间
  final DateTime createdAt;

  /// 描述/备注
  final String? description;

  const ScriptHookBinding({
    required this.id,
    required this.scriptId,
    required this.hookType,
    this.enabled = true,
    this.priority = 100,
    required this.createdAt,
    this.description,
  });

  ScriptHookBinding copyWith({
    String? id,
    String? scriptId,
    HookType? hookType,
    bool? enabled,
    int? priority,
    DateTime? createdAt,
    String? description,
  }) {
    return ScriptHookBinding(
      id: id ?? this.id,
      scriptId: scriptId ?? this.scriptId,
      hookType: hookType ?? this.hookType,
      enabled: enabled ?? this.enabled,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scriptId': scriptId,
      'hookType': hookType.name,
      'enabled': enabled,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'description': description,
    };
  }

  factory ScriptHookBinding.fromJson(Map<String, dynamic> json) {
    return ScriptHookBinding(
      id: json['id'] as String,
      scriptId: json['scriptId'] as String,
      hookType: HookType.values.firstWhere(
        (t) => t.name == json['hookType'],
        orElse: () => HookType.taskHook,
      ),
      enabled: json['enabled'] as bool? ?? true,
      priority: json['priority'] as int? ?? 100,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      description: json['description'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    scriptId,
    hookType,
    enabled,
    priority,
    createdAt,
    description,
  ];
}

/// Pipeline Hook 上下文
///
/// 传递给 Pipeline Hook 脚本的上下文信息
class PipelineHookContext {
  /// 原始数据
  final Uint8List rawData;

  /// 数据方向：true = 接收, false = 发送
  final bool isRx;

  /// 时间戳
  final DateTime timestamp;

  const PipelineHookContext({
    required this.rawData,
    required this.isRx,
    required this.timestamp,
  });
}

/// Reply Hook 上下文
///
/// 传递给 Reply Hook 脚本的上下文信息
class ReplyHookContext {
  /// 接收到的数据
  final Uint8List receivedData;

  /// 接收时间戳
  final DateTime timestamp;

  /// 全局延迟配置（毫秒）
  final int globalDelayMs;

  const ReplyHookContext({
    required this.receivedData,
    required this.timestamp,
    this.globalDelayMs = 0,
  });
}

/// Task Hook 配置
///
/// 手动任务的额外配置
class TaskHookConfig extends Equatable {
  /// 是否显示在工具栏快捷按钮
  final bool showInToolbar;

  /// 快捷键（可选）
  final String? shortcutKey;

  /// 执行前确认
  final bool confirmBeforeRun;

  const TaskHookConfig({
    this.showInToolbar = false,
    this.shortcutKey,
    this.confirmBeforeRun = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'showInToolbar': showInToolbar,
      'shortcutKey': shortcutKey,
      'confirmBeforeRun': confirmBeforeRun,
    };
  }

  factory TaskHookConfig.fromJson(Map<String, dynamic> json) {
    return TaskHookConfig(
      showInToolbar: json['showInToolbar'] as bool? ?? false,
      shortcutKey: json['shortcutKey'] as String?,
      confirmBeforeRun: json['confirmBeforeRun'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [showInToolbar, shortcutKey, confirmBeforeRun];
}
