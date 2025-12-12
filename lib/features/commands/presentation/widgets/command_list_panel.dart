import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/command_providers.dart';
import '../../domain/command.dart';
import 'command_edit_dialog.dart';

/// 指令列表面板
///
/// 显示用户预设的指令列表，支持添加、编辑、删除和发送指令。
class CommandListPanel extends ConsumerWidget {
  const CommandListPanel({super.key, this.onSendCommand});

  /// 发送指令的回调
  final void Function(Command command)? onSendCommand;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commandState = ref.watch(commandListProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          // 标题栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Text('指令列表', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                // 添加按钮
                SizedBox(
                  height: 32,
                  width: 32,
                  child: IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    tooltip: '添加指令',
                    padding: EdgeInsets.zero,
                    onPressed: () => _showAddDialog(context, ref),
                  ),
                ),
                // 刷新按钮
                SizedBox(
                  height: 32,
                  width: 32,
                  child: IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    tooltip: '刷新',
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      ref.read(commandListProvider.notifier).refresh();
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 指令列表
          Expanded(
            child: commandState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : commandState.commands.isEmpty
                ? _buildEmptyState(context)
                : _buildCommandList(context, ref, commandState),
          ),
          // 错误提示
          if (commandState.error != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Theme.of(context).colorScheme.errorContainer,
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      commandState.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        ref.read(commandListProvider.notifier).clearError();
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.list_alt_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无预设指令',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右上角 + 添加',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandList(
    BuildContext context,
    WidgetRef ref,
    CommandListState state,
  ) {
    return ReorderableListView.builder(
      itemCount: state.commands.length,
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) {
        ref
            .read(commandListProvider.notifier)
            .reorderCommands(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final command = state.commands[index];
        final isSelected = state.selectedCommandId == command.id;

        return _CommandListTile(
          key: ValueKey(command.id),
          command: command,
          index: index,
          isSelected: isSelected,
          onTap: () {
            ref.read(commandListProvider.notifier).selectCommand(command.id);
          },
          onDoubleTap: () => onSendCommand?.call(command),
          onEdit: () => _showEditDialog(context, ref, command),
          onDelete: () => _confirmDelete(context, ref, command),
          onSend: () => onSendCommand?.call(command),
        );
      },
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Command>(
      context: context,
      builder: (context) => const CommandEditDialog(),
    );

    if (result != null) {
      await ref
          .read(commandListProvider.notifier)
          .addCommand(
            name: result.name,
            data: result.data,
            mode: result.mode,
            description: result.description,
          );
    }
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    Command command,
  ) async {
    final result = await showDialog<Command>(
      context: context,
      builder: (context) => CommandEditDialog(command: command),
    );

    if (result != null) {
      await ref.read(commandListProvider.notifier).updateCommand(result);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Command command,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除指令'),
        content: Text('确定要删除指令 "${command.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(commandListProvider.notifier).deleteCommand(command.id);
    }
  }
}

/// 指令列表项
class _CommandListTile extends StatelessWidget {
  const _CommandListTile({
    super.key,
    required this.command,
    required this.index,
    required this.isSelected,
    required this.onTap,
    required this.onDoubleTap,
    required this.onEdit,
    required this.onDelete,
    required this.onSend,
  });

  final Command command;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer.withAlpha(128)
          : null,
      child: InkWell(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              // 拖拽手柄
              ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_handle, size: 20),
              ),
              const SizedBox(width: 8),
              // 模式指示器
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  command.mode.name.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              const SizedBox(width: 8),
              // 指令信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      command.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      command.data,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // 操作按钮
              IconButton(
                icon: const Icon(Icons.send, size: 18),
                tooltip: '发送',
                onPressed: onSend,
                visualDensity: VisualDensity.compact,
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18),
                tooltip: '更多',
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('编辑')),
                  const PopupMenuItem(value: 'delete', child: Text('删除')),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
