import 'package:equatable/equatable.dart';

import 'match_reply_config.dart';

/// 顺序回复帧
///
/// 定义顺序回复模式中的单个数据帧
class SequentialReplyFrame extends Equatable {
  const SequentialReplyFrame({
    required this.id,
    required this.name,
    required this.data,
    this.mode = DataMode.hex,
  });

  /// 帧唯一标识符
  final String id;

  /// 帧名称（用于 UI 显示）
  final String name;

  /// 帧数据
  final String data;

  /// 数据编码模式
  final DataMode mode;

  /// 创建副本并更新指定字段
  SequentialReplyFrame copyWith({
    String? id,
    String? name,
    String? data,
    DataMode? mode,
  }) {
    return SequentialReplyFrame(
      id: id ?? this.id,
      name: name ?? this.name,
      data: data ?? this.data,
      mode: mode ?? this.mode,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'data': data, 'mode': mode.name};
  }

  /// 从 JSON 创建
  factory SequentialReplyFrame.fromJson(Map<String, dynamic> json) {
    return SequentialReplyFrame(
      id: json['id'] as String,
      name: json['name'] as String,
      data: json['data'] as String,
      mode: DataMode.values.firstWhere(
        (m) => m.name == json['mode'],
        orElse: () => DataMode.hex,
      ),
    );
  }

  @override
  List<Object?> get props => [id, name, data, mode];
}

/// 顺序回复模式配置
///
/// 包含顺序回复所需的帧列表和状态
class SequentialReplyConfig extends Equatable {
  const SequentialReplyConfig({
    this.frames = const [],
    this.currentIndex = 0,
    this.loopEnabled = false,
  });

  /// 预设帧列表
  final List<SequentialReplyFrame> frames;

  /// 当前回复位置索引
  final int currentIndex;

  /// 是否启用循环（列表末尾后回到开头）
  final bool loopEnabled;

  /// 创建副本并更新指定字段
  SequentialReplyConfig copyWith({
    List<SequentialReplyFrame>? frames,
    int? currentIndex,
    bool? loopEnabled,
  }) {
    return SequentialReplyConfig(
      frames: frames ?? this.frames,
      currentIndex: currentIndex ?? this.currentIndex,
      loopEnabled: loopEnabled ?? this.loopEnabled,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'frames': frames.map((f) => f.toJson()).toList(),
      'currentIndex': currentIndex,
      'loopEnabled': loopEnabled,
    };
  }

  /// 从 JSON 创建
  factory SequentialReplyConfig.fromJson(Map<String, dynamic> json) {
    final framesList = json['frames'] as List<dynamic>?;
    return SequentialReplyConfig(
      frames:
          framesList
              ?.whereType<Map<String, dynamic>>()
              .map((e) => SequentialReplyFrame.fromJson(e))
              .toList() ??
          [],
      currentIndex: json['currentIndex'] as int? ?? 0,
      loopEnabled: json['loopEnabled'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [frames, currentIndex, loopEnabled];
}
