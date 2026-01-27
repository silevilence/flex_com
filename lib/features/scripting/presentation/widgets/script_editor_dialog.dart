import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/lua.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';
import 'package:re_highlight/styles/atom-one-light.dart';

import '../../domain/script_entity.dart';
import '../fcom_code_completer.dart';

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
  late final CodeLineEditingController _codeController;
  late final CodeScrollController _scrollController;
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
    _codeController = CodeLineEditingController.fromText(
      widget.script?.content ?? _defaultScriptContent,
    );
    _scrollController = CodeScrollController();
    _isEnabled = widget.script?.isEnabled ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _codeController.dispose();
    _scrollController.dispose();
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
                      clipBehavior: Clip.antiAlias,
                      child: _buildCodeEditor(context),
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
        content: _codeController.text,
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

  /// 构建代码编辑器
  Widget _buildCodeEditor(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return CodeAutocomplete(
      viewBuilder: buildAutocompleteView,
      promptsBuilder: FComCodePromptsBuilder(),
      child: CodeEditor(
        controller: _codeController,
        scrollController: _scrollController,
        style: CodeEditorStyle(
          fontSize: 13,
          fontFamily: 'Consolas, Monaco, Courier New, monospace',
          fontHeight: 1.5,
          backgroundColor: colorScheme.surfaceContainerLowest,
          textColor: colorScheme.onSurface,
          cursorColor: colorScheme.primary,
          selectionColor: colorScheme.primary.withAlpha(76),
          codeTheme: CodeHighlightTheme(
            languages: {'lua': CodeHighlightThemeMode(mode: langLua)},
            theme: isDarkMode ? atomOneDarkTheme : atomOneLightTheme,
          ),
        ),
        indicatorBuilder:
            (context, editingController, chunkController, notifier) {
              return DefaultCodeLineNumber(
                controller: editingController,
                notifier: notifier,
                textStyle: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  fontFamily: 'Consolas, Monaco, Courier New, monospace',
                ),
              );
            },
        sperator: Container(width: 1, color: colorScheme.outlineVariant),
        wordWrap: false,
      ),
    );
  }

  void _showApiHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [Icon(Icons.api), SizedBox(width: 8), Text('FCom API 参考')],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // === 基础通信 API ===
                const _ApiSectionHeader(title: '基础通信'),
                const _ApiHelpItem(
                  name: 'FCom.send(data)',
                  signature: 'send(data: string|table) → void',
                  description: '发送数据到串口，支持 Hex 字符串或字节数组',
                  example: 'FCom.send("48656C6C6F") -- 发送 "Hello"',
                ),
                const _ApiHelpItem(
                  name: 'FCom.log(message, level?)',
                  signature: 'log(message: string, level?: string) → void',
                  description: '输出日志到控制台，level 可选: info, warning, error, debug',
                  example: 'FCom.log("测试消息", "info")',
                ),
                const _ApiHelpItem(
                  name: 'FCom.delay(ms)',
                  signature: 'delay(ms: number) → void',
                  description: '延迟指定毫秒（仅做标记，不阻塞脚本执行）',
                  example: 'FCom.delay(1000) -- 标记延迟 1 秒',
                ),

                // === 校验计算 API ===
                const _ApiSectionHeader(title: '校验计算'),
                const _ApiHelpItem(
                  name: 'FCom.crc16(data)',
                  signature: 'crc16(data: string) → string',
                  description: '计算 CRC16-Modbus 校验值，返回 Hex 字符串',
                  example: 'local crc = FCom.crc16("010300")',
                ),
                const _ApiHelpItem(
                  name: 'FCom.crc32(data)',
                  signature: 'crc32(data: string) → string',
                  description: '计算 CRC32 校验值，返回 Hex 字符串',
                  example: 'local crc = FCom.crc32("010300")',
                ),
                const _ApiHelpItem(
                  name: 'FCom.checksum(data)',
                  signature: 'checksum(data: string) → string',
                  description: '计算 8 位累加和校验值，返回 Hex 字符串',
                  example: 'local sum = FCom.checksum("010300")',
                ),

                // === 工具函数 ===
                const _ApiSectionHeader(title: '工具函数'),
                const _ApiHelpItem(
                  name: 'FCom.getTimestamp()',
                  signature: 'getTimestamp() → number',
                  description: '获取当前 Unix 时间戳（毫秒）',
                  example: 'local ts = FCom.getTimestamp()',
                ),
                const _ApiHelpItem(
                  name: 'FCom.hexToBytes(hex)',
                  signature: 'hexToBytes(hex: string) → table',
                  description: 'Hex 字符串转字节数组（Lua table），索引从 1 开始',
                  example:
                      'local bytes = FCom.hexToBytes("48656C6C6F")\n-- bytes = {72, 101, 108, 108, 111}',
                ),
                const _ApiHelpItem(
                  name: 'FCom.bytesToHex(bytes)',
                  signature: 'bytesToHex(bytes: table) → string',
                  description: '字节数组转 Hex 字符串（大写，无空格）',
                  example:
                      'local hex = FCom.bytesToHex({72, 101, 108})\n-- hex = "48656C"',
                ),

                // === 输入数据 ===
                const _ApiSectionHeader(title: '输入数据 (Hook 脚本可用)'),
                const _ApiHelpItem(
                  name: 'FCom.input',
                  signature: 'input: { raw, hex, length, isRx }',
                  description:
                      '当前输入数据对象，包含以下字段：\n'
                      '• raw: table - 原始字节数组，索引从 1 开始\n'
                      '• hex: string - 十六进制字符串（大写，无空格）\n'
                      '• length: number - 数据长度（字节数）\n'
                      '• isRx: boolean - 是否为接收数据',
                  example:
                      'local hex = FCom.input.hex\nlocal len = FCom.input.length',
                ),
                const _ApiHelpItem(
                  name: 'FCom.getData()',
                  signature: 'getData() → table',
                  description: '获取输入数据，等同于 FCom.input',
                  example: 'local data = FCom.getData()',
                ),

                // === Hook 专用 API ===
                const _ApiSectionHeader(title: 'Hook 专用 API'),
                const _ApiHelpItem(
                  name: 'FCom.setResponse(data)',
                  signature: 'setResponse(data: string|table) → void',
                  description: '[Reply Hook] 设置自动回复的响应数据',
                  example: '-- 收到数据后自动回复\nFCom.setResponse("OK")',
                ),
                const _ApiHelpItem(
                  name: 'FCom.setProcessedData(data)',
                  signature: 'setProcessedData(data: string|table) → void',
                  description: '[Pipeline Hook] 设置处理后的数据，用于修改显示/转发的内容',
                  example:
                      '-- 给数据添加时间戳前缀\nlocal newData = timestamp .. FCom.input.hex\nFCom.setProcessedData(newData)',
                ),
                const _ApiHelpItem(
                  name: 'FCom.skipReply()',
                  signature: 'skipReply() → void',
                  description: '[Reply Hook] 跳过本次自动回复，不发送任何响应',
                  example:
                      '-- 条件判断是否回复\nif FCom.input.length < 5 then\n  FCom.skipReply()\nend',
                ),
              ],
            ),
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

/// API 分类标题
class _ApiSectionHeader extends StatelessWidget {
  const _ApiSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
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
    this.signature,
    required this.description,
    required this.example,
  });

  final String name;
  final String? signature;
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
          if (signature != null) ...[
            const SizedBox(height: 4),
            Text(
              signature!,
              style: TextStyle(
                fontFamily: 'Consolas, Monaco, monospace',
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
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
