import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/script_service.dart';
import '../../domain/script_entity.dart';
import 'script_editor_dialog.dart';

/// 脚本列表面板
class ScriptListPanel extends ConsumerWidget {
  const ScriptListPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scriptServiceProvider);

    return Column(
      children: [
        // 工具栏
        _buildToolbar(context, ref),
        const Divider(height: 1),
        // 脚本列表
        Expanded(
          child: state.scripts.isEmpty
              ? _buildEmptyState(context)
              : _buildScriptList(context, ref, state.scripts),
        ),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scriptServiceProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // 新建脚本按钮
          Tooltip(
            message: '新建脚本',
            child: IconButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: () => _showCreateDialog(context, ref),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const Spacer(),
          // 正在执行指示器
          if (state.isExecuting)
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
                    '运行中',
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
                Icons.code_off,
                size: 48,
                color: colorScheme.outline.withAlpha(128),
              ),
              const SizedBox(height: 12),
              Text(
                '暂无脚本',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
              ),
              const SizedBox(height: 8),
              Text(
                '点击 + 按钮创建新脚本',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline.withAlpha(180),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScriptList(
    BuildContext context,
    WidgetRef ref,
    List<ScriptEntity> scripts,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: scripts.length,
      itemBuilder: (context, index) {
        final script = scripts[index];
        return _ScriptListTile(
          script: script,
          onTap: () => _showEditDialog(context, ref, script),
          onRun: () => _runScript(ref, script),
          onDelete: () => _confirmDelete(context, ref, script),
          onToggleEnabled: (enabled) => _toggleEnabled(ref, script, enabled),
        );
      },
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ScriptEditorDialog(
        onSave: (script) async {
          await ref.read(scriptServiceProvider.notifier).saveScript(script);
        },
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    ScriptEntity script,
  ) {
    showDialog(
      context: context,
      builder: (context) => ScriptEditorDialog(
        script: script,
        onSave: (updatedScript) async {
          await ref
              .read(scriptServiceProvider.notifier)
              .saveScript(updatedScript);
        },
      ),
    );
  }

  Future<void> _runScript(WidgetRef ref, ScriptEntity script) async {
    await ref.read(scriptServiceProvider.notifier).executeScript(script.id);
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ScriptEntity script,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除脚本'),
        content: Text('确定要删除脚本「${script.name}」吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(scriptServiceProvider.notifier).deleteScript(script.id);
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
    ScriptEntity script,
    bool enabled,
  ) async {
    final updated = script.copyWith(isEnabled: enabled);
    await ref.read(scriptServiceProvider.notifier).saveScript(updated);
  }
}

/// 脚本列表项
class _ScriptListTile extends StatelessWidget {
  const _ScriptListTile({
    required this.script,
    required this.onTap,
    required this.onRun,
    required this.onDelete,
    required this.onToggleEnabled,
  });

  final ScriptEntity script;
  final VoidCallback onTap;
  final VoidCallback onRun;
  final VoidCallback onDelete;
  final void Function(bool enabled) onToggleEnabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                    value: script.isEnabled,
                    onChanged: onToggleEnabled,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 脚本信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      script.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: script.isEnabled
                            ? colorScheme.onSurface
                            : colorScheme.outline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (script.description != null &&
                        script.description!.isNotEmpty)
                      Text(
                        script.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // 运行按钮
              Tooltip(
                message: '运行脚本',
                child: IconButton(
                  icon: Icon(
                    Icons.play_arrow,
                    size: 20,
                    color: script.isEnabled
                        ? colorScheme.primary
                        : colorScheme.outline,
                  ),
                  onPressed: script.isEnabled ? onRun : null,
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
