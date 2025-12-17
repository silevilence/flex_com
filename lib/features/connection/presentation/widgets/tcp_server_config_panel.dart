import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../connection/application/connection_providers.dart';
import '../../../connection/domain/connection.dart';
import '../../../connection/domain/connection_config.dart';

/// TCP Server 配置面板
class TcpServerConfigPanel extends ConsumerStatefulWidget {
  const TcpServerConfigPanel({super.key});

  @override
  ConsumerState<TcpServerConfigPanel> createState() =>
      _TcpServerConfigPanelState();
}

class _TcpServerConfigPanelState extends ConsumerState<TcpServerConfigPanel> {
  final _bindAddressController = TextEditingController(text: '0.0.0.0');
  final _portController = TextEditingController(text: '8080');
  int _maxClients = 10;

  InputDecoration _compactDecoration(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    isDense: true,
  );

  @override
  void dispose() {
    _bindAddressController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(unifiedConnectionProvider);
    final isConnected = connectionState.isConnected;
    final clients = connectionState.connectedClients;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 绑定地址
        SizedBox(
          height: 36,
          child: TextFormField(
            controller: _bindAddressController,
            decoration: _compactDecoration('绑定地址'),
            enabled: !isConnected,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 8),

        // 端口 + 最大连接数
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
                  initialValue: _maxClients,
                  decoration: _compactDecoration('最大连接'),
                  items: [1, 5, 10, 20, 50]
                      .map(
                        (v) =>
                            DropdownMenuItem<int>(value: v, child: Text('$v')),
                      )
                      .toList(),
                  onChanged: isConnected
                      ? null
                      : (v) {
                          if (v != null) setState(() => _maxClients = v);
                        },
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 启动/停止按钮
        SizedBox(
          height: 36,
          child: FilledButton.icon(
            onPressed: _canStart() ? _toggleServer : null,
            icon: Icon(isConnected ? Icons.stop : Icons.play_arrow, size: 18),
            label: Text(
              isConnected ? '停止监听' : '开始监听',
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

        // 客户端列表
        if (isConnected && clients.isNotEmpty) ...[
          const SizedBox(height: 10),
          _buildClientList(clients),
        ],

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

  Widget _buildClientList(List<ClientInfo> clients) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(6),
            child: Text(
              '已连接客户端 (${clients.length})',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          const Divider(height: 1),
          ...clients.map((client) => _buildClientTile(client)),
        ],
      ),
    );
  }

  Widget _buildClientTile(ClientInfo client) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: Text(
        '${client.remoteAddress}:${client.remotePort}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 16),
        tooltip: '断开',
        onPressed: () => _disconnectClient(client.id),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      ),
    );
  }

  bool _canStart() {
    final portText = _portController.text.trim();
    if (portText.isEmpty) return false;
    final port = int.tryParse(portText);
    return port != null && port > 0 && port <= 65535;
  }

  Future<void> _toggleServer() async {
    final notifier = ref.read(unifiedConnectionProvider.notifier);
    final isConnected = ref.read(unifiedConnectionProvider).isConnected;

    try {
      if (isConnected) {
        await notifier.disconnect();
      } else {
        final config = TcpServerConfig(
          bindAddress: _bindAddressController.text.trim(),
          port: int.parse(_portController.text.trim()),
          maxClients: _maxClients,
        );
        await notifier.connect(config);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _disconnectClient(String clientId) async {
    try {
      await ref
          .read(unifiedConnectionProvider.notifier)
          .disconnectClient(clientId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('断开客户端失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
