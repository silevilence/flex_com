import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/hex_utils.dart';
import '../../application/serial_data_providers.dart';
import '../../application/serial_providers.dart';
import '../../domain/serial_data_entry.dart';

/// Widget that provides serial data sending functionality.
///
/// Supports both ASCII text and Hex input modes.
class SendPanel extends ConsumerStatefulWidget {
  const SendPanel({super.key});

  @override
  ConsumerState<SendPanel> createState() => _SendPanelState();
}

class _SendPanelState extends ConsumerState<SendPanel> {
  final TextEditingController _sendController = TextEditingController();
  final FocusNode _sendFocusNode = FocusNode();
  bool _isSending = false;
  String? _errorMessage;

  @override
  void dispose() {
    _sendController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(serialConnectionProvider);
    final isConnected = connectionState.isConnected;
    final sendMode = ref.watch(sendModeProvider);

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
            // Input field and send button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _sendController,
                    focusNode: _sendFocusNode,
                    enabled: isConnected && !_isSending,
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
                      errorText: _errorMessage,
                    ),
                    style: const TextStyle(fontFamily: 'monospace'),
                    onSubmitted: (_) => _sendData(),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: isConnected && !_isSending ? _sendData : null,
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
}
