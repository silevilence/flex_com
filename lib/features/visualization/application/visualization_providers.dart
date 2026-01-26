import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../frame_parser/application/parser_providers.dart';
import '../../frame_parser/domain/protocol_parser.dart';
import '../data/oscilloscope_config_repository.dart';
import '../domain/chart_types.dart';
import '../domain/oscilloscope_state.dart';

part 'visualization_providers.g.dart';

/// 配置仓库 Provider
@Riverpod(keepAlive: true)
OscilloscopeConfigRepository oscilloscopeConfigRepository(Ref ref) {
  return OscilloscopeConfigRepository.instance;
}

/// 示波器状态管理
@riverpod
class OscilloscopeNotifier extends _$OscilloscopeNotifier {
  Timer? _refreshTimer;

  // 数据缓冲区，在定时器触发时才更新到状态
  final Map<String, List<ChartDataPoint>> _dataBuffer = {};
  bool _hasNewData = false;

  @override
  Future<OscilloscopeState> build() async {
    final repository = ref.read(oscilloscopeConfigRepositoryProvider);
    final config = await repository.loadConfig();

    ref.onDispose(() {
      _refreshTimer?.cancel();
      _dataBuffer.clear();
    });

    return OscilloscopeState(config: config);
  }

  /// 添加数据通道
  Future<void> addChannel(ChartChannel channel) async {
    final current = await future;
    final newChannels = [...current.config.channels, channel];
    final newConfig = current.config.copyWith(channels: newChannels);

    state = AsyncData(current.copyWith(config: newConfig));

    final repository = ref.read(oscilloscopeConfigRepositoryProvider);
    await repository.saveConfig(newConfig);
  }

  /// 移除数据通道
  Future<void> removeChannel(String channelId) async {
    final current = await future;
    final newChannels = current.config.channels
        .where((c) => c.id != channelId)
        .toList();
    final newConfig = current.config.copyWith(channels: newChannels);

    // 同时移除通道数据
    final newData = Map<String, List<ChartDataPoint>>.from(current.channelData);
    newData.remove(channelId);

    state = AsyncData(
      current.copyWith(config: newConfig, channelData: newData),
    );

    final repository = ref.read(oscilloscopeConfigRepositoryProvider);
    await repository.saveConfig(newConfig);
  }

  /// 更新通道配置
  Future<void> updateChannel(ChartChannel channel) async {
    final current = await future;
    final newChannels = current.config.channels.map((c) {
      return c.id == channel.id ? channel : c;
    }).toList();
    final newConfig = current.config.copyWith(channels: newChannels);

    state = AsyncData(current.copyWith(config: newConfig));

    final repository = ref.read(oscilloscopeConfigRepositoryProvider);
    await repository.saveConfig(newConfig);
  }

  /// 切换通道可见性
  Future<void> toggleChannelVisibility(String channelId) async {
    final current = await future;
    final newChannels = current.config.channels.map((c) {
      if (c.id == channelId) {
        return c.copyWith(isVisible: !c.isVisible);
      }
      return c;
    }).toList();
    final newConfig = current.config.copyWith(channels: newChannels);

    state = AsyncData(current.copyWith(config: newConfig));
  }

  /// 更新示波器配置
  Future<void> updateConfig(OscilloscopeConfig config) async {
    final current = await future;
    state = AsyncData(current.copyWith(config: config));

    final repository = ref.read(oscilloscopeConfigRepositoryProvider);
    await repository.saveConfig(config);
  }

  /// 开始数据采集
  Future<void> start() async {
    final current = await future;
    if (current.isRunning) return;

    state = AsyncData(
      current.copyWith(
        isRunning: true,
        isPaused: false,
        startTime: DateTime.now(),
      ),
    );

    // 启动刷新定时器
    _startRefreshTimer();
  }

  /// 停止数据采集
  Future<void> stop() async {
    final current = await future;
    _refreshTimer?.cancel();
    _refreshTimer = null;

    state = AsyncData(current.copyWith(isRunning: false, isPaused: false));
  }

  /// 暂停/继续绘制
  Future<void> togglePause() async {
    final current = await future;
    if (!current.isRunning) return;

    state = AsyncData(current.copyWith(isPaused: !current.isPaused));
  }

  /// 清空数据
  Future<void> clearData() async {
    final current = await future;
    _dataBuffer.clear();
    _hasNewData = false;
    state = AsyncData(current.copyWith(channelData: {}, clearCursorInfo: true));
  }

