import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../connection/application/connection_providers.dart';
import '../../frame_parser/application/parser_providers.dart';
import '../application/visualization_providers.dart';
import '../domain/chart_types.dart';
import '../domain/oscilloscope_state.dart';
import 'channel_config_dialog.dart';

/// 示波器面板
class OscilloscopePanel extends ConsumerStatefulWidget {
  const OscilloscopePanel({super.key});

  @override
  ConsumerState<OscilloscopePanel> createState() => _OscilloscopePanelState();
}

class _OscilloscopePanelState extends ConsumerState<OscilloscopePanel> {
  // 用于截图的 key
  final _chartKey = GlobalKey();

  // 缩放和平移状态
  double _scaleX = 1.0;
  double _scaleY = 1.0;
  double _offsetX = 0.0;

  // 游标状态
  bool _showCursor = false;

  // 导出状态
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final oscilloscopeState = ref.watch(oscilloscopeProvider);
    final connectionState = ref.watch(unifiedConnectionProvider);
    final parserState = ref.watch(parserProvider);

    return oscilloscopeState.when(
      data: (state) =>
          _buildContent(state, theme, connectionState, parserState),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('加载失败: $error')),
    );
  }

  Widget _buildContent(
    OscilloscopeState state,
    ThemeData theme,
    UnifiedConnectionState connectionState,
    AsyncValue<dynamic> parserState,
  ) {
    // 检查前置条件
    final prerequisiteIssue = _checkPrerequisites(
      connectionState,
      parserState,
      state,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildToolbar(state, theme, prerequisiteIssue),
        const Divider(height: 1),
        // 显示前置条件警告
        if (prerequisiteIssue != null)
          _buildPrerequisiteWarning(prerequisiteIssue, theme),
        Expanded(
          child: state.config.channels.isEmpty
              ? _buildEmptyState(theme, parserState)
              : _buildChart(state, theme),
        ),
        // 使用 Flexible 防止底部元素溢出
        if (state.config.showLegend && state.config.channels.isNotEmpty)
          Flexible(flex: 0, child: _buildLegend(state, theme, parserState)),
        if (_showCursor && state.cursorInfo != null)
          Flexible(flex: 0, child: _buildCursorInfo(state.cursorInfo!, theme)),
      ],
    );
  }

  /// 检查前置条件，返回问题描述（null 表示无问题）
  _PrerequisiteIssue? _checkPrerequisites(
    UnifiedConnectionState connectionState,
    AsyncValue<dynamic> parserState,
    OscilloscopeState oscilloscopeState,
  ) {
    // 1. 检查连接状态
    if (!connectionState.isConnected) {
      return _PrerequisiteIssue(
        icon: Icons.cable_outlined,
        title: '未连接',
        message: '请先连接串口或网络',
        severity: _IssueSeverity.error,
      );
    }

    // 2. 检查解析器状态
    final parser = parserState.maybeWhen(
      data: (data) => data,
      orElse: () => null,
    );
    if (parser == null) {
      return _PrerequisiteIssue(
        icon: Icons.hourglass_empty,
        title: '加载中',
        message: '正在加载解析器配置...',
        severity: _IssueSeverity.info,
      );
    }

    if (!parser.isEnabled) {
      return _PrerequisiteIssue(
        icon: Icons.code_off,
        title: '协议解析未启用',
        message: '请在「协议解析」面板中启用解析功能',
        severity: _IssueSeverity.warning,
      );
    }

    if (parser.activeConfig == null) {
      return _PrerequisiteIssue(
        icon: Icons.playlist_remove,
        title: '未选择协议',
        message: '请在「协议解析」面板中选择要使用的协议配置',
        severity: _IssueSeverity.warning,
      );
    }

    // 3. 检查通道与当前协议是否匹配
    final activeConfigId = parser.activeConfigId;
    final mismatchedChannels = oscilloscopeState.config.channels.where((ch) {
      final parts = ch.fieldId.split(':');
      if (parts.length != 2) return true;
      return parts[0] != activeConfigId;
    }).toList();

    if (mismatchedChannels.isNotEmpty) {
      final names = mismatchedChannels.map((c) => c.name).join('、');
      return _PrerequisiteIssue(
        icon: Icons.warning_amber,
        title: '通道配置不匹配',
        message: '通道「$names」使用的协议与当前激活的协议不同，将无法显示数据',
        severity: _IssueSeverity.warning,
      );
    }

    return null;
  }

  /// 构建前置条件警告栏
  Widget _buildPrerequisiteWarning(_PrerequisiteIssue issue, ThemeData theme) {
    final Color bgColor;
    final Color fgColor;

    switch (issue.severity) {
      case _IssueSeverity.error:
        bgColor = theme.colorScheme.errorContainer;
        fgColor = theme.colorScheme.onErrorContainer;
      case _IssueSeverity.warning:
        bgColor = Colors.orange.shade100;
        fgColor = Colors.orange.shade900;
      case _IssueSeverity.info:
        bgColor = theme.colorScheme.surfaceContainerHighest;
        fgColor = theme.colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: bgColor,
      child: Row(
        children: [
          Icon(issue.icon, size: 18, color: fgColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: fgColor,
                  ),
                ),
                Text(
                  issue.message,
                  style: theme.textTheme.bodySmall?.copyWith(color: fgColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(
    OscilloscopeState state,
    ThemeData theme,
    _PrerequisiteIssue? prerequisiteIssue,
  ) {
    // 如果有严重问题，禁用开始按钮
    final canStart =
        prerequisiteIssue == null ||
        prerequisiteIssue.severity != _IssueSeverity.error;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.show_chart, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            '示波器',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),

          // 运行/停止按钮
          _buildIconButton(
            icon: state.isRunning ? Icons.stop : Icons.play_arrow,
            color: canStart
                ? (state.isRunning ? Colors.red : Colors.green)
                : theme.disabledColor,
            tooltip: state.isRunning ? '停止' : (canStart ? '开始' : '请先完成前置配置'),
            onPressed: canStart
                ? () {
                    if (state.isRunning) {
                      ref.read(oscilloscopeProvider.notifier).stop();
                    } else {
                      ref.read(oscilloscopeProvider.notifier).start();
                    }
                  }
                : null,
          ),

          // 暂停按钮
          if (state.isRunning)
            _buildIconButton(
              icon: state.isPaused ? Icons.play_arrow : Icons.pause,
              tooltip: state.isPaused ? '继续' : '暂停',
              onPressed: () {
                ref.read(oscilloscopeProvider.notifier).togglePause();
              },
            ),

          // 清空按钮
          _buildIconButton(
            icon: Icons.delete_outline,
            tooltip: '清空数据',
            onPressed: () {
              ref.read(oscilloscopeProvider.notifier).clearData();
            },
          ),

          const VerticalDivider(width: 16),

          // 游标开关
          _buildIconButton(
            icon: Icons.gps_fixed,
            tooltip: '游标测量',
            isActive: _showCursor,
            onPressed: () {
              setState(() {
                _showCursor = !_showCursor;
                if (!_showCursor) {
                  ref.read(oscilloscopeProvider.notifier).setCursor(null);
                }
              });
            },
          ),

          // 自动缩放
          _buildIconButton(
            icon: Icons.fit_screen,
            tooltip: '自动缩放',
            isActive: state.config.autoScaleY,
            onPressed: () {
              ref
                  .read(oscilloscopeProvider.notifier)
                  .setYRange(autoScale: !state.config.autoScaleY);
            },
          ),

          // 重置视图（拖动后显示明显的重置按钮）
          if (_scaleX != 1.0 || _scaleY != 1.0 || _offsetX != 0.0)
            FilledButton.tonalIcon(
              onPressed: _resetView,
              icon: const Icon(Icons.zoom_out_map, size: 16),
              label: const Text('重置'),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            )
          else
            _buildIconButton(
              icon: Icons.zoom_out_map,
              tooltip: '重置视图',
              onPressed: _resetView,
            ),

          const Spacer(),

          // 时间窗口选择
          _buildTimeWindowSelector(state, theme),

          const SizedBox(width: 8),

          // 添加通道按钮
          _buildIconButton(
            icon: Icons.add,
            tooltip: '添加通道',
            onPressed: () => _showAddChannelDialog(context),
          ),

          // 导出按钮
          PopupMenuButton<String>(
            icon: _isExporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_alt, size: 20),
            tooltip: '导出',
            enabled: !_isExporting && state.config.channels.isNotEmpty,
            onSelected: (value) => _handleExport(value, state),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'image',
                child: ListTile(
                  leading: Icon(Icons.image),
                  title: Text('导出为图片'),
                  subtitle: Text('PNG 格式'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'csv',
                child: ListTile(
                  leading: Icon(Icons.table_chart),
                  title: Text('导出数据'),
                  subtitle: Text('CSV 格式'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),

          // 设置按钮
          _buildIconButton(
            icon: Icons.settings,
            tooltip: '设置',
            onPressed: () => _showSettingsDialog(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    VoidCallback? onPressed,
    Color? color,
    bool isActive = false,
  }) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      color: color ?? (isActive ? Theme.of(context).colorScheme.primary : null),
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }

  /// 处理导出操作
  Future<void> _handleExport(String type, OscilloscopeState state) async {
    switch (type) {
      case 'image':
        await _exportAsImage();
        break;
      case 'csv':
        await _exportAsCsv(state);
        break;
    }
  }

  /// 导出为图片
  Future<void> _exportAsImage() async {
    setState(() => _isExporting = true);

    try {
      // 获取 RenderRepaintBoundary
      final boundary =
          _chartKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        _showSnackBar('无法获取图表内容', isError: true);
        return;
      }

      // 捕获图像（2x 分辨率以获得更好的质量）
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        _showSnackBar('图像转换失败', isError: true);
        return;
      }

      // 选择保存路径
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final result = await FilePicker.platform.saveFile(
        dialogTitle: '保存图表图片',
        fileName: 'oscilloscope_$timestamp.png',
        type: FileType.custom,
        allowedExtensions: ['png'],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsBytes(byteData.buffer.asUint8List());
        _showSnackBar('图片已保存到: ${file.path}');
      }
    } catch (e) {
      _showSnackBar('导出失败: $e', isError: true);
    } finally {
      setState(() => _isExporting = false);
    }
  }

  /// 导出为 CSV
  Future<void> _exportAsCsv(OscilloscopeState state) async {
    setState(() => _isExporting = true);

    try {
      // 收集所有时间点
      final allTimestamps = <int>{};
      for (final entry in state.channelData.entries) {
        for (final point in entry.value) {
          allTimestamps.add(point.timestamp);
        }
      }
      final sortedTimestamps = allTimestamps.toList()..sort();

      if (sortedTimestamps.isEmpty) {
        _showSnackBar('没有数据可导出', isError: true);
        return;
      }

      // 构建 CSV 内容
      final channels = state.config.channels;
      final buffer = StringBuffer();

      // 写入表头
      buffer.write('时间');
      for (final channel in channels) {
        buffer.write(',${channel.name}');
      }
      buffer.writeln();

      // 为每个通道创建时间戳到值的映射
      final channelDataMap = <String, Map<int, double>>{};
      for (final channel in channels) {
        final dataMap = <int, double>{};
        final data = state.channelData[channel.id] ?? [];
        for (final point in data) {
          dataMap[point.timestamp] = point.value;
        }
        channelDataMap[channel.id] = dataMap;
      }

      // 写入数据行
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
      for (final timestamp in sortedTimestamps) {
        final time = DateTime.fromMillisecondsSinceEpoch(timestamp);
        buffer.write(dateFormat.format(time));
        for (final channel in channels) {
          final value = channelDataMap[channel.id]?[timestamp];
          buffer.write(',${value ?? ''}');
        }
        buffer.writeln();
      }

      // 选择保存路径
      final timestampStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final result = await FilePicker.platform.saveFile(
        dialogTitle: '保存数据文件',
        fileName: 'oscilloscope_data_$timestampStr.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsString(buffer.toString());
        _showSnackBar('数据已保存到: ${file.path}');
      }
    } catch (e) {
      _showSnackBar('导出失败: $e', isError: true);
    } finally {
      setState(() => _isExporting = false);
    }
  }

  /// 显示提示消息
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  Widget _buildTimeWindowSelector(OscilloscopeState state, ThemeData theme) {
    return DropdownButton<int>(
      value: state.config.timeWindowMs,
      isDense: true,
      underline: const SizedBox(),
      items: const [
        DropdownMenuItem(value: 5000, child: Text('5 秒')),
        DropdownMenuItem(value: 10000, child: Text('10 秒')),
        DropdownMenuItem(value: 30000, child: Text('30 秒')),
        DropdownMenuItem(value: 60000, child: Text('1 分钟')),
        DropdownMenuItem(value: 300000, child: Text('5 分钟')),
      ],
      onChanged: (value) {
        if (value != null) {
          ref.read(oscilloscopeProvider.notifier).setTimeWindow(value);
        }
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme, AsyncValue<dynamic> parserState) {
    final parser = parserState.maybeWhen(
      data: (data) => data,
      orElse: () => null,
    );
    final hasParser =
        parser != null && parser.isEnabled && parser.activeConfig != null;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无数据通道',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasParser ? '点击下方按钮添加数据通道' : '请先在「协议解析」面板配置并启用协议',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withAlpha(180),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: hasParser ? () => _showAddChannelDialog(context) : null,
            icon: const Icon(Icons.add),
            label: const Text('添加通道'),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(OscilloscopeState state, ThemeData theme) {
    final yRange = state.calculateYRange();
    final now = DateTime.now().millisecondsSinceEpoch;
    final minX = (now - state.config.timeWindowMs) / 1000.0;
    final maxX = now / 1000.0;

    return RepaintBoundary(
      key: _chartKey,
      child: GestureDetector(
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        onTapDown: _showCursor
            ? (details) => _onTapForCursor(details, state)
            : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
          child: LineChart(
            LineChartData(
              minX: minX - _offsetX,
              maxX: maxX - _offsetX,
              minY: yRange.min / _scaleY,
              maxY: yRange.max / _scaleY,
              clipData: const FlClipData.all(),
              gridData: FlGridData(
                show: state.config.gridEnabled,
                drawVerticalLine: true,
                drawHorizontalLine: true,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: theme.colorScheme.outlineVariant.withAlpha(80),
                  strokeWidth: 1,
                ),
                getDrawingVerticalLine: (value) => FlLine(
                  color: theme.colorScheme.outlineVariant.withAlpha(80),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        _formatYValue(value),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: _calculateXInterval(state.config.timeWindowMs),
                    getTitlesWidget: (value, meta) {
                      // 跳过边界值避免重叠
                      if (meta.min == value || meta.max == value) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _formatTimeValueShort(value),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: theme.colorScheme.outline.withAlpha(100),
                ),
              ),
              lineBarsData: _buildLineBarsData(state),
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) =>
                      theme.colorScheme.surfaceContainerHighest.withAlpha(240),
                  tooltipPadding: const EdgeInsets.all(8),
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final channel = state.config.channels[spot.barIndex];
                      final time = DateTime.fromMillisecondsSinceEpoch(
                        (spot.x * 1000).toInt(),
                      );
                      final timeStr =
                          '${time.hour.toString().padLeft(2, '0')}:'
                          '${time.minute.toString().padLeft(2, '0')}:'
                          '${time.second.toString().padLeft(2, '0')}';
                      return LineTooltipItem(
                        '${channel.name}\n${spot.y.toStringAsFixed(2)}\n$timeStr',
                        TextStyle(
                          color: channel.color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
                handleBuiltInTouches: true,
                touchSpotThreshold: 20,
              ),
            ),
            duration: state.isPaused
                ? Duration.zero
                : const Duration(milliseconds: 0),
          ),
        ),
      ),
    );
  }

  List<LineChartBarData> _buildLineBarsData(OscilloscopeState state) {
    final lines = <LineChartBarData>[];

    for (final channel in state.config.channels) {
      if (!channel.isVisible) continue;

      final data = state.channelData[channel.id] ?? [];
      final spots = data.map((point) {
        return FlSpot(point.timestamp / 1000.0, point.value);
      }).toList();

      lines.add(
        LineChartBarData(
          spots: spots,
          isCurved: false,
          color: channel.color,
          barWidth: channel.lineWidth,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
      );
    }

    return lines;
  }

  Widget _buildLegend(
    OscilloscopeState state,
    ThemeData theme,
    AsyncValue<dynamic> parserState,
  ) {
    final parser = parserState.maybeWhen(
      data: (data) => data,
      orElse: () => null,
    );
    final activeConfigId = parser?.activeConfigId;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: state.config.channels.map((channel) {
          // 检查通道是否属于当前激活的协议
          final channelConfigId = channel.fieldId.split(':').firstOrNull;
          final isMismatch =
              activeConfigId != null && channelConfigId != activeConfigId;

          return Chip(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.only(left: 4),
            avatar: Container(
              width: 12,
              height: 3,
              decoration: BoxDecoration(
                color: channel.isVisible
                    ? channel.color
                    : channel.color.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMismatch)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Tooltip(
                      message: '通道协议与当前激活协议不一致，无法接收数据',
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 14,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                Text(
                  channel.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isMismatch
                        ? theme.colorScheme.error
                        : channel.isVisible
                        ? null
                        : theme.colorScheme.onSurfaceVariant.withAlpha(128),
                    decoration: channel.isVisible
                        ? null
                        : TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () => _confirmDeleteChannel(channel),
            backgroundColor: isMismatch
                ? theme.colorScheme.errorContainer.withAlpha(100)
                : channel.isVisible
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.surfaceContainerLow,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCursorInfo(CursorInfo info, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            _formatTimestamp(info.timestamp),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Wrap(
              spacing: 16,
              children: info.channelValues.entries.map((entry) {
                return Text(
                  '${entry.key}: ${entry.value.toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    // 记录起始状态
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      // 水平缩放
      if (details.horizontalScale != 1.0) {
        _scaleX = (_scaleX * details.horizontalScale).clamp(0.1, 10.0);
      }
      // 垂直缩放
      if (details.verticalScale != 1.0) {
        _scaleY = (_scaleY * details.verticalScale).clamp(0.1, 10.0);
      }
      // 水平平移
      _offsetX += details.focalPointDelta.dx * 0.01 / _scaleX;
    });
  }

  void _onTapForCursor(TapDownDetails details, OscilloscopeState state) {
    // 简单实现：记录点击位置并计算对应的数据值
    // 实际实现需要根据图表坐标系转换
    final channelValues = <String, double>{};

    for (final channel in state.config.channels) {
      if (!channel.isVisible) continue;
      final data = state.channelData[channel.id];
      if (data != null && data.isNotEmpty) {
        channelValues[channel.name] = data.last.value;
      }
    }

    ref
        .read(oscilloscopeProvider.notifier)
        .setCursor(
          CursorInfo(
            x: details.localPosition.dx,
            y: details.localPosition.dy,
            timestamp: DateTime.now().millisecondsSinceEpoch,
            channelValues: channelValues,
          ),
        );
  }

  void _showAddChannelDialog(BuildContext context) async {
    final result = await ChannelConfigDialog.show(context, ref);
    if (result != null) {
      for (final channel in result) {
        await ref.read(oscilloscopeProvider.notifier).addChannel(channel);
      }
    }
  }

  void _showSettingsDialog(
    BuildContext context,
    OscilloscopeState state,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => _SettingsDialog(config: state.config),
    );
  }

  void _confirmDeleteChannel(ChartChannel channel) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除通道'),
        content: Text('确定要删除通道 "${channel.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(oscilloscopeProvider.notifier).removeChannel(channel.id);
    }
  }

  String _formatYValue(double value) {
    if (value.abs() >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    if (value.abs() < 0.01 && value != 0) {
      return value.toStringAsExponential(1);
    }
    return value.toStringAsFixed(1);
  }

  /// 格式化时间值（短格式，只显示时:分:秒）
  String _formatTimeValueShort(double seconds) {
    final dt = DateTime.fromMillisecondsSinceEpoch((seconds * 1000).toInt());
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }

  /// 根据时间窗口计算 X 轴标签间隔
  double _calculateXInterval(int timeWindowMs) {
    // 根据时间窗口返回合适的间隔（秒）
    if (timeWindowMs <= 5000) return 1.0; // 5秒窗口，每1秒一个标签
    if (timeWindowMs <= 10000) return 2.0; // 10秒窗口，每2秒一个标签
    if (timeWindowMs <= 30000) return 5.0; // 30秒窗口，每5秒一个标签
    if (timeWindowMs <= 60000) return 10.0; // 1分钟窗口，每10秒一个标签
    return 30.0; // 5分钟窗口，每30秒一个标签
  }

  /// 重置视图
  void _resetView() {
    setState(() {
      _scaleX = 1.0;
      _scaleY = 1.0;
      _offsetX = 0.0;
    });
  }

  String _formatTimestamp(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}.'
        '${dt.millisecond.toString().padLeft(3, '0')}';
  }
}

/// 设置对话框
class _SettingsDialog extends ConsumerStatefulWidget {
  const _SettingsDialog({required this.config});

  final OscilloscopeConfig config;

  @override
  ConsumerState<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<_SettingsDialog> {
  late OscilloscopeConfig _config;
  late TextEditingController _minYController;
  late TextEditingController _maxYController;
  late TextEditingController _maxPointsController;

  @override
  void initState() {
    super.initState();
    _config = widget.config;
    _minYController = TextEditingController(text: _config.minY.toString());
    _maxYController = TextEditingController(text: _config.maxY.toString());
    _maxPointsController = TextEditingController(
      text: _config.maxDataPoints.toString(),
    );
  }

  @override
  void dispose() {
    _minYController.dispose();
    _maxYController.dispose();
    _maxPointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('示波器设置'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('自动缩放 Y 轴'),
              value: _config.autoScaleY,
              onChanged: (value) {
                setState(() {
                  _config = _config.copyWith(autoScaleY: value);
                });
              },
            ),
            if (!_config.autoScaleY) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minYController,
                      decoration: const InputDecoration(
                        labelText: 'Y 轴最小值',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _maxYController,
                      decoration: const InputDecoration(
                        labelText: 'Y 轴最大值',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            SwitchListTile(
              title: const Text('显示网格'),
              value: _config.gridEnabled,
              onChanged: (value) {
                setState(() {
                  _config = _config.copyWith(gridEnabled: value);
                });
              },
            ),
            SwitchListTile(
              title: const Text('显示图例'),
              value: _config.showLegend,
              onChanged: (value) {
                setState(() {
                  _config = _config.copyWith(showLegend: value);
                });
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _maxPointsController,
              decoration: const InputDecoration(
                labelText: '最大数据点数',
                border: OutlineInputBorder(),
                isDense: true,
                helperText: '超过后自动丢弃旧数据',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _save, child: const Text('保存')),
      ],
    );
  }

  void _save() {
    final minY = double.tryParse(_minYController.text) ?? _config.minY;
    final maxY = double.tryParse(_maxYController.text) ?? _config.maxY;
    final maxPoints =
        int.tryParse(_maxPointsController.text) ?? _config.maxDataPoints;

    final newConfig = _config.copyWith(
      minY: minY,
      maxY: maxY,
      maxDataPoints: maxPoints,
    );

    ref.read(oscilloscopeProvider.notifier).updateConfig(newConfig);
    Navigator.pop(context);
  }
}

/// 前置条件问题的严重性
enum _IssueSeverity {
  error, // 阻塞，无法运行
  warning, // 警告，可以运行但可能无数据
  info, // 提示信息
}

/// 前置条件问题描述
class _PrerequisiteIssue {
  final IconData icon;
  final String title;
  final String message;
  final _IssueSeverity severity;

  const _PrerequisiteIssue({
    required this.icon,
    required this.title,
    required this.message,
    required this.severity,
  });
}
