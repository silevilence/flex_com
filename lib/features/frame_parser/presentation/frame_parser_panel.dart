import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/hex_utils.dart';
import '../application/parser_providers.dart';
import '../data/generic_frame_parser.dart';
import '../domain/frame_config.dart';
import '../domain/protocol_parser.dart';
import 'frame_parser_config_dialog.dart';

/// 帧解析器面板
///
/// 显示协议配置、解析结果和测试功能
class FrameParserPanel extends ConsumerStatefulWidget {
  const FrameParserPanel({super.key});

  @override
  ConsumerState<FrameParserPanel> createState() => _FrameParserPanelState();
}

class _FrameParserPanelState extends ConsumerState<FrameParserPanel> {
  final _testInputController = TextEditingController();
  ParsedFrame? _testResult;

  @override
  void dispose() {
    _testInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parserState = ref.watch(parserProvider);

    return parserState.when(
      data: (state) => _buildContent(state, theme),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('加载失败: $error')),
    );
  }

  Widget _buildContent(dynamic state, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(state, theme),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildConfigSelector(state, theme),
                const SizedBox(height: 12),
                _buildTestSection(state, theme),
                if (_testResult != null) ...[
                  const SizedBox(height: 12),
                  _buildResultSection(_testResult!, theme),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(dynamic state, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.settings_input_component_outlined,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '协议解析器',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // 启用开关
          SizedBox(
            height: 24,
            child: Switch(
              value: state.isEnabled,
              onChanged: (value) {
                ref.read(parserProvider.notifier).setEnabled(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigSelector(dynamic state, ThemeData theme) {
    final configs = state.configs as List<FrameConfig>;
    final activeId = state.activeConfigId as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '协议配置',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: _addConfig,
              tooltip: '新建配置',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (configs.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.folder_open_outlined,
                    size: 32,
                    color: theme.colorScheme.onSurfaceVariant.withAlpha(128),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '暂无协议配置',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: configs.map((config) {
              final isActive = config.id == activeId;
              return Card(
                margin: const EdgeInsets.only(bottom: 4),
                color: isActive
                    ? theme.colorScheme.primaryContainer.withAlpha(100)
                    : null,
                child: InkWell(
                  onTap: () {
                    ref
                        .read(parserProvider.notifier)
                        .setActiveConfig(isActive ? null : config.id);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isActive
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          size: 18,
                          color: isActive
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                config.name,
                                style: TextStyle(
                                  fontWeight: isActive
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              if (config.description.isNotEmpty)
                                Text(
                                  config.description,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: () => _editConfig(config),
                          tooltip: '编辑',
                          visualDensity: VisualDensity.compact,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: theme.colorScheme.error,
                          ),
                          onPressed: () => _deleteConfig(config),
                          tooltip: '删除',
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildTestSection(dynamic state, ThemeData theme) {
    final activeConfig = state.activeConfig as FrameConfig?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '测试解析',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _testInputController,
          decoration: InputDecoration(
            hintText: '输入 Hex 数据进行测试，如: AA 55 01 02 03',
            border: const OutlineInputBorder(),
            isDense: true,
            suffixIcon: IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: activeConfig != null ? _runTest : null,
              tooltip: '解析',
            ),
          ),
          style: const TextStyle(fontFamily: 'Consolas', fontSize: 13),
          maxLines: 2,
          onSubmitted: (_) => _runTest(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: activeConfig != null ? _runTest : null,
              icon: const Icon(Icons.analytics_outlined, size: 18),
              label: const Text('解析'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {
                _testInputController.clear();
                setState(() {
                  _testResult = null;
                });
              },
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('清空'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultSection(ParsedFrame result, ThemeData theme) {
    final isValid = result.isValid;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isValid
            ? theme.colorScheme.primaryContainer.withAlpha(50)
            : theme.colorScheme.errorContainer.withAlpha(50),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isValid
              ? theme.colorScheme.primary.withAlpha(100)
              : theme.colorScheme.error.withAlpha(100),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isValid ? Icons.check_circle_outline : Icons.error_outline,
                color: isValid
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isValid ? '解析成功' : '解析失败',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isValid
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (result.checksumValid != null) ...[
                const SizedBox(width: 12),
                Chip(
                  label: Text(
                    result.checksumValid! ? '校验通过' : '校验失败',
                    style: TextStyle(
                      fontSize: 12,
                      color: result.checksumValid!
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                    ),
                  ),
                  backgroundColor: result.checksumValid!
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.errorContainer,
                  side: BorderSide.none,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
          if (result.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              result.errorMessage!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
          if (result.fields.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '解析字段 (${result.fields.length})',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...result.fields.map((field) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        field.definition.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        field.displayValue ?? field.value.toString(),
                        style: const TextStyle(
                          fontFamily: 'Consolas',
                          fontSize: 13,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 16),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(
                            text: field.displayValue ?? field.value.toString(),
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('已复制'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      tooltip: '复制',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Future<void> _addConfig() async {
    final config = await FrameParserConfigDialog.show(context);
    if (config != null) {
      await ref.read(parserProvider.notifier).addConfig(config);
    }
  }

  Future<void> _editConfig(FrameConfig config) async {
    final updated = await FrameParserConfigDialog.show(
      context,
      initialConfig: config,
    );
    if (updated != null) {
      await ref.read(parserProvider.notifier).updateConfig(updated);
    }
  }

  Future<void> _deleteConfig(FrameConfig config) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除配置'),
        content: Text('确定要删除配置 "${config.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(parserProvider.notifier).deleteConfig(config.id);
    }
  }

  void _runTest() {
    final parserState = ref.read(parserProvider).valueOrNull;
    final activeConfig = parserState?.activeConfig;

    if (activeConfig == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先选择一个协议配置')));
      return;
    }

    final input = _testInputController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入测试数据')));
      return;
    }

    try {
      final data = HexUtils.hexStringToBytes(input);
      final parser = const GenericFrameParser();
      final result = parser.parse(data, config: activeConfig);

      setState(() {
        _testResult = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('数据格式错误: $e')));
    }
  }
}

/// 辅助方法扩展：获取 AsyncValue 的值
extension AsyncValueExtension<T> on AsyncValue<T> {
  T? get valueOrNull {
    return when(
      data: (data) => data,
      loading: () => null,
      error: (_, __) => null,
    );
  }
}