  /// 添加数据点（缓冲到内部，由定时器统一更新）
  void addDataPointBuffered(String channelId, ChartDataPoint point) {
    final channelPoints = _dataBuffer[channelId] ?? [];
    channelPoints.add(point);
    _dataBuffer[channelId] = channelPoints;
    _hasNewData = true;
  }

  /// 添加数据点（立即更新状态 - 用于手动添加）
  Future<void> addDataPoint(String channelId, ChartDataPoint point) async {
    final current = await future;
    if (!current.isRunning) return;

    final newData = Map<String, List<ChartDataPoint>>.from(current.channelData);
    final channelPoints = List<ChartDataPoint>.from(newData[channelId] ?? []);
    channelPoints.add(point);

    // 限制数据点数量
    while (channelPoints.length > current.config.maxDataPoints) {
      channelPoints.removeAt(0);
    }

    newData[channelId] = channelPoints;
    state = AsyncData(current.copyWith(channelData: newData));
  }

  /// 批量添加数据点（从解析结果，缓冲模式）
  void addDataFromParsedFrameBuffered(ParsedFrame frame) {
    // 同步方法，仅将数据添加到缓冲区，不更新状态
    final stateValue = state.value;
    if (stateValue == null) {
      debugPrint('[Oscilloscope] state.value 为 null');
      return;
    }
    if (!stateValue.isRunning) {
      debugPrint('[Oscilloscope] 示波器未运行 (需要先点击开始按钮)');
      return;
    }

    debugPrint(
      '[Oscilloscope] 准备添加数据, 通道数=${stateValue.config.channels.length}, frame.config.id=${frame.config.id}',
    );

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    for (final channel in stateValue.config.channels) {
      // channel.fieldId 格式为 "configId:fieldId"，需要解析
      final parts = channel.fieldId.split(':');
      if (parts.length != 2) {
        debugPrint(
          '[Oscilloscope] 通道 ${channel.id} fieldId 格式错误: ${channel.fieldId}',
        );
        continue;
      }

      final configId = parts[0];
      final fieldId = parts[1];

      // 检查是否匹配当前解析的帧配置
      if (frame.config.id != configId) {
        debugPrint(
          '[Oscilloscope] 通道 ${channel.id} configId 不匹配: $configId != ${frame.config.id}',
        );
        continue;
      }

      final field = frame.getField(fieldId);
      if (field == null) {
        debugPrint('[Oscilloscope] 通道 ${channel.id} 找不到字段: $fieldId');
        continue;
      }

      // 尝试将值转换为 double
      final value = _toDouble(field.value);
      if (value == null) {
        debugPrint(
          '[Oscilloscope] 通道 ${channel.id} 值无法转换为 double: ${field.value}',
        );
        continue;
      }

      debugPrint('[Oscilloscope] 添加数据点: 通道=${channel.id}, 值=$value');
      final point = ChartDataPoint(timestamp: timestamp, value: value);
      addDataPointBuffered(channel.id, point);
    }
  }

  /// 批量添加数据点（从解析结果 - 保留原方法兼容性）
  Future<void> addDataFromParsedFrame(ParsedFrame frame) async {
    // 委托给缓冲方法
    addDataFromParsedFrameBuffered(frame);
  }

  /// 设置游标信息
  Future<void> setCursor(CursorInfo? info) async {
    final current = await future;
    state = AsyncData(
      current.copyWith(cursorInfo: info, clearCursorInfo: info == null),
    );
  }

  /// 设置时间窗口
  Future<void> setTimeWindow(int milliseconds) async {
    final current = await future;
    final newConfig = current.config.copyWith(timeWindowMs: milliseconds);
    state = AsyncData(current.copyWith(config: newConfig));

    final repository = ref.read(oscilloscopeConfigRepositoryProvider);
    await repository.saveConfig(newConfig);
  }

  /// 设置 Y 轴范围
  Future<void> setYRange({double? min, double? max, bool? autoScale}) async {
    final current = await future;
    final newConfig = current.config.copyWith(
      minY: min,
      maxY: max,
      autoScaleY: autoScale,
    );
    state = AsyncData(current.copyWith(config: newConfig));

    final repository = ref.read(oscilloscopeConfigRepositoryProvider);
    await repository.saveConfig(newConfig);
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    // 定时器用于将缓冲区数据合并到状态并刷新 UI
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      state.whenData((current) {
        if (!current.isPaused && _hasNewData) {
          // 合并缓冲区数据到当前状态
          final newData = Map<String, List<ChartDataPoint>>.from(
            current.channelData,
          );

          for (final entry in _dataBuffer.entries) {
            final channelId = entry.key;
            final bufferedPoints = entry.value;

            final channelPoints = List<ChartDataPoint>.from(
              newData[channelId] ?? [],
            );
            channelPoints.addAll(bufferedPoints);

            // 限制数据点数量
            while (channelPoints.length > current.config.maxDataPoints) {
              channelPoints.removeAt(0);
            }

            newData[channelId] = channelPoints;
          }

          // 清空缓冲区
          _dataBuffer.clear();
          _hasNewData = false;

          // 更新状态
          state = AsyncData(current.copyWith(channelData: newData));
        }
      });
    });
  }

  double? _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return null;
  }
}

