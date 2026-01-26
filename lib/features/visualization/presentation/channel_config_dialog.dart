import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/visualization_providers.dart';
import '../domain/chart_types.dart';
import '../domain/oscilloscope_state.dart';

/// 通道配置对话框
class ChannelConfigDialog extends ConsumerStatefulWidget {
  const ChannelConfigDialog._({this.existingChannel});

  final ChartChannel? existingChannel;

  /// 显示添加通道对话框
  static Future<List<ChartChannel>?> show(
    BuildContext context,
    WidgetRef ref,
  ) async {
    return showDialog<List<ChartChannel>>(
      context: context,
      builder: (context) => const ChannelConfigDialog._(),
    );
  }

  /// 显示编辑通道对话框
  static Future<ChartChannel?> showEdit(
    BuildContext context,
    WidgetRef ref,
    ChartChannel channel,
  ) async {
    final result = await showDialog<List<ChartChannel>>(
      context: context,
      builder: (context) => ChannelConfigDialog._(existingChannel: channel),
    );
    return result?.firstOrNull;
  }

  @override
  ConsumerState<ChannelConfigDialog> createState() =>
      _ChannelConfigDialogState();
}

class _ChannelConfigDialogState extends ConsumerState<ChannelConfigDialog> {
  late TextEditingController _nameController;
  late Color _selectedColor;
  late double _lineWidth;
  late Set<String> _selectedFieldIds;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingChannel;

    _nameController = TextEditingController(text: existing?.name ?? '');
    _selectedColor = existing?.color ?? ChannelColors.colors[0];
    _lineWidth = existing?.lineWidth ?? 1.5;
    _selectedFieldIds = existing?.fieldId != null ? {existing!.fieldId} : {};
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingChannel != null;
    final selectorState = ref.watch(channelSelectorProvider);

    return AlertDialog(
      title: Text(isEditing ? '编辑通道' : '添加数据通道'),
      content: SizedBox(
        width: 400,
        child: selectorState.when(
          data: (state) => _buildContent(state, isEditing),
          loading: () =>
              const Center(heightFactor: 3, child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('加载失败: $error')),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _canSubmit() ? _submit : null,
          child: Text(isEditing ? '保存' : '添加'),
        ),
      ],
    );
  }

  Widget _buildContent(ChannelSelectorState state, bool isEditing) {
    if (state.availableFields.isEmpty) {
      return _buildNoFieldsMessage();
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isEditing) ...[
            Text('选择数据源字段', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            _buildFieldSelector(state),
            const Divider(height: 24),
          ],
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: '通道名称',
              hintText: isEditing ? null : '留空则使用字段名',
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 16),
          _buildColorSelector(),
          const SizedBox(height: 16),
          _buildLineWidthSelector(),
        ],
      ),
    );
  }

  Widget _buildNoFieldsMessage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.info_outline,
          size: 48,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        const Text('暂无可用的数据字段', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          '请先在协议解析器中配置解析规则，\n并确保包含数值类型的字段。',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldSelector(ChannelSelectorState state) {
    // 按配置分组
    final groupedFields = <String, List<FieldInfo>>{};
    for (final field in state.availableFields) {
      final configName = field.configName ?? '未知配置';
      groupedFields.putIfAbsent(configName, () => []).add(field);
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView(
        shrinkWrap: true,
        children: groupedFields.entries.map((entry) {
          return ExpansionTile(
            title: Text(
              entry.key,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            initiallyExpanded: true,
            children: entry.value.map((field) {
              final isSelected = _selectedFieldIds.contains(field.id);
              return CheckboxListTile(
                title: Text(field.name),
                subtitle: Text(
                  '${field.typeName} • ${field.configName}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                value: isSelected,
                dense: true,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedFieldIds.add(field.id);
                    } else {
                      _selectedFieldIds.remove(field.id);
                    }
                  });
                },
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('线条颜色', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ChannelColors.colors.map((color) {
            final isSelected = _selectedColor == color;
            return InkWell(
              onTap: () => setState(() => _selectedColor = color),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withAlpha(128),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLineWidthSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('线条宽度', style: Theme.of(context).textTheme.titleSmall),
            Text(
              '${_lineWidth.toStringAsFixed(1)} px',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        Slider(
          value: _lineWidth,
          min: 0.5,
          max: 5.0,
          divisions: 9,
          onChanged: (value) => setState(() => _lineWidth = value),
        ),
      ],
    );
  }

  bool _canSubmit() {
    if (widget.existingChannel != null) {
      return true;
    }
    return _selectedFieldIds.isNotEmpty;
  }

  void _submit() {
    final selectorState = ref
        .read(channelSelectorProvider)
        .whenOrNull(data: (s) => s);
    if (selectorState == null) return;

    final channels = <ChartChannel>[];

    if (widget.existingChannel != null) {
      // 编辑模式
      channels.add(
        widget.existingChannel!.copyWith(
          name: _nameController.text.isEmpty
              ? widget.existingChannel!.name
              : _nameController.text,
          color: _selectedColor,
          lineWidth: _lineWidth,
        ),
      );
    } else {
      // 添加模式
      for (final fieldId in _selectedFieldIds) {
        final field = selectorState.availableFields.firstWhere(
          (f) => f.id == fieldId,
        );

        final name =
            _nameController.text.isEmpty || _selectedFieldIds.length > 1
            ? field.name
            : _nameController.text;

        // 为多个通道分配不同颜色
        final colorIndex = channels.length % ChannelColors.colors.length;

        channels.add(
          ChartChannel(
            id: 'ch_${DateTime.now().millisecondsSinceEpoch}_${channels.length}',
            name: name,
            fieldId: fieldId,
            color: _selectedFieldIds.length > 1
                ? ChannelColors.colors[colorIndex]
                : _selectedColor,
            lineWidth: _lineWidth,
          ),
        );
      }
    }

    Navigator.pop(context, channels);
  }
}
