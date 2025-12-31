import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/script_service.dart';
import '../../domain/script_log.dart';

/// 脚本日志面板
class ScriptLogPanel extends ConsumerWidget {
  const ScriptLogPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scriptServiceProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // 工具栏
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.terminal, size: 16, color: colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                '脚本日志',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${state.logs.length}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              const Spacer(),
              // 清除日志按钮
              Tooltip(
                message: '清除日志',
                child: IconButton(
                  icon: const Icon(Icons.delete_sweep, size: 18),
                  onPressed: state.logs.isEmpty
                      ? null
                      : () {
                          ref.read(scriptServiceProvider.notifier).clearLogs();
                        },
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
        // 日志列表
        Expanded(
          child: state.logs.isEmpty
              ? _buildEmptyState(context)
              : _buildLogList(context, state.logs),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 32,
            color: colorScheme.outline.withAlpha(128),
          ),
          const SizedBox(height: 8),
          Text(
            '暂无日志',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildLogList(BuildContext context, List<ScriptLog> logs) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        // 从底部显示最新日志
        final log = logs[logs.length - 1 - index];
        return _LogItem(log: log);
      },
    );
  }
}

/// 单条日志项
class _LogItem extends StatelessWidget {
  const _LogItem({required this.log});

  final ScriptLog log;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeFormat = DateFormat('HH:mm:ss.SSS');

    Color getColor() {
      switch (log.type) {
        case ScriptLogType.info:
          return colorScheme.primary;
        case ScriptLogType.warning:
          return Colors.orange;
        case ScriptLogType.error:
          return colorScheme.error;
        case ScriptLogType.debug:
          return colorScheme.outline;
      }
    }

    IconData getIcon() {
      switch (log.type) {
        case ScriptLogType.info:
          return Icons.info_outline;
        case ScriptLogType.warning:
          return Icons.warning_amber;
        case ScriptLogType.error:
          return Icons.error_outline;
        case ScriptLogType.debug:
          return Icons.bug_report_outlined;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间戳
          Text(
            timeFormat.format(log.timestamp),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'Consolas, Monaco, monospace',
              color: colorScheme.outline,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 8),
          // 图标
          Icon(getIcon(), size: 14, color: getColor()),
          const SizedBox(width: 4),
          // 消息
          Expanded(
            child: Text(
              log.message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'Consolas, Monaco, monospace',
                color: getColor(),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