/// 通道选择器状态管理
@riverpod
class ChannelSelectorNotifier extends _$ChannelSelectorNotifier {
  @override
  Future<ChannelSelectorState> build() async {
    // 读取协议解析器配置（仅读取一次，不持续监听）
    // 使用 ref.read 而非 ref.watch 避免每次串口数据更新都触发重建
    final parserState = ref.read(parserProvider);

    final availableFields = <FieldInfo>[];

    parserState.whenData((state) {
      for (final config in state.configs) {
        for (final field in config.fields) {
          // 只添加数值类型的字段
          if (_isNumericField(field.dataType)) {
            availableFields.add(
              FieldInfo(
                id: '${config.id}:${field.id}',
                name: field.name,
                typeName: field.dataType.toString().split('.').last,
                configName: config.name,
              ),
            );
          }
        }
      }
    });

    return ChannelSelectorState(availableFields: availableFields);
  }

  /// 刷新可用字段列表
  Future<void> refreshFields() async {
    final parserState = ref.read(parserProvider);
    final availableFields = <FieldInfo>[];

    parserState.whenData((stateData) {
      for (final config in stateData.configs) {
        for (final field in config.fields) {
          if (_isNumericField(field.dataType)) {
            availableFields.add(
              FieldInfo(
                id: '${config.id}:${field.id}',
                name: field.name,
                typeName: field.dataType.toString().split('.').last,
                configName: config.name,
              ),
            );
          }
        }
      }
    });

    final current = await future;
    state = AsyncData(current.copyWith(availableFields: availableFields));
  }

  /// 选择/取消选择字段
  Future<void> toggleField(String fieldId) async {
    final current = await future;
    final newSelected = Set<String>.from(current.selectedFieldIds);

    if (newSelected.contains(fieldId)) {
      newSelected.remove(fieldId);
    } else {
      newSelected.add(fieldId);
    }

    state = AsyncData(current.copyWith(selectedFieldIds: newSelected));
  }

  /// 从选中的字段创建通道
  Future<List<ChartChannel>> createChannelsFromSelection() async {
    final current = await future;
    final channels = <ChartChannel>[];
    var colorIndex = 0;

    for (final fieldId in current.selectedFieldIds) {
      final field = current.availableFields.firstWhere(
        (f) => f.id == fieldId,
        orElse: () => const FieldInfo(id: '', name: '', typeName: ''),
      );

      if (field.id.isEmpty) continue;

      channels.add(
        ChartChannel(
          id:
              DateTime.now().millisecondsSinceEpoch.toString() +
              colorIndex.toString(),
          name: '${field.configName} - ${field.name}',
          fieldId: fieldId,
          color: ChannelColors.getColor(colorIndex),
        ),
      );

      colorIndex++;
    }

    return channels;
  }

  /// 清空选择
  Future<void> clearSelection() async {
    final current = await future;
    state = AsyncData(current.copyWith(selectedFieldIds: {}));
  }

  bool _isNumericField(dynamic dataType) {
    // 检查数据类型是否为数值类型
    final typeName = dataType.toString().toLowerCase();
    return typeName.contains('int') ||
        typeName.contains('uint') ||
        typeName.contains('float') ||
        typeName.contains('double');
  }
}

/// 便捷 Provider：获取示波器配置
@riverpod
OscilloscopeConfig? oscilloscopeConfig(Ref ref) {
  final state = ref.watch(oscilloscopeProvider);
  return state.whenOrNull(data: (s) => s.config);
}

/// 便捷 Provider：获取是否正在运行
@riverpod
bool isOscilloscopeRunning(Ref ref) {
  final state = ref.watch(oscilloscopeProvider);
  return state.whenOrNull(data: (s) => s.isRunning) ?? false;
}

/// 便捷 Provider：获取是否暂停
@riverpod
bool isOscilloscopePaused(Ref ref) {
  final state = ref.watch(oscilloscopeProvider);
  return state.whenOrNull(data: (s) => s.isPaused) ?? false;
}
