import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../connection/application/connection_providers.dart';
import '../../../connection/domain/connection_config.dart';
import '../../application/display_settings_providers.dart';

/// Status bar widget that displays connection status and byte counters.
///
/// Design: Clean, subtle, professional status bar with clear visual hierarchy.
class StatusBar extends ConsumerWidget {
  const StatusBar({super.key});

  String _formatByteCount(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  /// Get a human-readable connection info string based on connection type.
  String _getConnectionInfo(UnifiedConnectionState state) {
    final config = state.config;
    if (config == null) return '-';

    switch (config.type) {
      case ConnectionType.serial:
        final serialConfig = config as SerialConnectionConfig;
        return '${serialConfig.portName} @ ${serialConfig.baudRate}';
      case ConnectionType.tcpClient:
        final tcpConfig = config as TcpClientConfig;
        return 'TCP → ${tcpConfig.host}:${tcpConfig.port}';
      case ConnectionType.tcpServer:
        final serverConfig = config as TcpServerConfig;
        final clientCount = state.connectedClients.length;
        return 'TCP Server :${serverConfig.port} ($clientCount 客户端)';
      case ConnectionType.udp:
        final udpConfig = config as UdpConfig;
        return 'UDP ${udpConfig.remoteHost}:${udpConfig.remotePort}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(unifiedConnectionProvider);
    final byteCounter = ref.watch(byteCounterProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final isConnected = connectionState.isConnected;
    final connectionInfo = _getConnectionInfo(connectionState);

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          // Connection status indicator with pulse animation
          _ConnectionIndicator(isConnected: isConnected),
          const SizedBox(width: 8),
          // Connection info
          Text(
            isConnected ? connectionInfo : '未连接',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isConnected
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
              fontWeight: isConnected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          const Spacer(),
          // RX counter
          _CounterChip(
            icon: Icons.arrow_downward_rounded,
            label: 'RX',
            value: _formatByteCount(byteCounter.rxBytes),
            color: colorScheme.primary,
          ),
          const SizedBox(width: 16),
          // TX counter
          _CounterChip(
            icon: Icons.arrow_upward_rounded,
            label: 'TX',
            value: _formatByteCount(byteCounter.txBytes),
            color: colorScheme.tertiary,
          ),
          const SizedBox(width: 8),
          // Reset button
          _ResetButton(
            onPressed: () {
              ref.read(byteCounterProvider.notifier).reset();
            },
          ),
        ],
      ),
    );
  }
}

/// Connection status indicator with subtle animation
class _ConnectionIndicator extends StatefulWidget {
  const _ConnectionIndicator({required this.isConnected});

  final bool isConnected;

  @override
  State<_ConnectionIndicator> createState() => _ConnectionIndicatorState();
}

class _ConnectionIndicatorState extends State<_ConnectionIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isConnected) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_ConnectionIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isConnected != oldWidget.isConnected) {
      if (widget.isConnected) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = widget.isConnected
        ? colorScheme
              .tertiary // Green for connected
        : colorScheme.outline; // Gray for disconnected

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: baseColor.withValues(
              alpha: widget.isConnected ? _animation.value : 1.0,
            ),
            boxShadow: widget.isConnected
                ? [
                    BoxShadow(
                      color: baseColor.withValues(
                        alpha: 0.4 * _animation.value,
                      ),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        );
      },
    );
  }
}

/// A chip widget that displays a counter with an icon and label.
class _CounterChip extends StatelessWidget {
  const _CounterChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface,
            fontFamily: 'Consolas, monospace',
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

/// Reset button with hover effect
class _ResetButton extends StatefulWidget {
  const _ResetButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_ResetButton> createState() => _ResetButtonState();
}

class _ResetButtonState extends State<_ResetButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Tooltip(
          message: '复位计数器',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _isHovered
                  ? colorScheme.surfaceContainerHigh
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.restart_alt_rounded,
              size: 16,
              color: _isHovered
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
