import 'package:flutter/material.dart';

import '../../domain/match_reply_config.dart';
import '../../domain/sequential_reply_config.dart';

/// 顺序帧编辑对话框
class SequentialFrameEditDialog extends StatefulWidget {
  const SequentialFrameEditDialog({
    super.key,
    this.frame,
    required this.onSave,
  });

  /// 要编辑的帧（null 表示新建）
  final SequentialReplyFrame? frame;

  /// 保存回调
  final void Function(SequentialReplyFrame frame) onSave;

  @override
  State<SequentialFrameEditDialog> createState() =>
      _SequentialFrameEditDialogState();
}

class _SequentialFrameEditDialogState extends State<SequentialFrameEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dataController;
  late DataMode _dataMode;

  bool get _isEditing => widget.frame != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.frame?.name ?? '');
    _dataController = TextEditingController(text: widget.frame?.data ?? '');
    _dataMode = widget.frame?.mode ?? DataMode.hex;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? '编辑帧' : '添加帧'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 帧名称
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '帧名称',
                  hintText: '例如: 握手响应',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入帧名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 数据模式
              Text('帧数据', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildModeChip('HEX', DataMode.hex),
                  const SizedBox(width: 8),
                  _buildModeChip('ASCII', DataMode.ascii),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dataController,
                decoration: InputDecoration(
                  hintText: _dataMode == DataMode.hex
                      ? 'AA BB CC DD'
                      : 'Hello World',
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                maxLines: 3,
                style: const TextStyle(fontFamily: 'monospace'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入帧数据';
                  }
                  return null;
                },
              ),
            ],
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

  Widget _buildModeChip(String label, DataMode mode) {
    final isSelected = mode == _dataMode;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _dataMode = mode),
      visualDensity: VisualDensity.compact,
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final frame = SequentialReplyFrame(
      id: widget.frame?.id ?? _generateId(),
      name: _nameController.text.trim(),
      data: _dataController.text.trim(),
      mode: _dataMode,
    );

    widget.onSave(frame);
    Navigator.of(context).pop();
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
