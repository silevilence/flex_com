import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/hex_utils.dart';
import '../../application/send_helper_providers.dart';
import '../../application/serial_data_providers.dart';
import '../../application/serial_providers.dart';
import '../../domain/send_settings.dart';
import '../../domain/serial_data_entry.dart';

/// Widget that provides serial data sending functionality.
///
/// Supports both ASCII text and Hex input modes, with send helpers
/// including cyclic send, auto newline, and checksum options.
class SendPanel extends ConsumerStatefulWidget {
  const SendPanel({super.key});

  @override
  ConsumerState<SendPanel> createState() => _SendPanelState();
}

class _SendPanelState extends ConsumerState<SendPanel> {
  final TextEditingController _sendController = TextEditingController();
  final TextEditingController _intervalController = TextEditingController();
  final FocusNode _sendFocusNode = FocusNode();
  bool _isSending = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // 初始化间隔输入框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(sendSettingsProvider);
      _intervalController.text = settings.cyclicIntervalMs.toString();
    });
  }

  @override
  void dispose() {
    _sendController.dispose();
    _intervalController.dispose();
    _sendFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendData() async {
    final text = _sendController.text;
    if (text.isEmpty) return;

    final connectionState = ref.read(serialConnectionProvider);
    if (!connectionState.isConnected) {
      setState(() {
        _errorMessage = '串口未打开';
      });
      return;
    }

    final sendMode = ref.read(sendModeProvider);
    final settings = ref.read(sendSettingsProvider);
    Uint8List? data;

    try {
      if (sendMode == DataDisplayMode.hex) {
        data = HexUtils.hexStringToBytes(text);
      } else {
        data = HexUtils.asciiStringToBytes(text);
      }
    } on FormatException catch (e) {
      setState(() {
        _errorMessage = '格式错误: ${e.message}';
      });
      return;
    }

    if (data.isEmpty) {
      setState(() {
        _errorMessage = '发送数据为空';
      });
      return;
    }

    // 处理数据（追加换行符、校验等）
    data = processSendData(data, settings);

    setState(() {
      _isSending = true;
      _errorMessage = null;
    });

    try {
      await ref.read(serialConnectionProvider.notifier).sendData(data);
      // Add to log
      ref.read(serialDataLogProvider.notifier).addSentData(data);
      // Clear input on successful send
      _sendController.clear();
    } catch (e) {
      setState(() {
        _errorMessage = '发送失败: $e';
      });
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _toggleCyclicSend() {
    final cyclicState = ref.read(cyclicSendControllerProvider);

    if (cyclicState.isRunning) {
      ref.read(cyclicSendControllerProvider.notifier).stop();
    } else {
      final text = _sendController.text;
      if (text.isEmpty) {
        setState(() {
          _errorMessage = '请输入要发送的数据';
        });
        return;
      }

      final connectionState = ref.read(serialConnectionProvider);
      if (!connectionState.isConnected) {
        setState(() {
          _errorMessage = '串口未打开';
        });
        return;
      }

      setState(() {
        _errorMessage = null;
      });

      final sendMode = ref.read(sendModeProvider);
      ref.read(cyclicSendControllerProvider.notifier).start(text, sendMode);
    }
  }

  void _onIntervalChanged(String value) {
    final interval = int.tryParse(value);
    if (interval != null) {
      ref.read(sendSettingsProvider.notifier).setCyclicIntervalMs(interval);
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(serialConnectionProvider);
    final isConnected = connectionState.isConnected;
    final sendMode = ref.watch(sendModeProvider);
    final settings = ref.watch(sendSettingsProvider);
    final cyclicState = ref.watch(cyclicSendControllerProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Text('发送区', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                // Send mode toggle
                SegmentedButton<DataDisplayMode>(
                  segments: const [
                    ButtonSegment(
                      value: DataDisplayMode.ascii,
                      label: Text('ASCII'),
                    ),
                    ButtonSegment(
                      value: DataDisplayMode.hex,
                      label: Text('HEX'),
                    ),
                  ],
                  selected: {sendMode},
                  onSelectionChanged: (selected) {
                    ref.read(sendModeProvider.notifier).setMode(selected.first);
                    // Clear error when mode changes
                    setState(() {
                      _errorMessage = null;
                    });
                  },
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 发送辅助选项
            _buildSendHelperOptions(settings, cyclicState),
            const SizedBox(height: 12),

            // Input field and send button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _sendController,
                    focusNode: _sendFocusNode,
                    enabled:
                        isConnected && !_isSending && !cyclicState.isRunning,
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: sendMode == DataDisplayMode.hex
                          ? '输入十六进制数据 (如: 48 65 6C 6C 6F)'
                          : '输入文本数据',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      errorText: _errorMessage ?? cyclicState.lastError,
                    ),
                    style: const TextStyle(fontFamily: 'monospace'),
                    onSubmitted: (_) => _sendData(),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    // 发送按钮
                    SizedBox(
                      height: 48,
                      child: FilledButton.icon(
                        onPressed:
                            isConnected && !_isSending && !cyclicState.isRunning
                            ? _sendData
                            : null,
                        icon: _isSending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send),
                        label: const Text('发送'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 循环发送按钮
                    SizedBox(
                      height: 48,
                      child: settings.cyclicSendEnabled
                          ? FilledButton.tonalIcon(
                              onPressed: isConnected ? _toggleCyclicSend : null,
                              icon: Icon(
                                cyclicState.isRunning
                                    ? Icons.stop
                                    : Icons.repeat,
                              ),
                              label: Text(
                                cyclicState.isRunning
                                    ? '停止 (${cyclicState.sendCount})'
                                    : '循环',
                              ),
                              style: cyclicState.isRunning
                                  ? FilledButton.styleFrom(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.errorContainer,
                                      foregroundColor: Theme.of(
                                        context,
                                      ).colorScheme.onErrorContainer,
                                    )
                                  : null,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ],
            ),
            // Status indicator
            if (!isConnected) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '请先打开串口',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSendHelperOptions(
    SendSettings settings,
    CyclicSendState cyclicState,
  ) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // 追加换行符选项
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: settings.appendNewline,
              onChanged: cyclicState.isRunning
                  ? null
                  : (value) {
                      ref
                          .read(sendSettingsProvider.notifier)
                          .setAppendNewline(value ?? false);
                    },
            ),
            const Text('追加换行 (\\r\\n)'),
          ],
        ),

        // 校验类型选项
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('校验: '),
            DropdownButton<ChecksumType>(
              value: settings.checksumType,
              isDense: true,
              onChanged: cyclicState.isRunning
                  ? null
                  : (value) {
                      if (value != null) {
                        ref
                            .read(sendSettingsProvider.notifier)
                            .setChecksumType(value);
                      }
                    },
              items: ChecksumType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),

        // 循环发送选项
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: settings.cyclicSendEnabled,
              onChanged: cyclicState.isRunning
                  ? null
                  : (value) {
                      ref
                          .read(sendSettingsProvider.notifier)
                          .setCyclicSendEnabled(value ?? false);
                    },
            ),
            const Text('定时发送'),
            if (settings.cyclicSendEnabled) ...[
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _intervalController,
                  enabled: !cyclicState.isRunning,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(),
                    suffixText: 'ms',
                  ),
                  onChanged: _onIntervalChanged,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
