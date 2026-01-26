import 'package:equatable/equatable.dart';

import 'chart_types.dart';

/// 示波器状态
class OscilloscopeState extends Equatable {
  const OscilloscopeState({
    this.config = const OscilloscopeConfig(),
    this.channelData = const {},
    this.isRunning = false,
    this.isPaused = false,
    this.cursorInfo,
    this.startTime,
  });

  /// 示波器配置
  final OscilloscopeConfig config;

  /// 各通道的数据 {channelId: [dataPoints]}
  final Map<String, List<ChartDataPoint>> channelData;

  /// 是否正在运行（数据采集中）
  final bool isRunning;

  /// 是否暂停（暂停绘制但继续采集）
  final bool isPaused;

  /// 游标信息
  final CursorInfo? cursorInfo;

  /// 采集开始时间
  final DateTime? startTime;

  /// 获取指定通道的数据
  List<ChartDataPoint> getChannelData(String channelId) {
    return channelData[channelId] ?? [];
  }

  /// 获取所有可见通道
  List<ChartChannel> get visibleChannels {
    return config.channels.where((c) => c.isVisible).toList();
  }

  /// 计算 Y 轴范围（自动模式）
  ({double min, double max}) calculateYRange() {
    if (!config.autoScaleY) {
      return (min: config.minY, max: config.maxY);
    }

    double minValue = double.infinity;
    double maxValue = double.negativeInfinity;

    for (final channel in config.channels) {
      if (!channel.isVisible) continue;
      final data = channelData[channel.id];
      if (data == null || data.isEmpty) continue;

      for (final point in data) {
        if (point.value < minValue) minValue = point.value;
        if (point.value > maxValue) maxValue = point.value;
      }
    }

    if (minValue == double.infinity || maxValue == double.negativeInfinity) {
      return (min: 0.0, max: 100.0);
    }

    // 添加 10% 边距
    final range = maxValue - minValue;
    final margin = range * 0.1;
    return (min: minValue - margin, max: maxValue + margin);
  }

  OscilloscopeState copyWith({
    OscilloscopeConfig? config,
    Map<String, List<ChartDataPoint>>? channelData,
    bool? isRunning,
    bool? isPaused,
    CursorInfo? cursorInfo,
    DateTime? startTime,
    bool clearCursorInfo = false,
    bool clearStartTime = false,
  }) {
    return OscilloscopeState(
      config: config ?? this.config,
      channelData: channelData ?? this.channelData,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      cursorInfo: clearCursorInfo ? null : (cursorInfo ?? this.cursorInfo),
      startTime: clearStartTime ? null : (startTime ?? this.startTime),
    );
  }

  @override
  List<Object?> get props => [
    config,
    channelData,
    isRunning,
    isPaused,
    cursorInfo,
    startTime,
  ];
}

/// 字段信息（用于通道选择）
class FieldInfo extends Equatable {
  const FieldInfo({
    required this.id,
    required this.name,
    required this.typeName,
    this.configName,
  });

  final String id;
  final String name;
  final String typeName;
  final String? configName;

  @override
  List<Object?> get props => [id, name, typeName, configName];
}

/// 通道选择器状态
class ChannelSelectorState extends Equatable {
  const ChannelSelectorState({
    this.availableFields = const [],
    this.selectedFieldIds = const {},
  });

  /// 可用的协议解析字段列表
  final List<FieldInfo> availableFields;

  /// 已选择的字段 ID 集合
  final Set<String> selectedFieldIds;

  ChannelSelectorState copyWith({
    List<FieldInfo>? availableFields,
    Set<String>? selectedFieldIds,
  }) {
    return ChannelSelectorState(
      availableFields: availableFields ?? this.availableFields,
      selectedFieldIds: selectedFieldIds ?? this.selectedFieldIds,
    );
  }

  @override
  List<Object?> get props => [availableFields, selectedFieldIds];
}
