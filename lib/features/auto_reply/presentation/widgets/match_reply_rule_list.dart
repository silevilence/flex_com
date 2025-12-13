import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/auto_reply_providers.dart';
import '../../domain/match_reply_config.dart';
import 'match_rule_edit_dialog.dart';

/// 匹配回复规则列表组件
class MatchReplyRuleList extends ConsumerWidget {
  const MatchReplyRuleList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(matchReplyConfigProvider);

    return configAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('加载失败: $error')),
      data: (config) => _buildRuleList(context, ref, config),
    );
  }

  Widget _buildRuleList(
    BuildContext context,
    WidgetRef ref,
    MatchReplyConfig config,
  ) {
    if (config.rules.isEmpty) {
      return _buildEmptyState(context, ref);
    }

    return Column(
      children: [
        // 添加规则按钮
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => _showAddDialog(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('添加规则'),
              ),
            ],
          ),
        ),
        // 规则列表
        Expanded(
          child: ReorderableListView.builder(
            itemCount: config.rules.length,
            buildDefaultDragHandles: false,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex--;
              ref
                  .read(matchReplyConfigProvider.notifier)
                  .reorderRules(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final rule = config.rules[index];
              return _MatchRuleItem(
                key: ValueKey(rule.id),
                rule: rule,
                index: index,
                onEdit: () => _showEditDialog(context, ref, rule),
                onDelete: () => _confirmDelete(context, ref, rule),
                onToggle: () => ref
                    .read(matchReplyConfigProvider.notifier)
                    .toggleRuleEnabled(rule.id),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.rule_outlined,
            size: 40,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            '暂无匹配规则',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: () => _showAddDialog(context, ref),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('添加规则'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => MatchRuleEditDialog(
        onSave: (rule) {
          ref.read(matchReplyConfigProvider.notifier).addRule(rule);
        },
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    MatchReplyRule rule,
  ) {
    showDialog(
      context: context,
      builder: (context) => MatchRuleEditDialog(
        rule: rule,
        onSave: (updatedRule) {
          ref.read(matchReplyConfigProvider.notifier).updateRule(updatedRule);
        },
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    MatchReplyRule rule,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除规则'),
        content: Text('确定要删除规则 "${rule.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(matchReplyConfigProvider.notifier).deleteRule(rule.id);
              Navigator.of(context).pop();
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

/// 单条匹配规则项
class _MatchRuleItem extends StatelessWidget {
  const _MatchRuleItem({
    super.key,
    required this.rule,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  final MatchReplyRule rule;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onEdit,
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
              // 启用开关
              SizedBox(
                width: 36,
                height: 24,
                child: Switch(
                  value: rule.enabled,
                  onChanged: (_) => onToggle(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              // 规则信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: rule.enabled ? null : colorScheme.outline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _buildModeBadge(
                          context,
                          rule.triggerMode.displayName,
                          colorScheme.primaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _truncateData(rule.triggerPattern),
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
              // 操作按钮
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
