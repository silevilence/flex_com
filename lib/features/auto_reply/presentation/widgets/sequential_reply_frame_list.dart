import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/auto_reply_providers.dart';
import '../../domain/sequential_reply_config.dart';
import 'sequential_frame_edit_dialog.dart';

/// 顺序回复帧列表组件
class SequentialReplyFrameList extends ConsumerWidget {
  const SequentialReplyFrameList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(sequentialReplyConfigProvider);

    return configAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('加载失败: $error')),
      data: (config) => _buildContent(context, ref, config),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    SequentialReplyConfig config,
  ) {
    return Column(
      children: [
        // 控制栏
        _buildControlBar(context, ref, config),
        const Divider(height: 1),
        // 帧列表
        Expanded(
          child: config.frames.isEmpty
              ? _buildEmptyState(context, ref)
              : _buildFrameList(context, ref, config),
        ),
      ],
    );
  }

  Widget _buildControlBar(
    BuildContext context,
    WidgetRef ref,
    SequentialReplyConfig config,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // 当前进度指示
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              config.frames.isEmpty
                  ? '0 / 0'
                  : '${config.currentIndex + 1} / ${config.frames.length}',
              style: theme.textTheme.labelMedium?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 重置按钮
          Tooltip(
            message: '重置到第一帧',
            child: IconButton(
              icon: const Icon(Icons.first_page, size: 20),
              onPressed: config.frames.isEmpty
                  ? null
                  : () => ref
                        .read(sequentialReplyConfigProvider.notifier)
                        .resetToFirst(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ),
          // 循环开关
          Tooltip(
            message: config.loopEnabled ? '关闭循环' : '开启循环',
            child: IconButton(
              icon: Icon(
                config.loopEnabled ? Icons.repeat_on : Icons.repeat,
                size: 20,
                color: config.loopEnabled ? theme.colorScheme.primary : null,
              ),
              onPressed: () =>
                  ref.read(sequentialReplyConfigProvider.notifier).toggleLoop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ),
          const Spacer(),
          // 添加按钮
          FilledButton.tonalIcon(
            onPressed: () => _showAddDialog(context, ref),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('添加'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(0, 32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.playlist_add,
            size: 40,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            '暂无回复帧',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '添加帧后，收到数据将按顺序回复',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrameList(
    BuildContext context,
    WidgetRef ref,
    SequentialReplyConfig config,
  ) {
    return ReorderableListView.builder(
      itemCount: config.frames.length,
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        ref
            .read(sequentialReplyConfigProvider.notifier)
            .reorderFrames(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final frame = config.frames[index];
        final isCurrentFrame = index == config.currentIndex;
        return _SequentialFrameItem(
          key: ValueKey(frame.id),
          frame: frame,
          index: index,
          isCurrent: isCurrentFrame,
          onEdit: () => _showEditDialog(context, ref, frame),
          onDelete: () => _confirmDelete(context, ref, frame),
          onJumpTo: () => ref
              .read(sequentialReplyConfigProvider.notifier)
              .setCurrentIndex(index),
        );
      },
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => SequentialFrameEditDialog(
        onSave: (frame) {
          ref.read(sequentialReplyConfigProvider.notifier).addFrame(frame);
        },
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    SequentialReplyFrame frame,
  ) {
    showDialog(
      context: context,
      builder: (context) => SequentialFrameEditDialog(
        frame: frame,
        onSave: (updatedFrame) {
          ref
              .read(sequentialReplyConfigProvider.notifier)
              .updateFrame(updatedFrame);
        },
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SequentialReplyFrame frame,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除帧'),
        content: Text('确定要删除帧 "${frame.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(sequentialReplyConfigProvider.notifier)
                  .deleteFrame(frame.id);
              Navigator.of(context).pop();
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

/// 单个顺序帧项
class _SequentialFrameItem extends StatelessWidget {
  const _SequentialFrameItem({
    super.key,
    required this.frame,
    required this.index,
    required this.isCurrent,
    required this.onEdit,
    required this.onDelete,
    required this.onJumpTo,
  });

  final SequentialReplyFrame frame;
  final int index;
  final bool isCurrent;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onJumpTo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: isCurrent
          ? colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      child: InkWell(
        onTap: onEdit,
        onDoubleTap: onJumpTo,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              // 拖拽手柄
              ReorderableDragStartListener(
                index: index,
                child: Icon(
                  Icons.drag_handle,
                  color: colorScheme.outline,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              // 序号/当前指示
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCurrent
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: isCurrent
                    ? Icon(
                        Icons.play_arrow,
                        size: 16,
                        color: colorScheme.onPrimary,
                      )
                    : Text(
                        '${index + 1}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              // 帧信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      frame.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _buildModeBadge(
                          context,
                          frame.mode.displayName,
                          colorScheme.secondaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _truncateData(frame.data),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                              fontFamily: 'monospace',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 跳转按钮
              Tooltip(
                message: '从此帧开始',
                child: IconButton(
                  icon: const Icon(Icons.play_circle_outline, size: 20),
                  onPressed: isCurrent ? null : onJumpTo,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ),
              // 删除按钮
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: onDelete,
                tooltip: '删除',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeBadge(BuildContext context, String text, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10),
      ),
    );
  }

  String _truncateData(String data) {
    if (data.length > 20) {
      return '${data.substring(0, 20)}...';
    }
    return data;
  }
}
