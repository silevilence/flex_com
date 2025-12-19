import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../connection/application/connection_providers.dart';
import '../../../connection/domain/connection_config.dart';
import '../../../settings/application/config_providers.dart';

/// UDP 配置面板
class UdpConfigPanel extends ConsumerStatefulWidget {
  const UdpConfigPanel({super.key});

  @override
  ConsumerState<UdpConfigPanel> createState() => _UdpConfigPanelState();
}

class _UdpConfigPanelState extends ConsumerState<UdpConfigPanel> {
  final _localPortController = TextEditingController(text: '5000');
  final _remoteHostController = TextEditingController(text: '127.0.0.1');
  final _remotePortController = TextEditingController(text: '5001');
  final _broadcastAddressController = TextEditingController(
    text: '255.255.255.255',
  );
  UdpMode _mode = UdpMode.unicast;
  bool _configLoaded = false;

  InputDecoration _compactDecoration(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    isDense: true,
  );

  @override
  void dispose() {
    _localPortController.dispose();
    _remoteHostController.dispose();
    _remotePortController.dispose();
    _broadcastAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(unifiedConnectionProvider);
    final isConnected = connectionState.isConnected;

    // 加载保存的配置（仅一次）
    final savedConfigAsync = ref.watch(savedUdpConfigProvider);
    if (!_configLoaded && savedConfigAsync.hasValue) {
      final config = savedConfigAsync.value;
      if (config != null) {
        _localPortController.text = config.localPort.toString();
        _remoteHostController.text = config.remoteHost;
        _remotePortController.text = config.remotePort.toString();
        _broadcastAddressController.text = config.broadcastAddress;
        _mode = config.mode;
        _configLoaded = true;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 模式选择
        SizedBox(
          height: 36,
          child: DropdownButtonFormField<UdpMode>(
            initialValue: _mode,
            decoration: _compactDecoration('模式'),
            items: UdpMode.values
                .map(
                  (m) => DropdownMenuItem<UdpMode>(
                    value: m,
                    child: Text(m.displayName),
                  ),
                )
                .toList(),
            onChanged: isConnected
                ? null
                : (v) {
                    if (v != null) setState(() => _mode = v);
                  },
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 8),

        // 本地端口
        SizedBox(
          height: 36,
          child: TextFormField(
            controller: _localPortController,
            decoration: _compactDecoration('本地端口 (0=自动)'),
            enabled: !isConnected,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 8),

        // 根据模式显示不同配置
        if (_mode == UdpMode.unicast) ...[
          // 远程主机
          SizedBox(
            height: 36,
            child: TextFormField(
              controller: _remoteHostController,
              decoration: _compactDecoration('远程主机'),
              enabled: !isConnected,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 8),
          // 远程端口
          SizedBox(
            height: 36,
            child: TextFormField(
              controller: _remotePortController,
              decoration: _compactDecoration('远程端口'),
              enabled: !isConnected,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ] else ...[
          // 广播地址
          SizedBox(
            height: 36,
            child: TextFormField(
              controller: _broadcastAddressController,
              decoration: _compactDecoration('广播地址'),
              enabled: !isConnected,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 8),
          // 广播端口
          SizedBox(
            height: 36,
            child: TextFormField(
              controller: _remotePortController,
              decoration: _compactDecoration('广播端口'),
              enabled: !isConnected,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
        const SizedBox(height: 10),

        // 打开/关闭按钮
        SizedBox(
          height: 36,
          child: FilledButton.icon(
            onPressed: _canOpen() ? _toggleConnection : null,
            icon: Icon(isConnected ? Icons.close : Icons.wifi, size: 18),
            label: Text(
              isConnected ? '关闭' : '打开',
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

  bool _canOpen() {
    final localPortText = _localPortController.text.trim();
    final remotePortText = _remotePortController.text.trim();

    if (localPortText.isEmpty) return false;
    final localPort = int.tryParse(localPortText);
    if (localPort == null || localPort < 0 || localPort > 65535) return false;

    if (_mode == UdpMode.unicast) {
      if (_remoteHostController.text.trim().isEmpty) return false;
    }

    if (remotePortText.isEmpty) return false;
    final remotePort = int.tryParse(remotePortText);
    return remotePort != null && remotePort > 0 && remotePort <= 65535;
  }

  Future<void> _toggleConnection() async {
    final notifier = ref.read(unifiedConnectionProvider.notifier);
    final isConnected = ref.read(unifiedConnectionProvider).isConnected;

    try {
      if (isConnected) {
        await notifier.disconnect();
      } else {
        final config = UdpConfig(
          localPort: int.parse(_localPortController.text.trim()),
          remoteHost: _remoteHostController.text.trim(),
          remotePort: int.parse(_remotePortController.text.trim()),
          mode: _mode,
          broadcastAddress: _broadcastAddressController.text.trim(),
        );
        await notifier.connect(config);

        // 保存配置
        await ref.read(savedUdpConfigProvider.notifier).saveConfig(config);
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
}
