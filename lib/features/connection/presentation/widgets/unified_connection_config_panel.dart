import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../connection/application/connection_providers.dart';
import '../../../connection/domain/connection_config.dart';
import '../../../settings/application/config_providers.dart';
import 'tcp_client_config_panel.dart';
import 'tcp_server_config_panel.dart';
import 'udp_config_panel.dart';

part 'unified_connection_config_panel.g.dart';

/// 当前选择的连接类型 Provider
@Riverpod(keepAlive: true)
class SelectedConnectionType extends _$SelectedConnectionType {
  @override
  ConnectionType build() => ConnectionType.serial;

  void setType(ConnectionType type) {
    state = type;
  }
}

/// 统一连接配置面板
///
/// 包含连接类型选择器和对应的配置面板。
/// 支持 Serial、TCP Client、TCP Server、UDP 四种连接类型。
class UnifiedConnectionConfigPanel extends ConsumerWidget {
  const UnifiedConnectionConfigPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedConnectionTypeProvider);
    final connectionState = ref.watch(unifiedConnectionProvider);
    final isConnected = connectionState.isConnected;

    // 如果已连接，显示当前连接类型
    final displayType = isConnected
        ? (connectionState.connectionType ?? selectedType)
        : selectedType;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 连接类型选择器
            _buildConnectionTypeSelector(
              context,
              ref,
              displayType,
              isConnected,
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // 根据类型显示对应配置面板
            _buildConfigPanel(displayType),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionTypeSelector(
    BuildContext context,
    WidgetRef ref,
    ConnectionType currentType,
    bool isConnected,
  ) {
    return SizedBox(
      height: 36,
      child: DropdownButtonFormField<ConnectionType>(
        initialValue: currentType,
        decoration: InputDecoration(
          labelText: '连接类型',
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
          isDense: true,
          prefixIcon: Icon(_getIconForType(currentType), size: 18),
        ),
        items: ConnectionType.values
            .map(
              (type) => DropdownMenuItem<ConnectionType>(
                value: type,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getIconForType(type), size: 16),
                    const SizedBox(width: 8),
                    Text(type.displayName),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: isConnected
            ? null
            : (type) {
                if (type != null) {
                  ref
                      .read(selectedConnectionTypeProvider.notifier)
                      .setType(type);
                }
              },
        style: Theme.of(context).textTheme.bodySmall,
        selectedItemBuilder: (context) => ConnectionType.values
            .map(
              (type) => Text(
                type.displayName,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildConfigPanel(ConnectionType type) {
    switch (type) {
      case ConnectionType.serial:
        return const _SerialConfigPanelContent();
      case ConnectionType.tcpClient:
        return const TcpClientConfigPanel();
      case ConnectionType.tcpServer:
        return const TcpServerConfigPanel();
      case ConnectionType.udp:
        return const UdpConfigPanel();
    }
  }

  IconData _getIconForType(ConnectionType type) {
    switch (type) {
      case ConnectionType.serial:
        return Icons.usb;
      case ConnectionType.tcpClient:
        return Icons.computer;
      case ConnectionType.tcpServer:
        return Icons.dns;
      case ConnectionType.udp:
        return Icons.swap_horiz;
    }
  }
}

/// 串口配置面板内容（从 CompactSerialConfigPanel 提取的核心内容）
class _SerialConfigPanelContent extends ConsumerStatefulWidget {
  const _SerialConfigPanelContent();

  @override
  ConsumerState<_SerialConfigPanelContent> createState() =>
      _SerialConfigPanelContentState();
}

class _SerialConfigPanelContentState
    extends ConsumerState<_SerialConfigPanelContent> {
  String? _selectedPort;
  int _baudRate = 9600;
  int _dataBits = 8;
  int _stopBits = 1;
  SerialParity _parity = SerialParity.none;
  SerialFlowControl _flowControl = SerialFlowControl.none;
  bool _configLoaded = false;

  InputDecoration _compactDecoration(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    isDense: true,
  );

  @override
  Widget build(BuildContext context) {
    final portsAsync = ref.watch(availableSerialPortsProvider);
    final connectionState = ref.watch(unifiedConnectionProvider);
    final isConnected =
        connectionState.isConnected &&
        connectionState.connectionType == ConnectionType.serial;

    // 加载保存的配置（仅一次）
    final savedConfigAsync = ref.watch(savedConfigProvider);
    if (!_configLoaded && savedConfigAsync.hasValue) {
      final config = savedConfigAsync.value;
      if (config != null) {
        _selectedPort = config.portName.isNotEmpty ? config.portName : null;
        _baudRate = config.baudRate;
        _dataBits = config.dataBits;
        _stopBits = config.stopBits;
        // 转换旧的枚举类型
        _parity = SerialParity.values.firstWhere(
          (p) => p.value == config.parity.value,
          orElse: () => SerialParity.none,
        );
        _flowControl = SerialFlowControl.values.firstWhere(
          (fc) => fc.value == config.flowControl.value,
          orElse: () => SerialFlowControl.none,
        );
        _configLoaded = true;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 串口选择行
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 36,
                child: portsAsync.when(
                  data: (ports) => _buildPortDropdown(ports, isConnected),
                  loading: () => _buildDisabledDropdown('串口', '加载中...'),
                  error: (error, _) =>
                      _buildErrorDropdown('串口', error.toString()),
                ),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                onPressed: isConnected
                    ? null
                    : () => ref.invalidate(availableSerialPortsProvider),
                icon: const Icon(Icons.refresh, size: 18),
                tooltip: '刷新',
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 波特率 + 数据位
        Row(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 36,
                child: _buildIntDropdown(
                  label: '波特率',
                  currentValue: _baudRate,
                  options: SerialConnectionConfig.commonBaudRates,
                  enabled: !isConnected,
                  onChanged: (v) => setState(() => _baudRate = v),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 36,
                child: _buildIntDropdown(
                  label: '数据位',
                  currentValue: _dataBits,
                  options: SerialConnectionConfig.commonDataBits,
                  enabled: !isConnected,
                  onChanged: (v) => setState(() => _dataBits = v),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 停止位 + 校验位
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 36,
                child: _buildIntDropdown(
                  label: '停止位',
                  currentValue: _stopBits,
                  options: SerialConnectionConfig.commonStopBits,
                  enabled: !isConnected,
                  onChanged: (v) => setState(() => _stopBits = v),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 36,
                child: _buildParityDropdown(isConnected),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 流控
        SizedBox(height: 36, child: _buildFlowControlDropdown(isConnected)),
        const SizedBox(height: 10),

        // 连接按钮
        SizedBox(
          height: 36,
          child: FilledButton.icon(
            onPressed: _selectedPort == null ? null : _toggleConnection,
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

  Widget _buildPortDropdown(List<String> ports, bool isConnected) {
    final validSelectedPort = ports.contains(_selectedPort)
        ? _selectedPort
        : null;

    return DropdownButtonFormField<String>(
      key: ValueKey('port_$validSelectedPort'),
      initialValue: validSelectedPort,
      decoration: _compactDecoration('串口'),
      items: ports.isEmpty
          ? [const DropdownMenuItem<String>(value: null, child: Text('无串口'))]
          : ports
                .map(
                  (port) =>
                      DropdownMenuItem<String>(value: port, child: Text(port)),
                )
                .toList(),
      onChanged: isConnected
          ? null
          : (value) => setState(() => _selectedPort = value),
      style: Theme.of(context).textTheme.bodySmall,
    );
  }

  Widget _buildDisabledDropdown(String label, String placeholder) {
    return DropdownButtonFormField<String>(
      decoration: _compactDecoration(label),
      items: [DropdownMenuItem<String>(value: null, child: Text(placeholder))],
      onChanged: null,
    );
  }

  Widget _buildErrorDropdown(String label, String errorText) {
    return DropdownButtonFormField<String>(
      decoration: _compactDecoration(label).copyWith(errorText: errorText),
      items: const [],
      onChanged: null,
    );
  }

  Widget _buildIntDropdown({
    required String label,
    required int currentValue,
    required List<int> options,
    required bool enabled,
    required void Function(int) onChanged,
  }) {
    return DropdownButtonFormField<int>(
      key: ValueKey('${label}_$currentValue'),
      initialValue: currentValue,
      decoration: _compactDecoration(label),
      items: options
          .map(
            (opt) =>
                DropdownMenuItem<int>(value: opt, child: Text(opt.toString())),
          )
          .toList(),
      onChanged: enabled
          ? (value) {
              if (value != null) onChanged(value);
            }
          : null,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }

  Widget _buildParityDropdown(bool isConnected) {
    return DropdownButtonFormField<SerialParity>(
      key: ValueKey('parity_${_parity.value}'),
      initialValue: _parity,
      decoration: _compactDecoration('校验'),
      items: SerialParity.values
          .map(
            (p) => DropdownMenuItem<SerialParity>(
              value: p,
              child: Text(p.displayName),
            ),
          )
          .toList(),
      onChanged: isConnected
          ? null
          : (value) {
              if (value != null) setState(() => _parity = value);
            },
      style: Theme.of(context).textTheme.bodySmall,
    );
  }

  Widget _buildFlowControlDropdown(bool isConnected) {
    return DropdownButtonFormField<SerialFlowControl>(
      key: ValueKey('flowControl_${_flowControl.value}'),
      initialValue: _flowControl,
      decoration: _compactDecoration('流控'),
      items: SerialFlowControl.values
          .map(
            (fc) => DropdownMenuItem<SerialFlowControl>(
              value: fc,
              child: Text(fc.displayName),
            ),
          )
          .toList(),
      onChanged: isConnected
          ? null
          : (value) {
              if (value != null) setState(() => _flowControl = value);
            },
      style: Theme.of(context).textTheme.bodySmall,
    );
  }

  Future<void> _toggleConnection() async {
    final notifier = ref.read(unifiedConnectionProvider.notifier);
    final isConnected = ref.read(unifiedConnectionProvider).isConnected;

    try {
      if (isConnected) {
        await notifier.disconnect();
      } else {
        final config = SerialConnectionConfig(
          portName: _selectedPort!,
          baudRate: _baudRate,
          dataBits: _dataBits,
          stopBits: _stopBits,
          parity: _parity,
          flowControl: _flowControl,
        );
        await notifier.connect(config);
        // 保存配置到旧格式（兼容）
        // TODO: 未来统一配置保存格式
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
