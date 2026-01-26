import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/hex_utils.dart';
import '../domain/frame_config.dart';
import '../domain/parser_types.dart';

/// 帧解析器配置对话框
class FrameParserConfigDialog extends ConsumerStatefulWidget {
  const FrameParserConfigDialog({super.key, this.initialConfig});

  /// 初始配置（编辑模式）
  final FrameConfig? initialConfig;

  /// 打开配置对话框
  static Future<FrameConfig?> show(
    BuildContext context, {
    FrameConfig? initialConfig,
  }) {
    return showDialog<FrameConfig>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          FrameParserConfigDialog(initialConfig: initialConfig),
    );
  }

  @override
  ConsumerState<FrameParserConfigDialog> createState() =>
      _FrameParserConfigDialogState();
}

class _FrameParserConfigDialogState
    extends ConsumerState<FrameParserConfigDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _headerController;
  late TextEditingController _footerController;
  late TextEditingController _minLengthController;
  late TextEditingController _maxLengthController;
  late TextEditingController _checksumStartController;
  late TextEditingController _checksumEndController;

  late FrameConfig _config;

  @override
  void initState() {
    super.initState();
    _config =
        widget.initialConfig ??
        FrameConfig(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: '新协议配置',
        );

    _nameController = TextEditingController(text: _config.name);
    _descController = TextEditingController(text: _config.description);
    _headerController = TextEditingController(
      text: _config.header.isNotEmpty
          ? _config.header
                .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
                .join(' ')
          : '',
    );
    _footerController = TextEditingController(
      text: _config.footer.isNotEmpty
          ? _config.footer
                .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
                .join(' ')
          : '',
    );
    _minLengthController = TextEditingController(
      text: _config.minLength?.toString() ?? '',
    );
    _maxLengthController = TextEditingController(
      text: _config.maxLength?.toString() ?? '',
    );
    _checksumStartController = TextEditingController(
      text: _config.checksumStartByte.toString(),
    );
    _checksumEndController = TextEditingController(
      text: _config.checksumEndByte?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _headerController.dispose();
    _footerController.dispose();
    _minLengthController.dispose();
    _maxLengthController.dispose();
    _checksumStartController.dispose();
    _checksumEndController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTitleBar(theme),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildBasicSection(theme),
                      const SizedBox(height: 16),
                      _buildFrameSection(theme),
                      const SizedBox(height: 16),
                      _buildChecksumSection(theme),
                      const SizedBox(height: 16),
                      _buildFieldsSection(theme),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildActionButtons(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBar(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.settings_input_component_outlined,
          color: theme.colorScheme.primary,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.initialConfig == null ? '新建协议配置' : '编辑协议配置',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: '关闭',
        ),
      ],
    );
  }

  Widget _buildBasicSection(ThemeData theme) {
    return _buildSection(
      title: '基本信息',
      icon: Icons.info_outline,
      theme: theme,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '配置名称',
            hintText: '如: Modbus RTU、自定义协议等',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (value) {
            _config = _config.copyWith(name: value);
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descController,
          decoration: const InputDecoration(
            labelText: '描述（可选）',
            hintText: '协议用途、特点等',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          maxLines: 2,
          onChanged: (value) {
            _config = _config.copyWith(description: value);
          },
        ),
      ],
    );
  }

  Widget _buildFrameSection(ThemeData theme) {
    return _buildSection(
      title: '帧结构',
      icon: Icons.view_stream_outlined,
      theme: theme,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _headerController,
                decoration: const InputDecoration(
                  labelText: '帧头（Hex）',
                  hintText: '如: AA 55',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                inputFormatters: [_HexInputFormatter()],
                onChanged: (value) => _updateHeader(value),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _footerController,
                decoration: const InputDecoration(
                  labelText: '帧尾（Hex）',
                  hintText: '如: 0D 0A',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                inputFormatters: [_HexInputFormatter()],
                onChanged: (value) => _updateFooter(value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minLengthController,
                decoration: const InputDecoration(
                  labelText: '最小长度',
                  hintText: '字节',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  final len = int.tryParse(value);
                  _config = _config.copyWith(
                    minLength: len,
                    clearMinLength: len == null,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _maxLengthController,
                decoration: const InputDecoration(
                  labelText: '最大长度',
                  hintText: '字节',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  final len = int.tryParse(value);
                  _config = _config.copyWith(
                    maxLength: len,
                    clearMaxLength: len == null,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChecksumSection(ThemeData theme) {
    return _buildSection(
      title: '校验配置',
      icon: Icons.verified_outlined,
      theme: theme,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<ChecksumType>(
                initialValue: _config.checksumType,
                decoration: const InputDecoration(
                  labelText: '校验类型',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: ChecksumType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _config = _config.copyWith(checksumType: value);
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<Endianness>(
                initialValue: _config.checksumEndianness,
                decoration: const InputDecoration(
                  labelText: '校验字节序',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: Endianness.values.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e == Endianness.big ? '大端' : '小端'),
                  );
                }).toList(),
                onChanged: _config.checksumType != ChecksumType.none
                    ? (value) {
                        if (value != null) {
                          setState(() {
                            _config = _config.copyWith(
                              checksumEndianness: value,
                            );
                          });
                        }
                      }
                    : null,
              ),
            ),
          ],
        ),
        if (_config.checksumType != ChecksumType.none) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _checksumStartController,
                  decoration: const InputDecoration(
                    labelText: '校验起始字节',
                    hintText: '索引从0开始',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    final start = int.tryParse(value) ?? 0;
                    _config = _config.copyWith(checksumStartByte: start);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _checksumEndController,
                  decoration: const InputDecoration(
                    labelText: '校验结束字节',
                    hintText: '空=到校验位',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    final end = int.tryParse(value);
                    _config = _config.copyWith(
                      checksumEndByte: end,
                      clearChecksumEndByte: end == null,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFieldsSection(ThemeData theme) {
    return _buildSection(
      title: '字段定义',
      icon: Icons.table_rows_outlined,
      theme: theme,
      trailing: IconButton(
        icon: const Icon(Icons.add_circle_outline),
        onPressed: _addField,
        tooltip: '添加字段',
        color: theme.colorScheme.primary,
      ),
      children: [
        if (_config.fields.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.table_rows_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant.withAlpha(128),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '暂无字段定义',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '点击右上角"+"添加数据字段',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withAlpha(180),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _config.fields.length,
            onReorder: _reorderFields,
            itemBuilder: (context, index) {
              final field = _config.fields[index];
              return _buildFieldItem(field, index, theme);
            },
          ),
      ],
    );
  }

  Widget _buildFieldItem(FieldDefinition field, int index, ThemeData theme) {
    return Card(
      key: ValueKey(field.id),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        leading: ReorderableDragStartListener(
          index: index,
          child: const Icon(Icons.drag_handle),
        ),
        title: Text(
          field.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '字节 ${field.startByte}${field.byteLength > 1 ? '-${field.startByte + field.byteLength - 1}' : ''} '
          '| ${field.dataType.displayName} '
          '${field.isBitField ? '| 位域' : ''}'
          '${field.unit.isNotEmpty ? '| ${field.unit}' : ''}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _editField(index),
              tooltip: '编辑',
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                size: 20,
                color: theme.colorScheme.error,
              ),
              onPressed: () => _removeField(index),
              tooltip: '删除',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required ThemeData theme,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (trailing != null) ...[const Spacer(), trailing],
          ],
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: _importFromTemplate,
          icon: const Icon(Icons.file_download_outlined, size: 18),
          label: const Text('从模板导入'),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: _nameController.text.isNotEmpty ? _save : null,
          icon: const Icon(Icons.save_outlined, size: 18),
          label: const Text('保存'),
        ),
      ],
    );
  }

  void _updateHeader(String value) {
    try {
      final bytes = HexUtils.hexStringToBytes(value);
      _config = _config.copyWith(header: bytes.toList());
    } catch (_) {
      // 忽略无效输入
    }
  }

  void _updateFooter(String value) {
    try {
      final bytes = HexUtils.hexStringToBytes(value);
      _config = _config.copyWith(footer: bytes.toList());
    } catch (_) {
      // 忽略无效输入
    }
  }

  void _addField() async {
    final field = await FieldDefinitionDialog.show(context);
    if (field != null) {
      setState(() {
        _config = _config.copyWith(fields: [..._config.fields, field]);
      });
    }
  }

  void _editField(int index) async {
    final field = await FieldDefinitionDialog.show(
      context,
      initialField: _config.fields[index],
    );
    if (field != null) {
      setState(() {
        final newFields = [..._config.fields];
        newFields[index] = field;
        _config = _config.copyWith(fields: newFields);
      });
    }
  }

  void _removeField(int index) {
    setState(() {
      final newFields = [..._config.fields];
      newFields.removeAt(index);
      _config = _config.copyWith(fields: newFields);
    });
  }

  void _reorderFields(int oldIndex, int newIndex) {
    setState(() {
      final fields = [..._config.fields];
      if (newIndex > oldIndex) newIndex -= 1;
      final field = fields.removeAt(oldIndex);
      fields.insert(newIndex, field);
      _config = _config.copyWith(fields: fields);
    });
  }

  void _importFromTemplate() async {
    final template = await showDialog<FrameConfig>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('选择模板'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(
              context,
              FrameConfigTemplates.modbusRtu(id: _config.id),
            ),
            child: const ListTile(
              title: Text('Modbus RTU'),
              subtitle: Text('CRC16-MODBUS 校验'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(
              context,
              FrameConfigTemplates.simpleHeaderFooter(id: _config.id),
            ),
            child: const ListTile(
              title: Text('帧头帧尾协议'),
              subtitle: Text('AA 55 ... 0D 0A，Sum8 校验'),
            ),
          ),
        ],
      ),
    );

    if (template != null) {
      setState(() {
        _config = template.copyWith(
          name: _nameController.text.isNotEmpty
              ? _nameController.text
              : template.name,
        );
        _descController.text = _config.description;
        _headerController.text = _config.header.isNotEmpty
            ? _config.header
                  .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
                  .join(' ')
            : '';
        _footerController.text = _config.footer.isNotEmpty
            ? _config.footer
                  .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
                  .join(' ')
            : '';
        _checksumStartController.text = _config.checksumStartByte.toString();
        _checksumEndController.text = _config.checksumEndByte?.toString() ?? '';
      });
    }
  }

  void _save() {
    Navigator.of(context).pop(_config);
  }
}

/// 字段定义对话框
class FieldDefinitionDialog extends StatefulWidget {
  const FieldDefinitionDialog({super.key, this.initialField});

  final FieldDefinition? initialField;

  static Future<FieldDefinition?> show(
    BuildContext context, {
    FieldDefinition? initialField,
  }) {
    return showDialog<FieldDefinition>(
      context: context,
      builder: (context) => FieldDefinitionDialog(initialField: initialField),
    );
  }

  @override
  State<FieldDefinitionDialog> createState() => _FieldDefinitionDialogState();
}

class _FieldDefinitionDialogState extends State<FieldDefinitionDialog> {
  late TextEditingController _nameController;
  late TextEditingController _startByteController;
  late TextEditingController _lengthController;
  late TextEditingController _descController;
  late TextEditingController _unitController;
  late TextEditingController _scaleController;
  late TextEditingController _offsetController;
  late TextEditingController _bitMaskController;
  late TextEditingController _bitOffsetController;

  late FieldDefinition _field;
  bool _useBitField = false;

  @override
  void initState() {
    super.initState();
    _field =
        widget.initialField ??
        FieldDefinition(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: '',
          startByte: 0,
          dataType: DataType.uint8,
        );

    _useBitField = _field.isBitField;

    _nameController = TextEditingController(text: _field.name);
    _startByteController = TextEditingController(
      text: _field.startByte.toString(),
    );
    _lengthController = TextEditingController(text: _field.length.toString());
    _descController = TextEditingController(text: _field.description);
    _unitController = TextEditingController(text: _field.unit);
    _scaleController = TextEditingController(
      text: _field.scaleFactor != 1.0 ? _field.scaleFactor.toString() : '',
    );
    _offsetController = TextEditingController(
      text: _field.offset != 0.0 ? _field.offset.toString() : '',
    );
    _bitMaskController = TextEditingController(
      text: _field.bitMask != null
          ? '0x${_field.bitMask!.toRadixString(16).toUpperCase()}'
          : '',
    );
    _bitOffsetController = TextEditingController(
      text: _field.bitOffset?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startByteController.dispose();
    _lengthController.dispose();
    _descController.dispose();
    _unitController.dispose();
    _scaleController.dispose();
    _offsetController.dispose();
    _bitMaskController.dispose();
    _bitOffsetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final needsLength =
        _field.dataType == DataType.bytes || _field.dataType == DataType.ascii;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.initialField == null ? '添加字段' : '编辑字段',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 基本信息
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: '字段名称 *',
                          hintText: '如: 温度、状态码等',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          _field = _field.copyWith(name: value);
                        },
                      ),
                      const SizedBox(height: 12),

                      // 位置和类型
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _startByteController,
                              decoration: const InputDecoration(
                                labelText: '起始字节 *',
                                hintText: '从0开始',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) {
                                final start = int.tryParse(value) ?? 0;
                                _field = _field.copyWith(startByte: start);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<DataType>(
                              initialValue: _field.dataType,
                              decoration: const InputDecoration(
                                labelText: '数据类型',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: DataType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type.displayName),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _field = _field.copyWith(dataType: value);
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 长度和字节序
                      Row(
                        children: [
                          if (needsLength)
                            Expanded(
                              child: TextField(
                                controller: _lengthController,
                                decoration: const InputDecoration(
                                  labelText: '长度（字节）',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (value) {
                                  final len = int.tryParse(value) ?? 1;
                                  _field = _field.copyWith(length: len);
                                },
                              ),
                            ),
                          if (needsLength) const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<Endianness>(
                              initialValue: _field.endianness,
                              decoration: const InputDecoration(
                                labelText: '字节序',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: Endianness.values.map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(e.displayName),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  _field = _field.copyWith(endianness: value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 位域选项
                      SwitchListTile(
                        title: const Text('启用位域提取'),
                        subtitle: const Text('从字节中提取特定位'),
                        value: _useBitField,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          setState(() {
                            _useBitField = value;
                            if (!value) {
                              _field = _field.copyWith(
                                clearBitMask: true,
                                clearBitOffset: true,
                              );
                              _bitMaskController.clear();
                              _bitOffsetController.clear();
                            }
                          });
                        },
                      ),

                      if (_useBitField) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _bitMaskController,
                                decoration: const InputDecoration(
                                  labelText: '位掩码',
                                  hintText: '如: 0xF0',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                onChanged: (value) {
                                  final mask = _parseHexOrInt(value);
                                  if (mask != null) {
                                    _field = _field.copyWith(bitMask: mask);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _bitOffsetController,
                                decoration: const InputDecoration(
                                  labelText: '位偏移（右移）',
                                  hintText: '如: 4',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (value) {
                                  final offset = int.tryParse(value);
                                  _field = _field.copyWith(
                                    bitOffset: offset,
                                    clearBitOffset: offset == null,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],

                      // 数值转换
                      const Divider(),
                      Text('数值转换（可选）', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Text(
                        '实际值 = 原始值 × 比例因子 + 偏移量',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _scaleController,
                              decoration: const InputDecoration(
                                labelText: '比例因子',
                                hintText: '默认 1.0',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              onChanged: (value) {
                                final scale = double.tryParse(value) ?? 1.0;
                                _field = _field.copyWith(scaleFactor: scale);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _offsetController,
                              decoration: const InputDecoration(
                                labelText: '偏移量',
                                hintText: '默认 0',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                              onChanged: (value) {
                                final offset = double.tryParse(value) ?? 0.0;
                                _field = _field.copyWith(offset: offset);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _unitController,
                              decoration: const InputDecoration(
                                labelText: '单位',
                                hintText: '如: °C, V, mA',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (value) {
                                _field = _field.copyWith(unit: value);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 描述
                      TextField(
                        controller: _descController,
                        decoration: const InputDecoration(
                          labelText: '描述（可选）',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          _field = _field.copyWith(description: value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _nameController.text.isNotEmpty ? _save : null,
                    child: const Text('确定'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int? _parseHexOrInt(String value) {
    if (value.isEmpty) return null;
    if (value.startsWith('0x') || value.startsWith('0X')) {
      return int.tryParse(value.substring(2), radix: 16);
    }
    return int.tryParse(value);
  }

  void _save() {
    Navigator.of(context).pop(_field);
  }
}

/// Hex 输入格式化器
class _HexInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 只允许 0-9, A-F, a-f 和空格
    final filtered = newValue.text.replaceAll(RegExp(r'[^0-9A-Fa-f\s]'), '');
    return TextEditingValue(
      text: filtered.toUpperCase(),
      selection: TextSelection.collapsed(
        offset: filtered.length.clamp(0, newValue.selection.baseOffset),
      ),
    );
  }
}
