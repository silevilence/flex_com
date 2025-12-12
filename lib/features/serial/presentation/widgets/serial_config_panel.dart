import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/application/config_providers.dart';
import '../../application/serial_providers.dart';
import '../../domain/serial_port_config.dart';

/// A widget that displays serial port configuration controls.
///
/// This includes port selection, baud rate, data bits, stop bits,
/// parity, and flow control settings.
class SerialConfigPanel extends ConsumerStatefulWidget {
  const SerialConfigPanel({super.key});

  @override
  ConsumerState<SerialConfigPanel> createState() => _SerialConfigPanelState();
}

class _SerialConfigPanelState extends ConsumerState<SerialConfigPanel> {
  String? _selectedPort;
  int _baudRate = 9600;
  int _dataBits = 8;
  int _stopBits = 1;
  Parity _parity = Parity.none;
  FlowControl _flowControl = FlowControl.none;
  bool _configLoaded = false;

  @override
  Widget build(BuildContext context) {
    final portsAsync = ref.watch(availablePortsProvider);
    final connectionState = ref.watch(serialConnectionProvider);
    final isConnected = connectionState.isConnected;

    // Watch saved config and apply when loaded (only once)
    final savedConfigAsync = ref.watch(savedConfigProvider);
    if (!_configLoaded && savedConfigAsync.hasValue) {
      final config = savedConfigAsync.value;
      if (config != null) {
        // Apply config synchronously during build (before returning widgets)
        _selectedPort = config.portName.isNotEmpty ? config.portName : null;
        _baudRate = config.baudRate;
        _dataBits = config.dataBits;
        _stopBits = config.stopBits;
        _parity = config.parity;
        _flowControl = config.flowControl;
        _configLoaded = true;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text('串口配置', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),

            // Port selection row
            Row(
              children: [
                Expanded(
                  child: portsAsync.when(
                    data: (ports) => _buildPortDropdown(ports, isConnected),
                    loading: () => _buildDisabledDropdown('串口', '加载中...'),
                    error: (error, _) =>
                        _buildErrorDropdown('串口', error.toString()),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: isConnected
                      ? null
                      : () => ref.invalidate(availablePortsProvider),
                  icon: const Icon(Icons.refresh),
                  tooltip: '刷新串口列表',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Baud rate
            _buildIntDropdown(
              label: '波特率',
              currentValue: _baudRate,
              options: SerialPortConfig.commonBaudRates,
              enabled: !isConnected,
              onChanged: (v) => setState(() => _baudRate = v),
            ),
            const SizedBox(height: 12),

            // Data bits
            _buildIntDropdown(
              label: '数据位',
              currentValue: _dataBits,
              options: SerialPortConfig.commonDataBits,
              enabled: !isConnected,
              onChanged: (v) => setState(() => _dataBits = v),
            ),
            const SizedBox(height: 12),

            // Stop bits
            _buildIntDropdown(
              label: '停止位',
              currentValue: _stopBits,
              options: SerialPortConfig.commonStopBits,
              enabled: !isConnected,
              onChanged: (v) => setState(() => _stopBits = v),
            ),
            const SizedBox(height: 12),

            // Parity
            _buildParityDropdown(isConnected),
            const SizedBox(height: 12),

            // Flow control
            _buildFlowControlDropdown(isConnected),
            const SizedBox(height: 16),

            // Connect/Disconnect button
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _selectedPort == null
                    ? null
                    : () => _toggleConnection(context),
                icon: Icon(isConnected ? Icons.link_off : Icons.link),
                label: Text(isConnected ? '断开连接' : '打开串口'),
                style: FilledButton.styleFrom(
                  backgroundColor: isConnected
                      ? Theme.of(context).colorScheme.error
                      : null,
                ),
              ),
            ),

            // Error display
            if (connectionState.error != null) ...[
              const SizedBox(height: 8),
              Text(
                connectionState.error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPortDropdown(List<String> ports, bool isConnected) {
    // Ensure selected port is in the list, otherwise reset to null
    final validSelectedPort = ports.contains(_selectedPort)
        ? _selectedPort
        : null;

    return DropdownButtonFormField<String>(
      key: ValueKey('port_$validSelectedPort'),
      initialValue: validSelectedPort,
      decoration: const InputDecoration(
        labelText: '串口',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: ports.isEmpty
          ? [const DropdownMenuItem<String>(value: null, child: Text('无可用串口'))]
          : ports
                .map(
                  (port) =>
                      DropdownMenuItem<String>(value: port, child: Text(port)),
                )
                .toList(),
      onChanged: isConnected
          ? null
          : (value) {
              setState(() {
                _selectedPort = value;
              });
            },
    );
  }

  Widget _buildDisabledDropdown(String label, String placeholder) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [DropdownMenuItem<String>(value: null, child: Text(placeholder))],
      onChanged: null,
    );
  }

  Widget _buildErrorDropdown(String label, String errorText) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        errorText: errorText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
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
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
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
    );
  }

  Widget _buildParityDropdown(bool isConnected) {
    return DropdownButtonFormField<Parity>(
      key: ValueKey('parity_${_parity.value}'),
      initialValue: _parity,
      decoration: const InputDecoration(
        labelText: '校验位',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: Parity.values
          .map(
            (p) =>
                DropdownMenuItem<Parity>(value: p, child: Text(p.displayName)),
          )
          .toList(),
      onChanged: isConnected
          ? null
          : (value) {
              if (value != null) {
                setState(() {
                  _parity = value;
                });
              }
            },
    );
  }

  Widget _buildFlowControlDropdown(bool isConnected) {
    return DropdownButtonFormField<FlowControl>(
      key: ValueKey('flowControl_${_flowControl.value}'),
      initialValue: _flowControl,
      decoration: const InputDecoration(
        labelText: '流控',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: FlowControl.values
          .map(
            (fc) => DropdownMenuItem<FlowControl>(
              value: fc,
              child: Text(fc.displayName),
            ),
          )
          .toList(),
      onChanged: isConnected
          ? null
          : (value) {
              if (value != null) {
                setState(() {
                  _flowControl = value;
                });
              }
            },
    );
  }

  Future<void> _toggleConnection(BuildContext context) async {
    final connectionNotifier = ref.read(serialConnectionProvider.notifier);
    final isConnected = ref.read(serialConnectionProvider).isConnected;

    try {
      if (isConnected) {
        await connectionNotifier.disconnect();
      } else {
        final config = SerialPortConfig(
          portName: _selectedPort!,
          baudRate: _baudRate,
          dataBits: _dataBits,
          stopBits: _stopBits,
          parity: _parity,
          flowControl: _flowControl,
        );
        await connectionNotifier.connect(config);

        // Save config on successful connection
        await ref.read(savedConfigProvider.notifier).saveConfig(config);
      }
    } catch (e) {
      if (context.mounted) {
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
