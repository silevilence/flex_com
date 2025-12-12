import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/display_settings_providers.dart';
import '../../application/serial_providers.dart';

/// Status bar widget that displays connection status and byte counters.
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(serialConnectionProvider);
    final byteCounter = ref.watch(byteCounterProvider);

    final isConnected = connectionState.isConnected;
    final portName = connectionState.config?.portName ?? '-';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          // Connection status indicator
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected
                  ? Colors.green
                  : Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isConnected ? '已连接: $portName' : '未连接',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          // RX counter
          _CounterChip(
            icon: Icons.arrow_downward,
            label: 'RX',
            value: _formatByteCount(byteCounter.rxBytes),
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16),
          // TX counter
          _CounterChip(
            icon: Icons.arrow_upward,
            label: 'TX',
            value: _formatByteCount(byteCounter.txBytes),
            color: Theme.of(context).colorScheme.tertiary,
          ),
          const SizedBox(width: 8),
          // Reset button
          IconButton(
            onPressed: () {
              ref.read(byteCounterProvider.notifier).reset();
            },
            icon: const Icon(Icons.restart_alt, size: 18),
            tooltip: '复位计数器',
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(4),
              minimumSize: const Size(28, 28),
            ),
          ),
        ],
      ),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
        ),
      ],
    );
  }
}
