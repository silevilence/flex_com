import 'package:flutter/material.dart';

import '../../domain/match_reply_config.dart';

/// 匹配规则编辑对话框
class MatchRuleEditDialog extends StatefulWidget {
  const MatchRuleEditDialog({super.key, this.rule, required this.onSave});

  /// 要编辑的规则（null 表示新建）
  final MatchReplyRule? rule;

  /// 保存回调
  final void Function(MatchReplyRule rule) onSave;

  @override
  State<MatchRuleEditDialog> createState() => _MatchRuleEditDialogState();
}

class _MatchRuleEditDialogState extends State<MatchRuleEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _triggerController;
  late final TextEditingController _responseController;
  late DataMode _triggerMode;
  late DataMode _responseMode;
  late bool _enabled;

  bool get _isEditing => widget.rule != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.rule?.name ?? '');
    _triggerController = TextEditingController(
      text: widget.rule?.triggerPattern ?? '',
    );
    _responseController = TextEditingController(
      text: widget.rule?.responseData ?? '',
    );
    _triggerMode = widget.rule?.triggerMode ?? DataMode.hex;
    _responseMode = widget.rule?.responseMode ?? DataMode.hex;
    _enabled = widget.rule?.enabled ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _triggerController.dispose();
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? '编辑规则' : '添加规则'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 规则名称
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '规则名称',
                    hintText: '例如: 心跳响应',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入规则名称';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 触发模式
                Text(
                  '触发条件（包含匹配）',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildModeChip('HEX', DataMode.hex, _triggerMode, (mode) {
                      setState(() => _triggerMode = mode);
                    }),
                    const SizedBox(width: 8),
                    _buildModeChip('ASCII', DataMode.ascii, _triggerMode, (
                      mode,
                    ) {
                      setState(() => _triggerMode = mode);
                    }),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _triggerController,
                  decoration: InputDecoration(
                    hintText: _triggerMode == DataMode.hex
                        ? 'AA BB CC'
                        : 'HELLO',
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  maxLines: 2,
                  style: const TextStyle(fontFamily: 'monospace'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入触发数据';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 响应数据
                Text('响应数据', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildModeChip('HEX', DataMode.hex, _responseMode, (mode) {
                      setState(() => _responseMode = mode);
                    }),
                    const SizedBox(width: 8),
                    _buildModeChip('ASCII', DataMode.ascii, _responseMode, (
                      mode,
                    ) {
                      setState(() => _responseMode = mode);
                    }),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _responseController,
                  decoration: InputDecoration(
                    hintText: _responseMode == DataMode.hex
                        ? 'DD EE FF'
                        : 'WORLD',
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  maxLines: 2,
                  style: const TextStyle(fontFamily: 'monospace'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入响应数据';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 启用开关
                SwitchListTile(
                  title: const Text('启用此规则'),
                  value: _enabled,
                  onChanged: (value) => setState(() => _enabled = value),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _save, child: const Text('保存')),
      ],
    );
  }

  Widget _buildModeChip(
    String label,
    DataMode mode,
    DataMode currentMode,
    void Function(DataMode) onSelected,
  ) {
    final isSelected = mode == currentMode;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(mode),
      visualDensity: VisualDensity.compact,
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final rule = MatchReplyRule(
      id: widget.rule?.id ?? _generateId(),
      name: _nameController.text.trim(),
      triggerPattern: _triggerController.text.trim(),
      triggerMode: _triggerMode,
      responseData: _responseController.text.trim(),
      responseMode: _responseMode,
      enabled: _enabled,
    );

    widget.onSave(rule);
    Navigator.of(context).pop();
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
