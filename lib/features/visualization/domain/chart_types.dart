import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// 图表数据点
class ChartDataPoint extends Equatable {
  const ChartDataPoint({required this.timestamp, required this.value});

  /// 时间戳（毫秒）
  final int timestamp;

  /// 数据值
  final double value;

  @override
  List<Object?> get props => [timestamp, value];
}

/// 数据通道
class ChartChannel extends Equatable {
  const ChartChannel({
    required this.id,
    required this.name,
    required this.fieldId,
    this.color = Colors.blue,
    this.isVisible = true,
    this.lineWidth = 2.0,
  });

  /// 通道唯一标识
  final String id;

  /// 通道名称（显示用）
  final String name;

  /// 关联的协议解析字段 ID
  final String fieldId;

  /// 通道颜色
  final Color color;

  /// 是否显示
  final bool isVisible;

  /// 线宽
  final double lineWidth;

  ChartChannel copyWith({
    String? id,
    String? name,
    String? fieldId,
    Color? color,
    bool? isVisible,
    double? lineWidth,
  }) {
    return ChartChannel(
      id: id ?? this.id,
      name: name ?? this.name,
      fieldId: fieldId ?? this.fieldId,
      color: color ?? this.color,
      isVisible: isVisible ?? this.isVisible,
      lineWidth: lineWidth ?? this.lineWidth,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fieldId': fieldId,
      'color': color.toHex(),
      'isVisible': isVisible,
      'lineWidth': lineWidth,
    };
  }

  factory ChartChannel.fromJson(Map<String, dynamic> json) {
    return ChartChannel(
      id: json['id'] as String,
      name: json['name'] as String,
      fieldId: json['fieldId'] as String,
      color: _colorFromHex(json['color'] as String? ?? '#2196F3'),
      isVisible: json['isVisible'] as bool? ?? true,
      lineWidth: (json['lineWidth'] as num?)?.toDouble() ?? 2.0,
    );
  }

  @override
  List<Object?> get props => [id, name, fieldId, color, isVisible, lineWidth];
}

/// 示波器配置
class OscilloscopeConfig extends Equatable {
  const OscilloscopeConfig({
    this.channels = const [],
    this.timeWindowMs = 10000,
    this.maxDataPoints = 1000,
    this.autoScaleY = true,
    this.minY = 0,
    this.maxY = 100,
    this.gridEnabled = true,
    this.showLegend = true,
    this.refreshRateMs = 50,
  });

  /// 数据通道列表
  final List<ChartChannel> channels;

  /// 时间窗口（毫秒）- X 轴显示的时间范围
  final int timeWindowMs;

  /// 最大数据点数（超过后自动丢弃旧数据）
  final int maxDataPoints;

  /// 是否自动缩放 Y 轴
  final bool autoScaleY;

  /// Y 轴最小值（手动模式）
  final double minY;

  /// Y 轴最大值（手动模式）
  final double maxY;

  /// 是否显示网格
  final bool gridEnabled;

  /// 是否显示图例
  final bool showLegend;

  /// 刷新率（毫秒）
  final int refreshRateMs;

  OscilloscopeConfig copyWith({
    List<ChartChannel>? channels,
    int? timeWindowMs,
    int? maxDataPoints,
    bool? autoScaleY,
    double? minY,
    double? maxY,
    bool? gridEnabled,
    bool? showLegend,
    int? refreshRateMs,
  }) {
    return OscilloscopeConfig(
      channels: channels ?? this.channels,
      timeWindowMs: timeWindowMs ?? this.timeWindowMs,
      maxDataPoints: maxDataPoints ?? this.maxDataPoints,
      autoScaleY: autoScaleY ?? this.autoScaleY,
      minY: minY ?? this.minY,
      maxY: maxY ?? this.maxY,
      gridEnabled: gridEnabled ?? this.gridEnabled,
      showLegend: showLegend ?? this.showLegend,
      refreshRateMs: refreshRateMs ?? this.refreshRateMs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'channels': channels.map((c) => c.toJson()).toList(),
      'timeWindowMs': timeWindowMs,
      'maxDataPoints': maxDataPoints,
      'autoScaleY': autoScaleY,
      'minY': minY,
      'maxY': maxY,
      'gridEnabled': gridEnabled,
      'showLegend': showLegend,
      'refreshRateMs': refreshRateMs,
    };
  }

  factory OscilloscopeConfig.fromJson(Map<String, dynamic> json) {
    return OscilloscopeConfig(
      channels:
          (json['channels'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => ChartChannel.fromJson(e))
              .toList() ??
          [],
      timeWindowMs: json['timeWindowMs'] as int? ?? 10000,
      maxDataPoints: json['maxDataPoints'] as int? ?? 1000,
      autoScaleY: json['autoScaleY'] as bool? ?? true,
      minY: (json['minY'] as num?)?.toDouble() ?? 0,
      maxY: (json['maxY'] as num?)?.toDouble() ?? 100,
      gridEnabled: json['gridEnabled'] as bool? ?? true,
      showLegend: json['showLegend'] as bool? ?? true,
      refreshRateMs: json['refreshRateMs'] as int? ?? 50,
    );
  }

  @override
  List<Object?> get props => [
    channels,
    timeWindowMs,
    maxDataPoints,
    autoScaleY,
    minY,
    maxY,
    gridEnabled,
    showLegend,
    refreshRateMs,
  ];
}

/// 游标信息
class CursorInfo extends Equatable {
  const CursorInfo({
    required this.x,
    required this.y,
    required this.timestamp,
    this.channelValues = const {},
  });

  /// X 坐标（屏幕坐标）
  final double x;

  /// Y 坐标（屏幕坐标）
  final double y;

  /// 时间戳
  final int timestamp;

  /// 各通道在该时刻的值 {channelId: value}
  final Map<String, double> channelValues;

  @override
  List<Object?> get props => [x, y, timestamp, channelValues];
}

/// 预定义通道颜色
class ChannelColors {
  ChannelColors._();

  static const List<Color> colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.cyan,
    Colors.pink,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
  ];

  static Color getColor(int index) {
    return colors[index % colors.length];
  }
}

// Helper extensions
extension ColorExtension on Color {
  String toHex() {
    return '#${(toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}

Color _colorFromHex(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 6 || hex.length == 7) {
    buffer.write('ff');
  }
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}
