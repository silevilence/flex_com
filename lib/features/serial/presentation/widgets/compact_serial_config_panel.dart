import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/application/config_providers.dart';
import '../../application/serial_providers.dart';
import '../../domain/serial_port_config.dart';

/// 紧凑型串口配置面板
///
/// 优化后的桌面端 UI，宽度更小，布局更紧凑。
/// 使用两列布局以减少高度占用。
class CompactSerialConfigPanel extends ConsumerStatefulWidget {
  const CompactSerialConfigPanel({super.key});

  @override
  ConsumerState<CompactSerialConfigPanel> createState() =>
      _CompactSerialConfigPanelState();
}

class _CompactSerialConfigPanelState
    extends ConsumerState<CompactSerialConfigPanel> {
  String? _selectedPort;
  int _baudRate = 9600;
  int _dataBits = 8;
  int _stopBits = 1;
  Parity _parity = Parity.none;
  FlowControl _flowControl = FlowControl.none;
  bool _configLoaded = false;

  // 紧凑型输入装饰
  InputDecoration _compactDecoration(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    isDense: true,
  );

  @override
  Widget build(BuildContext context) {
    final portsAsync = ref.watch(availablePortsProvider);
    final connectionState = ref.watch(serialConnectionProvider);
    final isConnected = connectionState.isConnected;

    // 加载保存的配置（仅一次）
    final savedConfigAsync = ref.watch(savedConfigProvider);
    if (!_configLoaded && savedConfigAsync.hasValue) {
      final config = savedConfigAsync.value;
      if (config != null) {
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
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
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
                        : () => ref.invalidate(availablePortsProvider),
                    icon: const Icon(Icons.refresh, size: 18),
                    tooltip: '刷新',
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 两列布局：波特率 + 数据位
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 36,
                    child: _buildIntDropdown(
                      label: '波特率',
                      currentValue: _baudRate,
                      options: SerialPortConfig.commonBaudRates,
                      enabled: !isConnected,
                      onChanged: (v) => setState(() => _baudRate = v),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 36,
                    child: _buildIntDropdown(
                      label: '数据位',
                      currentValue: _dataBits,
                      options: SerialPortConfig.commonDataBits,
                      enabled: !isConnected,
                      onChanged: (v) => setState(() => _dataBits = v),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 两列布局：停止位 + 校验位
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: _buildIntDropdown(
                      label: '停止位',
                      currentValue: _stopBits,
                      options: SerialPortConfig.commonStopBits,
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

            // 连接/断开按钮
            SizedBox(
              height: 36,
              child: FilledButton.icon(
                onPressed: _selectedPort == null
                    ? null
                    : () => _toggleConnection(),
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
        ),
      ),
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
    return DropdownButtonFormField<Parity>(
      key: ValueKey('parity_${_parity.value}'),
      initialValue: _parity,
      decoration: _compactDecoration('校验'),
      items: Parity.values
          .map(
            (p) =>
                DropdownMenuItem<Parity>(value: p, child: Text(p.displayName)),
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
    return DropdownButtonFormField<FlowControl>(
      key: ValueKey('flowControl_${_flowControl.value}'),
      initialValue: _flowControl,
      decoration: _compactDecoration('流控'),
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
              if (value != null) setState(() => _flowControl = value);
            },
      style: Theme.of(context).textTheme.bodySmall,
    );
  }

  Future<void> _toggleConnection() async {
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
        await ref.read(savedConfigProvider.notifier).saveConfig(config);
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
