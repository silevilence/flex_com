import 'package:flutter/material.dart';

import '../../../serial/domain/serial_data_entry.dart';
import '../../domain/command.dart';

/// 指令编辑对话框
///
/// 用于添加或编辑预设指令，支持设置名称、数据、模式和描述。
class CommandEditDialog extends StatefulWidget {
  const CommandEditDialog({super.key, this.command});

  /// 要编辑的指令，为 null 时表示新建
  final Command? command;

  @override
  State<CommandEditDialog> createState() => _CommandEditDialogState();
}

class _CommandEditDialogState extends State<CommandEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dataController;
  late final TextEditingController _descriptionController;
  late DataDisplayMode _mode;

  bool get isEditing => widget.command != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.command?.name ?? '');
    _dataController = TextEditingController(text: widget.command?.data ?? '');
    _descriptionController = TextEditingController(
      text: widget.command?.description ?? '',
    );
    _mode = widget.command?.mode ?? DataDisplayMode.hex;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dataController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final command = widget.command != null
        ? widget.command!.copyWith(
            name: _nameController.text.trim(),
            data: _dataController.text.trim(),
            mode: _mode,
            description: _descriptionController.text.trim(),
          )
        : Command.create(
            name: _nameController.text.trim(),
            data: _dataController.text.trim(),
            mode: _mode,
            description: _descriptionController.text.trim(),
          );

    Navigator.of(context).pop(command);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? '编辑指令' : '添加指令'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 名称
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '名称 *',
                  hintText: '为指令起个名字',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入名称';
                  }
                  return null;
                },
                autofocus: true,
              ),
              const SizedBox(height: 16),

              // 数据模式
              Row(
                children: [
                  const Text('模式: '),
                  const SizedBox(width: 8),
                  SegmentedButton<DataDisplayMode>(
                    segments: const [
                      ButtonSegment(
                        value: DataDisplayMode.hex,
                        label: Text('HEX'),
                      ),
                      ButtonSegment(
                        value: DataDisplayMode.ascii,
                        label: Text('ASCII'),
                      ),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (selected) {
                      setState(() {
                        _mode = selected.first;
                      });
                    },
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 数据内容
              TextFormField(
                controller: _dataController,
                decoration: InputDecoration(
                  labelText: '数据 *',
                  hintText: _mode == DataDisplayMode.hex
                      ? '输入十六进制数据 (如: 48 65 6C 6C 6F)'
                      : '输入文本数据',
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
                style: const TextStyle(fontFamily: 'monospace'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入数据';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 描述
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述 (可选)',
                  hintText: '添加备注信息',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
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
        FilledButton(onPressed: _submit, child: Text(isEditing ? '保存' : '添加')),
      ],
    );
  }
}
