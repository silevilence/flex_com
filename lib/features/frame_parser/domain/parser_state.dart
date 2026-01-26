import 'package:equatable/equatable.dart';

import 'frame_config.dart';
import 'protocol_parser.dart';

/// 解析器状态
class ParserState extends Equatable {
  const ParserState({
    this.configs = const [],
    this.activeConfigId,
    this.isEnabled = false,
    this.lastParsedFrame,
    this.parseHistory = const [],
    this.errorMessage,
  });

  /// 已保存的帧配置列表
  final List<FrameConfig> configs;

  /// 当前激活的配置 ID
  final String? activeConfigId;

  /// 解析器是否启用
  final bool isEnabled;

  /// 最近一次解析的帧
  final ParsedFrame? lastParsedFrame;

  /// 解析历史记录
  final List<ParsedFrame> parseHistory;

  /// 错误信息
  final String? errorMessage;

  /// 获取当前激活的配置
  FrameConfig? get activeConfig {
    if (activeConfigId == null) return null;
    try {
      return configs.firstWhere((c) => c.id == activeConfigId);
    } catch (_) {
      return null;
    }
  }

  ParserState copyWith({
    List<FrameConfig>? configs,
    String? activeConfigId,
    bool? isEnabled,
    ParsedFrame? lastParsedFrame,
    List<ParsedFrame>? parseHistory,
    String? errorMessage,
    bool clearActiveConfigId = false,
    bool clearLastParsedFrame = false,
    bool clearErrorMessage = false,
  }) {
    return ParserState(
      configs: configs ?? this.configs,
      activeConfigId: clearActiveConfigId
          ? null
          : (activeConfigId ?? this.activeConfigId),
      isEnabled: isEnabled ?? this.isEnabled,
      lastParsedFrame: clearLastParsedFrame
          ? null
          : (lastParsedFrame ?? this.lastParsedFrame),
      parseHistory: parseHistory ?? this.parseHistory,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    configs,
    activeConfigId,
    isEnabled,
    lastParsedFrame,
    parseHistory,
    errorMessage,
  ];
}

/// 编辑器状态（用于 UI 配置编辑）
class EditorState extends Equatable {
  const EditorState({
    this.editingConfig,
    this.editingFieldIndex,
    this.isModified = false,
  });

  /// 正在编辑的配置
  final FrameConfig? editingConfig;

  /// 正在编辑的字段索引（null 表示未编辑字段）
  final int? editingFieldIndex;

  /// 是否有未保存的修改
  final bool isModified;

  EditorState copyWith({
    FrameConfig? editingConfig,
    int? editingFieldIndex,
    bool? isModified,
    bool clearEditingConfig = false,
    bool clearEditingFieldIndex = false,
  }) {
    return EditorState(
      editingConfig: clearEditingConfig
          ? null
          : (editingConfig ?? this.editingConfig),
      editingFieldIndex: clearEditingFieldIndex
          ? null
          : (editingFieldIndex ?? this.editingFieldIndex),
      isModified: isModified ?? this.isModified,
    );
  }

  @override
  List<Object?> get props => [editingConfig, editingFieldIndex, isModified];
}
