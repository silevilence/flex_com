import 'package:flutter/material.dart';

import '../../domain/script_entity.dart';

/// 脚本编辑对话框
class ScriptEditorDialog extends StatefulWidget {
  const ScriptEditorDialog({super.key, this.script, required this.onSave});

  /// 要编辑的脚本，如果为 null 则创建新脚本
  final ScriptEntity? script;

  /// 保存回调
  final Future<void> Function(ScriptEntity script) onSave;

  @override
  State<ScriptEditorDialog> createState() => _ScriptEditorDialogState();
}

class _ScriptEditorDialogState extends State<ScriptEditorDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _contentController;
  bool _isEnabled = true;
  bool _isSaving = false;

  bool get _isEditing => widget.script != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.script?.name ?? 'New Script',
    );
    _descriptionController = TextEditingController(
      text: widget.script?.description ?? '',
    );
    _contentController = TextEditingController(
      text: widget.script?.content ?? _defaultScriptContent,
    );
    _isEnabled = widget.script?.isEnabled ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  static const _defaultScriptContent = '''-- FlexCom Lua 脚本
-- 可用 API:
--   FCom.send("HEXDATA")  - 发送数据
--   FCom.log("message", "info")  - 记录日志
--   FCom.crc16("data")  - 计算 CRC16
--   FCom.crc32("data")  - 计算 CRC32
--   FCom.checksum("data")  - 计算校验和
--   FCom.getTimestamp()  - 获取时间戳

-- 示例：发送数据
-- FCom.send("010300000001840A")

FCom.log("脚本开始执行", "info")

-- 在这里编写你的脚本...

FCom.log("脚本执行完成", "info")
''';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      child: Container(
        width: 700,
        height: 550,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Row(
              children: [
                Icon(
                  _isEditing ? Icons.edit : Icons.add,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _isEditing ? '编辑脚本' : '新建脚本',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                // 启用开关
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('启用', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(width: 8),
                    Switch(
                      value: _isEnabled,
                      onChanged: (value) {
                        setState(() => _isEnabled = value);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 名称输入
            Row(
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '脚本名称',
                      hintText: '输入脚本名称',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '描述（可选）',
                      hintText: '输入脚本描述',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 代码编辑区
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Lua 脚本',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const Spacer(),
                      // API 帮助按钮
                      TextButton.icon(
                        icon: const Icon(Icons.help_outline, size: 16),
                        label: const Text('API 参考'),
                        onPressed: () => _showApiHelp(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.outline),
                        borderRadius: BorderRadius.circular(8),
                        color: colorScheme.surfaceContainerLowest,
                      ),
                      child: TextField(
                        controller: _contentController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: const TextStyle(
                          fontFamily: 'Consolas, Monaco, monospace',
                          fontSize: 13,
                          height: 1.5,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12),
                          hintText: '在这里输入 Lua 脚本...',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 按钮栏
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? '保存中...' : '保存'),
                  onPressed: _isSaving ? null : _save,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入脚本名称')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final script = ScriptEntity(
        id:
            widget.script?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        content: _contentController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        createdAt: widget.script?.createdAt ?? now,
        updatedAt: now,
        isEnabled: _isEnabled,
      );

      await widget.onSave(script);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失败: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showApiHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [Icon(Icons.api), SizedBox(width: 8), Text('FCom API 参考')],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _ApiHelpItem(
                name: 'FCom.send(data)',
                description: '发送数据到串口',
                example: 'FCom.send("48656C6C6F") -- 发送 "Hello"',
              ),
              _ApiHelpItem(
                name: 'FCom.log(message, level)',
                description: '记录日志，level 可选: info, warning, error, debug',
                example: 'FCom.log("测试消息", "info")',
              ),
              _ApiHelpItem(
                name: 'FCom.delay(ms)',
                description: '延迟执行（毫秒）',
                example: 'FCom.delay(1000) -- 延迟 1 秒',
              ),
              _ApiHelpItem(
                name: 'FCom.crc16(data)',
                description: '计算 CRC16-Modbus 校验值',
                example: 'local crc = FCom.crc16("010300")',
              ),
              _ApiHelpItem(
                name: 'FCom.crc32(data)',
                description: '计算 CRC32 校验值',
                example: 'local crc = FCom.crc32("010300")',
              ),
              _ApiHelpItem(
                name: 'FCom.checksum(data)',
                description: '计算 8 位校验和',
                example: 'local sum = FCom.checksum("010300")',
              ),
              _ApiHelpItem(
                name: 'FCom.getTimestamp()',
                description: '获取当前时间戳（毫秒）',
                example: 'local ts = FCom.getTimestamp()',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

/// API 帮助项
class _ApiHelpItem extends StatelessWidget {
  const _ApiHelpItem({
    required this.name,
    required this.description,
    required this.example,
  });

  final String name;
  final String description;
  final String example;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              name,
              style: TextStyle(
                fontFamily: 'Consolas, Monaco, monospace',
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(description),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              example,
              style: TextStyle(
                fontFamily: 'Consolas, Monaco, monospace',
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
