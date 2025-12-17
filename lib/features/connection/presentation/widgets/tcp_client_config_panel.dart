import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../connection/application/connection_providers.dart';
import '../../../connection/domain/connection_config.dart';

/// TCP Client 配置面板
class TcpClientConfigPanel extends ConsumerStatefulWidget {
  const TcpClientConfigPanel({super.key});

  @override
  ConsumerState<TcpClientConfigPanel> createState() =>
      _TcpClientConfigPanelState();
}

class _TcpClientConfigPanelState extends ConsumerState<TcpClientConfigPanel> {
  final _hostController = TextEditingController(text: '127.0.0.1');
  final _portController = TextEditingController(text: '8080');
  int _timeoutSeconds = 10;

  InputDecoration _compactDecoration(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    isDense: true,
  );

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(unifiedConnectionProvider);
    final isConnected = connectionState.isConnected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 主机地址
        SizedBox(
          height: 36,
          child: TextFormField(
            controller: _hostController,
            decoration: _compactDecoration('主机地址'),
            enabled: !isConnected,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 8),

        // 端口 + 超时
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 36,
                child: TextFormField(
                  controller: _portController,
                  decoration: _compactDecoration('端口'),
                  enabled: !isConnected,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 36,
                child: DropdownButtonFormField<int>(
                  initialValue: _timeoutSeconds,
                  decoration: _compactDecoration('超时(秒)'),
                  items: [5, 10, 15, 30, 60]
                      .map(
                        (v) =>
                            DropdownMenuItem<int>(value: v, child: Text('$v')),
                      )
                      .toList(),
                  onChanged: isConnected
                      ? null
                      : (v) {
                          if (v != null) setState(() => _timeoutSeconds = v);
                        },
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 连接按钮
        SizedBox(
          height: 36,
          child: FilledButton.icon(
            onPressed: _canConnect() ? _toggleConnection : null,
            icon: Icon(isConnected ? Icons.link_off : Icons.link, size: 18),
            label: Text(
              isConnected ? '断开' : '连接',
              style: const TextStyle(fontSize: 13),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: isConnected
                  ? Theme.of(context).colorScheme.error
                  : null,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),

        // 错误显示
        if (connectionState.error != null) ...[
          const SizedBox(height: 6),
          Text(
            connectionState.error!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 11,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  bool _canConnect() {
    final host = _hostController.text.trim();
    final portText = _portController.text.trim();
    if (host.isEmpty || portText.isEmpty) return false;
    final port = int.tryParse(portText);
    return port != null && port > 0 && port <= 65535;
  }

  Future<void> _toggleConnection() async {
    final notifier = ref.read(unifiedConnectionProvider.notifier);
    final isConnected = ref.read(unifiedConnectionProvider).isConnected;

    try {
      if (isConnected) {
        await notifier.disconnect();
      } else {
        final config = TcpClientConfig(
          host: _hostController.text.trim(),
          port: int.parse(_portController.text.trim()),
          timeout: Duration(seconds: _timeoutSeconds),
        );
        await notifier.connect(config);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('连接失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
