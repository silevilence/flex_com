import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/hook_service.dart';
import '../../application/script_service.dart';
import '../../domain/script_hook.dart';
import 'hook_binding_dialog.dart';

/// Hook 管理面板
///
/// 用于管理脚本与 Hook 点的绑定关系
class HookManagementPanel extends ConsumerWidget {
  const HookManagementPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hookState = ref.watch(hookServiceProvider);

    return Column(
      children: [
        // 工具栏
        _buildToolbar(context, ref, hookState),
        const Divider(height: 1),
        // Hook 绑定列表
        Expanded(
          child: hookState.bindings.isEmpty
              ? _buildEmptyState(context)
              : _buildHookList(context, ref, hookState),
        ),
      ],
    );
  }

  Widget _buildToolbar(
    BuildContext context,
    WidgetRef ref,
    HookServiceState state,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // 新建绑定按钮
          Tooltip(
            message: '新建 Hook 绑定',
            child: IconButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: () => _showCreateDialog(context, ref),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 4),
          // 刷新按钮
          Tooltip(
            message: '刷新',
            child: IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: () =>
                  ref.read(hookServiceProvider.notifier).refreshBindings(),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const Spacer(),
          // 处理中指示器
          if (state.isProcessing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '处理中',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.webhook_outlined,
                size: 48,
                color: colorScheme.outline.withAlpha(128),
              ),
              const SizedBox(height: 12),
              Text(
                '暂无 Hook 绑定',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
              ),
              const SizedBox(height: 8),
              Text(
                '点击 + 将脚本绑定到 Hook 点',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline.withAlpha(180),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // 快速说明
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withAlpha(100),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHookTypeInfo(
                      context,
                      Icons.arrow_downward,
                      'Rx 预处理',
                      '接收数据解密/解封装',
                    ),
                    const SizedBox(height: 8),
                    _buildHookTypeInfo(
                      context,
                      Icons.arrow_upward,
                      'Tx 后处理',
                      '发送数据加密/封包',
                    ),
                    const SizedBox(height: 8),
                    _buildHookTypeInfo(
                      context,
                      Icons.reply,
                      '脚本回复',
                      '复杂条件自动应答',
                    ),
                    const SizedBox(height: 8),
                    _buildHookTypeInfo(
                      context,
                      Icons.play_arrow,
                      '手动任务',
                      '一键执行发包序列',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHookTypeInfo(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: colorScheme.outline),
          ),
        ),
      ],
    );
  }

  Widget _buildHookList(
    BuildContext context,
    WidgetRef ref,
    HookServiceState state,
  ) {
    // 按 Hook 类型分组
    final groupedBindings = <HookType, List<ScriptHookBinding>>{};
    for (final hookType in HookType.values) {
      final bindings = state.getBindingsByType(hookType);
      if (bindings.isNotEmpty) {
        groupedBindings[hookType] = bindings;
      }
    }

    if (groupedBindings.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: groupedBindings.length,
      itemBuilder: (context, index) {
        final hookType = groupedBindings.keys.elementAt(index);
        final bindings = groupedBindings[hookType]!;
        return _HookTypeSection(
          hookType: hookType,
          bindings: bindings,
          activeBinding: _getActiveBinding(state, hookType),
          onEdit: (binding) => _showEditDialog(context, ref, binding),
          onDelete: (binding) => _confirmDelete(context, ref, binding),
          onToggleEnabled: (binding, enabled) =>
              _toggleEnabled(ref, binding, enabled),
        );
      },
    );
  }

  ScriptHookBinding? _getActiveBinding(HookServiceState state, HookType type) {
    switch (type) {
      case HookType.rxPreProcessor:
        return state.activeRxHook;
      case HookType.txPostProcessor:
        return state.activeTxHook;
      case HookType.replyHook:
        return state.activeReplyHook;
      case HookType.taskHook:
        return null; // Task Hook 不需要激活状态
    }
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final scripts = ref.read(scriptServiceProvider).scripts;
    if (scripts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先创建脚本'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => HookBindingDialog(
        scripts: scripts,
        onSave: (scriptId, hookType, description, priority) async {
          await ref
              .read(hookServiceProvider.notifier)
              .createBinding(
                scriptId: scriptId,
                hookType: hookType,
                description: description,
                priority: priority,
              );
        },
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    ScriptHookBinding binding,
  ) {
    final scripts = ref.read(scriptServiceProvider).scripts;

    showDialog(
      context: context,
      builder: (context) => HookBindingDialog(
        binding: binding,
        scripts: scripts,
        onSave: (scriptId, hookType, description, priority) async {
          final updated = binding.copyWith(
            scriptId: scriptId,
            hookType: hookType,
            description: description,
            priority: priority,
          );
          await ref.read(hookServiceProvider.notifier).updateBinding(updated);
        },
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ScriptHookBinding binding,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除 Hook 绑定'),
        content: Text('确定要删除此 ${binding.hookType.displayName} 绑定吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(hookServiceProvider.notifier).deleteBinding(binding.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleEnabled(
    WidgetRef ref,
    ScriptHookBinding binding,
    bool enabled,
  ) async {
    await ref
        .read(hookServiceProvider.notifier)
        .setBindingEnabled(binding.id, enabled);
  }
}

/// Hook 类型分组区块
class _HookTypeSection extends ConsumerWidget {
  const _HookTypeSection({
    required this.hookType,
    required this.bindings,
    required this.activeBinding,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleEnabled,
  });

  final HookType hookType;
  final List<ScriptHookBinding> bindings;
  final ScriptHookBinding? activeBinding;
  final void Function(ScriptHookBinding) onEdit;
  final void Function(ScriptHookBinding) onDelete;
  final void Function(ScriptHookBinding, bool) onToggleEnabled;

  IconData get _hookTypeIcon {
    switch (hookType) {
      case HookType.rxPreProcessor:
        return Icons.arrow_downward;
      case HookType.txPostProcessor:
        return Icons.arrow_upward;
      case HookType.replyHook:
        return Icons.reply;
      case HookType.taskHook:
        return Icons.play_arrow;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 类型标题
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            children: [
              Icon(_hookTypeIcon, size: 16, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                hookType.displayName,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              if (activeBinding != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '激活',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        // 绑定列表
        ...bindings.map(
          (binding) => _HookBindingTile(
            binding: binding,
            isActive: activeBinding?.id == binding.id,
            onTap: () => onEdit(binding),
            onDelete: () => onDelete(binding),
            onToggleEnabled: (enabled) => onToggleEnabled(binding, enabled),
            onRunTask: hookType == HookType.taskHook
                ? () => _runTask(ref, binding)
                : null,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Future<void> _runTask(WidgetRef ref, ScriptHookBinding binding) async {
    await ref.read(hookServiceProvider.notifier).executeTaskHook(binding.id);
  }
}

/// Hook 绑定列表项
class _HookBindingTile extends ConsumerWidget {
  const _HookBindingTile({
    required this.binding,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
    required this.onToggleEnabled,
    this.onRunTask,
  });

  final ScriptHookBinding binding;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final void Function(bool enabled) onToggleEnabled;
  final VoidCallback? onRunTask;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final scripts = ref.watch(scriptServiceProvider).scripts;
    final script = scripts.where((s) => s.id == binding.scriptId).firstOrNull;
    final scriptName = script?.name ?? '未知脚本';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      color: isActive ? colorScheme.primaryContainer.withAlpha(50) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // 启用开关
              SizedBox(
                width: 36,
                height: 24,
                child: Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    value: binding.enabled,
                    onChanged: onToggleEnabled,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 激活指示器
              if (isActive)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              // 绑定信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.code, size: 14, color: colorScheme.outline),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            scriptName,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: binding.enabled
                                      ? colorScheme.onSurface
                                      : colorScheme.outline,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (binding.description != null &&
                        binding.description!.isNotEmpty)
                      Text(
                        binding.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    // 优先级显示
                    Text(
                      '优先级: ${binding.priority}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.outline.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),
              // 运行按钮（仅 Task Hook）
              if (onRunTask != null)
                Tooltip(
                  message: '运行任务',
                  child: IconButton(
                    icon: Icon(
                      Icons.play_arrow,
                      size: 20,
                      color: binding.enabled
                          ? colorScheme.primary
                          : colorScheme.outline,
                    ),
                    onPressed: binding.enabled ? onRunTask : null,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              // 删除按钮
              Tooltip(
                message: '删除',
                child: IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: colorScheme.error,
                  ),
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
