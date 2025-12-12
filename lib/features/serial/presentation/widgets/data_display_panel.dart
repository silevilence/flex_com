import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/data_log_service.dart';
import '../../application/display_settings_providers.dart';
import '../../application/serial_data_providers.dart';
import '../../domain/serial_data_entry.dart';

/// Widget that displays received and sent serial data.
///
/// Supports switching between Hex and ASCII display modes.
class DataDisplayPanel extends ConsumerStatefulWidget {
  const DataDisplayPanel({super.key});

  @override
  ConsumerState<DataDisplayPanel> createState() => _DataDisplayPanelState();
}

class _DataDisplayPanelState extends ConsumerState<DataDisplayPanel> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;
  final DataLogService _logService = DataLogService();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_autoScroll && _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _saveLog({required bool asBinary}) async {
    final entries = ref.read(serialDataLogProvider);
    if (entries.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('没有数据可保存')));
      }
      return;
    }

    final displayMode = ref.read(dataDisplayModeProvider);
    final defaultFileName = _logService.generateFileName(isBinary: asBinary);

    final result = await FilePicker.platform.saveFile(
      dialogTitle: asBinary ? '保存二进制日志' : '保存文本日志',
      fileName: defaultFileName,
      type: FileType.custom,
      allowedExtensions: asBinary ? ['bin'] : ['txt', 'log'],
    );

    if (result == null) return;

    try {
      if (asBinary) {
        await _logService.saveAsBinary(entries, result);
      } else {
        await _logService.saveAsText(
          entries,
          result,
          asHex: displayMode == DataDisplayMode.hex,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('日志已保存: ${File(result).uri.pathSegments.last}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失败: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(serialDataLogProvider);
    final displayMode = ref.watch(dataDisplayModeProvider);

    // Scroll to bottom when new data arrives
    ref.listen(serialDataLogProvider, (previous, next) {
      if (next.length > (previous?.length ?? 0)) {
        _scrollToBottom();
      }
    });

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with controls
          _buildHeader(context, displayMode, entries.length),
          const Divider(height: 1),
          // Data display area
          Expanded(
            child: entries.isEmpty
                ? _buildEmptyState(context)
                : _buildDataList(context, entries, displayMode),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    DataDisplayMode displayMode,
    int entryCount,
  ) {
    final displaySettings = ref.watch(displaySettingsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Text('接收区', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(width: 8),
          Text(
            '($entryCount 条)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          // Display mode toggle
          SegmentedButton<DataDisplayMode>(
            segments: const [
              ButtonSegment(value: DataDisplayMode.hex, label: Text('HEX')),
              ButtonSegment(value: DataDisplayMode.ascii, label: Text('ASCII')),
            ],
            selected: {displayMode},
            onSelectionChanged: (selected) {
              ref
                  .read(dataDisplayModeProvider.notifier)
                  .setMode(selected.first);
            },
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),
          const SizedBox(width: 8),
          // Timestamp toggle
          IconButton(
            onPressed: () {
              ref.read(displaySettingsProvider.notifier).toggleTimestamp();
            },
            icon: Icon(
              displaySettings.showTimestamp
                  ? Icons.access_time_filled
                  : Icons.access_time,
            ),
            tooltip: displaySettings.showTimestamp ? '时间戳已开启' : '时间戳已关闭',
            style: IconButton.styleFrom(
              backgroundColor: displaySettings.showTimestamp
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
            ),
          ),
          // Auto wrap toggle
          IconButton(
            onPressed: () {
              ref.read(displaySettingsProvider.notifier).toggleAutoWrap();
            },
            icon: Icon(
              displaySettings.autoWrap ? Icons.wrap_text : Icons.notes,
            ),
            tooltip: displaySettings.autoWrap ? '自动换行已开启' : '自动换行已关闭',
            style: IconButton.styleFrom(
              backgroundColor: displaySettings.autoWrap
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
            ),
          ),
          // Auto scroll toggle
          IconButton(
            onPressed: () {
              setState(() {
                _autoScroll = !_autoScroll;
              });
              if (_autoScroll) {
                _scrollToBottom();
              }
            },
            icon: Icon(_autoScroll ? Icons.vertical_align_bottom : Icons.pause),
            tooltip: _autoScroll ? '自动滚动已开启' : '自动滚动已暂停',
            style: IconButton.styleFrom(
              backgroundColor: _autoScroll
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
            ),
          ),
          // Save log button with menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.save_alt),
            tooltip: '保存日志',
            onSelected: (value) {
              switch (value) {
                case 'txt':
                  _saveLog(asBinary: false);
                case 'bin':
                  _saveLog(asBinary: true);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'txt',
                child: Row(
                  children: [
                    Icon(Icons.description_outlined),
                    SizedBox(width: 8),
                    Text('保存为文本 (.txt)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'bin',
                child: Row(
                  children: [
                    Icon(Icons.code),
                    SizedBox(width: 8),
                    Text('保存为二进制 (.bin)'),
                  ],
                ),
              ),
            ],
          ),
          // Clear button
          IconButton(
            onPressed: () {
              ref.read(serialDataLogProvider.notifier).clear();
            },
            icon: const Icon(Icons.delete_outline),
            tooltip: '清空接收区',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            '暂无数据',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '打开串口后，数据将显示在这里',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataList(
    BuildContext context,
    List<SerialDataEntry> entries,
    DataDisplayMode displayMode,
  ) {
    final displaySettings = ref.watch(displaySettingsProvider);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _DataEntryTile(
          entry: entry,
          displayMode: displayMode,
          showTimestamp: displaySettings.showTimestamp,
          autoWrap: displaySettings.autoWrap,
        );
      },
    );
  }
}

/// Widget that displays a single data entry.
class _DataEntryTile extends StatelessWidget {
  const _DataEntryTile({
    required this.entry,
    required this.displayMode,
    required this.showTimestamp,
    required this.autoWrap,
  });

  final SerialDataEntry entry;
  final DataDisplayMode displayMode;
  final bool showTimestamp;
  final bool autoWrap;

  static final _timeFormat = DateFormat('HH:mm:ss.SSS');

  @override
  Widget build(BuildContext context) {
    final isReceived = entry.direction == DataDirection.received;
    final directionIcon = isReceived
        ? Icons.arrow_downward
        : Icons.arrow_upward;
    final directionColor = isReceived
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.tertiary;

    final dataText = displayMode == DataDisplayMode.hex
        ? entry.toHexString()
        : entry.toTextString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Direction icon
          Icon(directionIcon, size: 16, color: directionColor),
          const SizedBox(width: 4),
          // Timestamp (conditional)
          if (showTimestamp) ...[
            Text(
              _timeFormat.format(entry.timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Direction label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: directionColor.withAlpha(30),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isReceived ? 'RX' : 'TX',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: directionColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Data
          Expanded(
            child: autoWrap
                ? SelectableText(
                    dataText,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SelectableText(
                      dataText,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
                    ),
                  ),
          ),
          // Byte count
          Text(
            '[${entry.data.length}]',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
