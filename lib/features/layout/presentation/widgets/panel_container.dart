import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/layout_providers.dart';
import '../../domain/panel_config.dart';

/// 面板容器组件
///
/// 包装面板内容，提供标题栏和折叠功能
class PanelContainer extends ConsumerWidget {
  const PanelContainer({super.key, required this.panelId, required this.child});

  final String panelId;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = PanelConfigs.getById(panelId);
    if (config == null) return child;

    return Column(
      children: [
        // 面板标题栏
        _PanelHeader(
          config: config,
          onClose: () {
            final location = ref.read(layoutProvider).getPanelLocation(panelId);
            if (location != null) {
              ref.read(layoutProvider.notifier).collapseLocation(location);
            }
          },
        ),
        // 面板内容
        Expanded(child: child),
      ],
    );
  }
}

/// 面板标题栏
class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.config, required this.onClose});

  final PanelConfig config;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(config.icon, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              config.title,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // 关闭按钮
          SizedBox(
            width: 28,
            height: 28,
            child: IconButton(
              icon: const Icon(Icons.close, size: 14),
              onPressed: onClose,
              tooltip: '收起面板',
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
