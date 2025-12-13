import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/calculator_providers.dart';
import '../domain/algorithm_type.dart';
import '../domain/calculator_state.dart';

/// 校验/摘要计算器对话框
class ChecksumCalculatorDialog extends ConsumerStatefulWidget {
  const ChecksumCalculatorDialog({
    super.key,
    this.initialData,
    this.initialFormat = InputFormat.hex,
    this.onAppendResult,
  });

  /// 初始数据（根据 initialFormat 格式）
  final String? initialData;

  /// 初始输入格式（与发送区同步）
  final InputFormat initialFormat;

  /// 将结果附加到待发送帧的回调
  final void Function(String hexResult)? onAppendResult;

  /// 打开计算器对话框
  static Future<void> show(
    BuildContext context, {
    String? initialData,
    InputFormat initialFormat = InputFormat.hex,
    void Function(String hexResult)? onAppendResult,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => ChecksumCalculatorDialog(
        initialData: initialData,
        initialFormat: initialFormat,
        onAppendResult: onAppendResult,
      ),
    );
  }

  @override
  ConsumerState<ChecksumCalculatorDialog> createState() =>
      _ChecksumCalculatorDialogState();
}

class _ChecksumCalculatorDialogState
    extends ConsumerState<ChecksumCalculatorDialog> {
  late TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();

    // 初始化时同步发送区的格式和数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(calculatorProvider.notifier);
      // 设置初始格式
      notifier.setInputFormat(widget.initialFormat);
      // 如果有初始数据，设置数据
      if (widget.initialData != null && widget.initialData!.isNotEmpty) {
        notifier.setInputText(widget.initialData!);
        _inputController.text = widget.initialData!;
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calculatorProvider);
    final theme = Theme.of(context);

    // 同步输入框内容
    if (_inputController.text != state.inputText) {
      _inputController.text = state.inputText;
      _inputController.selection = TextSelection.collapsed(
        offset: state.inputText.length,
      );
    }

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 标题栏
              _buildTitleBar(theme),
              const SizedBox(height: 16),

              // 输入区域
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInputSection(state, theme),
                      const SizedBox(height: 16),

                      // 算法选择
                      _buildAlgorithmSection(state, theme),
                      const SizedBox(height: 16),

                      // 结果区域
                      _buildResultSection(state, theme),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              // 操作按钮
              _buildActionButtons(state, theme),
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
          Icons.calculate_outlined,
          color: theme.colorScheme.primary,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '校验/摘要计算器',
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

  Widget _buildInputSection(CalculatorState state, ThemeData theme) {
    final preview = ref.watch(inputBytesPreviewProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 输入格式选择
        Row(
          children: [
            Text('输入数据', style: theme.textTheme.titleSmall),
            const Spacer(),
            _buildFormatSelector(state),
          ],
        ),
        const SizedBox(height: 8),

        // 输入框
        TextField(
          controller: _inputController,
          maxLines: 4,
          minLines: 3,
          decoration: InputDecoration(
            hintText: state.inputFormat == InputFormat.hex
                ? '输入十六进制数据，如: 01 02 03 04'
                : '输入 ASCII 文本',
            border: const OutlineInputBorder(),
            isDense: true,
            errorText: state.errorMessage,
          ),
          style: const TextStyle(fontFamily: 'Consolas', fontSize: 14),
          onChanged: (value) {
            ref.read(calculatorProvider.notifier).setInputText(value);
          },
        ),

        // 字节预览
        if (preview.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            preview,
            style: theme.textTheme.bodySmall?.copyWith(
              color: preview.contains('错误')
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFormatSelector(CalculatorState state) {
    return SegmentedButton<InputFormat>(
      segments: const [
        ButtonSegment(
          value: InputFormat.hex,
          label: Text('Hex'),
          icon: Icon(Icons.code, size: 16),
        ),
        ButtonSegment(
          value: InputFormat.ascii,
          label: Text('ASCII'),
          icon: Icon(Icons.text_fields, size: 16),
        ),
      ],
      selected: {state.inputFormat},
      onSelectionChanged: (selection) {
        // 切换格式时自动转换数据
        ref
            .read(calculatorProvider.notifier)
            .switchFormatAndConvert(selection.first);
        // 同步输入框内容
        final newState = ref.read(calculatorProvider);
        _inputController.text = newState.inputText;
      },
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildAlgorithmSection(CalculatorState state, ThemeData theme) {
    final groupedAlgorithms = ref.watch(groupedAlgorithmsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('选择算法', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),

        // 按分类显示算法
        ...groupedAlgorithms.entries.map((entry) {
          return _buildAlgorithmCategorySection(
            entry.key,
            entry.value,
            state,
            theme,
          );
        }),
      ],
    );
  }

  Widget _buildAlgorithmCategorySection(
    AlgorithmCategory category,
    List<AlgorithmType> algorithms,
    CalculatorState state,
    ThemeData theme,
  ) {
    if (algorithms.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getCategoryName(category),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: algorithms.map((algorithm) {
              final isSelected = state.selectedAlgorithmId == algorithm.id;
              return FilterChip(
                label: Text(algorithm.name),
                selected: isSelected,
                onSelected: (_) {
                  ref
                      .read(calculatorProvider.notifier)
                      .setAlgorithm(algorithm.id);
                },
                tooltip: algorithm.description,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(AlgorithmCategory category) {
    switch (category) {
      case AlgorithmCategory.checksum:
        return 'Checksum (校验和)';
      case AlgorithmCategory.crc:
        return 'CRC (循环冗余校验)';
      case AlgorithmCategory.xor:
        return 'XOR (异或校验)';
      case AlgorithmCategory.digest:
        return 'Digest (摘要/哈希)';
    }
  }

  Widget _buildResultSection(CalculatorState state, ThemeData theme) {
    if (!state.hasResult) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Center(
          child: Text(
            '点击"计算"按钮查看结果',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final result = state.result!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withAlpha(100),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.primary.withAlpha(100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${result.type.name} 结果',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () => _copyResult(result.hexString),
                tooltip: '复制结果',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 结果显示
          SelectableText(
            result.hexString,
            style: TextStyle(
              fontFamily: 'Consolas',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 8),
          Text(
            '${result.rawBytes.length} 字节',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(CalculatorState state, ThemeData theme) {
    return Row(
      children: [
        // 清空按钮
        OutlinedButton.icon(
          onPressed: () {
            ref.read(calculatorProvider.notifier).clear();
            _inputController.clear();
          },
          icon: const Icon(Icons.clear_all, size: 18),
          label: const Text('清空'),
        ),
        const SizedBox(width: 8),

        // 附加到发送帧按钮
        if (widget.onAppendResult != null && state.hasResult)
          OutlinedButton.icon(
            onPressed: () {
              widget.onAppendResult!(state.result!.hexString);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text('附加到发送帧'),
          ),

        const Spacer(),

        // 计算按钮
        FilledButton.icon(
          onPressed: state.inputText.isNotEmpty
              ? () {
                  ref.read(calculatorProvider.notifier).calculate();
                }
              : null,
          icon: const Icon(Icons.calculate, size: 18),
          label: const Text('计算'),
        ),
      ],
    );
  }

  void _copyResult(String result) {
    Clipboard.setData(ClipboardData(text: result));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制到剪贴板'), duration: Duration(seconds: 2)),
    );
  }
}
