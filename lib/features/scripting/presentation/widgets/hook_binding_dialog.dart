import 'package:flutter/material.dart';

import '../../domain/script_entity.dart';
import '../../domain/script_hook.dart';

/// Hook 绑定创建/编辑对话框
class HookBindingDialog extends StatefulWidget {
  const HookBindingDialog({
    super.key,
    this.binding,
    required this.scripts,
    required this.onSave,
  });

  /// 编辑时传入现有绑定，新建时为 null
  final ScriptHookBinding? binding;

  /// 可选的脚本列表
  final List<ScriptEntity> scripts;

  /// 保存回调
  final Future<void> Function(
    String scriptId,
    HookType hookType,
    String? description,
    int priority,
  )
  onSave;

  @override
  State<HookBindingDialog> createState() => _HookBindingDialogState();
}

class _HookBindingDialogState extends State<HookBindingDialog> {
  late String? _selectedScriptId;
  late HookType _selectedHookType;
  late TextEditingController _descriptionController;
  late TextEditingController _priorityController;
  bool _isSaving = false;

  bool get isEditing => widget.binding != null;

  @override
  void initState() {
    super.initState();
    _selectedScriptId =
        widget.binding?.scriptId ?? widget.scripts.firstOrNull?.id;
    _selectedHookType = widget.binding?.hookType ?? HookType.taskHook;
    _descriptionController = TextEditingController(
      text: widget.binding?.description ?? '',
    );
    _priorityController = TextEditingController(
      text: (widget.binding?.priority ?? 100).toString(),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(isEditing ? '编辑 Hook 绑定' : '创建 Hook 绑定'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 脚本选择
              _buildSectionTitle(context, '选择脚本'),
              const SizedBox(height: 8),
              _buildScriptDropdown(context),
              const SizedBox(height: 16),

              // Hook 类型选择
              _buildSectionTitle(context, 'Hook 类型'),
              const SizedBox(height: 8),
              _buildHookTypeSelector(context),
              const SizedBox(height: 16),

              // 描述
              _buildSectionTitle(context, '描述（可选）'),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: '输入绑定描述...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // 优先级
              _buildSectionTitle(context, '优先级'),
              const SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _priorityController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '数值越小优先级越高',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Hook 类型说明
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withAlpha(100),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedHookType.displayName,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedHookType.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _isSaving || _selectedScriptId == null ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? '保存' : '创建'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildScriptDropdown(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.scripts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withAlpha(50),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.error.withAlpha(100)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, size: 16, color: colorScheme.error),
            const SizedBox(width: 8),
            Text(
              '请先创建脚本',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colorScheme.error),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      // ignore: deprecated_member_use
      value: _selectedScriptId,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
      ),
      isExpanded: true,
      items: widget.scripts.map((script) {
        return DropdownMenuItem(
          value: script.id,
          child: Text(
            script.name + (script.isEnabled ? '' : ' (已禁用)'),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: script.isEnabled ? null : colorScheme.outline,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedScriptId = value;
        });
      },
    );
  }

  Widget _buildHookTypeSelector(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: HookType.values.map((type) {
        final isSelected = _selectedHookType == type;
        return _HookTypeChip(
          hookType: type,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              _selectedHookType = type;
            });
          },
        );
      }).toList(),
    );
  }

  Future<void> _save() async {
    if (_selectedScriptId == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final priority = int.tryParse(_priorityController.text) ?? 100;
      final description = _descriptionController.text.trim();

      await widget.onSave(
        _selectedScriptId!,
        _selectedHookType,
        description.isEmpty ? null : description,
        priority,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

/// Hook 类型选择芯片
class _HookTypeChip extends StatelessWidget {
  const _HookTypeChip({
    required this.hookType,
    required this.isSelected,
    required this.onTap,
  });

  final HookType hookType;
  final bool isSelected;
  final VoidCallback onTap;

  IconData get _icon {
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected ? colorScheme.primaryContainer : colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _icon,
                size: 16,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                hookType.displayName,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
