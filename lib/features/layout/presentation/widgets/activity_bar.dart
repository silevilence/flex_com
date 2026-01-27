import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/presentation/settings_page.dart';
import '../../application/layout_providers.dart';
import '../../domain/layout_state.dart';
import '../../domain/panel_config.dart';

/// VS Code 风格的 Activity Bar
///
/// 根据面板当前位置分组显示图标：
/// - 上部：Left 区域的面板
/// - 中部：Right 区域的面板
/// - 下部：Bottom 区域的面板
class ActivityBar extends ConsumerWidget {
  const ActivityBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layoutState = ref.watch(layoutProvider);

    // 按当前位置分组面板
    final leftPanels = <PanelConfig>[];
    final rightPanels = <PanelConfig>[];
    final bottomPanels = <PanelConfig>[];

    for (final config in PanelConfigs.all) {
      final location = layoutState.getPanelLocation(config.id);
      switch (location) {
        case PanelLocation.left:
          leftPanels.add(config);
        case PanelLocation.right:
          rightPanels.add(config);
        case PanelLocation.bottom:
          bottomPanels.add(config);
        case null:
          leftPanels.add(config); // fallback
      }
    }

    return Container(
      width: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // 左侧区域面板图标（上部）
          ...leftPanels.map(
            (config) => _buildItem(
              context,
              ref,
              config,
              layoutState,
              PanelLocation.left,
            ),
          ),
          // 分隔线（如果有右侧面板）
          if (rightPanels.isNotEmpty) ...[
            _buildDivider(context),
            _buildLocationLabel(context, '右'),
            ...rightPanels.map(
              (config) => _buildItem(
                context,
                ref,
                config,
                layoutState,
                PanelLocation.right,
              ),
            ),
          ],
          // 分隔线（如果有底部面板）
          if (bottomPanels.isNotEmpty) ...[
            _buildDivider(context),
            _buildLocationLabel(context, '底'),
            ...bottomPanels.map(
              (config) => _buildItem(
                context,
                ref,
                config,
                layoutState,
                PanelLocation.bottom,
              ),
            ),
          ],
          const Spacer(),
          // 分隔线
          _buildDivider(context),
          const SizedBox(height: 4),
          // 设置按钮
          _ActivityBarItem(
            config: const PanelConfig(
              id: 'settings',
              title: '设置',
              icon: Icons.settings_outlined,
              defaultLocation: PanelLocation.left,
            ),
            isActive: false,
            currentLocation: PanelLocation.left,
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
            },
          ),
          // 重置布局按钮
          _ActivityBarItem(
            config: const PanelConfig(
              id: 'reset',
              title: '重置布局',
              icon: Icons.restore_outlined,
              defaultLocation: PanelLocation.left,
            ),
            isActive: false,
            currentLocation: PanelLocation.left,
            onTap: () {
              ref.read(layoutProvider.notifier).resetLayout();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    WidgetRef ref,
    PanelConfig config,
    LayoutState layoutState,
    PanelLocation currentLocation,
  ) {
    final isActive = layoutState.isPanelActive(config.id);
    return _ActivityBarItem(
      config: config,
      isActive: isActive,
      currentLocation: currentLocation,
      onTap: () {
        ref.read(layoutProvider.notifier).togglePanel(config.id);
      },
      onMoveTo: config.isMovable
          ? (location) {
              ref.read(layoutProvider.notifier).movePanel(config.id, location);
            }
          : null,
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }

  Widget _buildLocationLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.outline,
          fontSize: 10,
        ),
      ),
    );
  }
}

/// Activity Bar 单个项目
class _ActivityBarItem extends StatefulWidget {
  const _ActivityBarItem({
    required this.config,
    required this.isActive,
    required this.currentLocation,
    required this.onTap,
    this.onMoveTo,
  });

  final PanelConfig config;
  final bool isActive;
  final PanelLocation currentLocation;
  final VoidCallback onTap;
  final void Function(PanelLocation)? onMoveTo;

  @override
  State<_ActivityBarItem> createState() => _ActivityBarItemState();
}

class _ActivityBarItemState extends State<_ActivityBarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = widget.isActive;

    return GestureDetector(
      onSecondaryTapDown: widget.onMoveTo != null
          ? (details) => _showContextMenu(context, details.globalPosition)
          : null,
      child: Tooltip(
        message: widget.config.title,
        preferBelow: false,
        waitDuration: const Duration(milliseconds: 500),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 48,
              height: 44,
              margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? colorScheme.primaryContainer.withValues(alpha: 0.5)
                    : _isHovered
                    ? colorScheme.surfaceContainerHigh
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(
                    color: isActive ? colorScheme.primary : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Icon(
                widget.config.icon,
                size: 22,
                color: isActive
                    ? colorScheme.primary
                    : _isHovered
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, Offset position) {
    // 使用当前实际位置而非默认位置
    showMenu<PanelLocation>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        for (final location in PanelLocation.values)
          PopupMenuItem<PanelLocation>(
            value: location,
            enabled: location != widget.currentLocation,
            child: Row(
              children: [
                Icon(
                  _getLocationIcon(location),
                  size: 18,
                  color: location == widget.currentLocation
                      ? Theme.of(context).colorScheme.outline
                      : null,
                ),
                const SizedBox(width: 8),
                Text('移动到${location.displayName}'),
              ],
            ),
          ),
      ],
    ).then((value) {
      if (value != null && widget.onMoveTo != null) {
        widget.onMoveTo!(value);
      }
    });
  }

  IconData _getLocationIcon(PanelLocation location) {
    switch (location) {
      case PanelLocation.left:
        return Icons.border_left;
      case PanelLocation.right:
        return Icons.border_right;
      case PanelLocation.bottom:
        return Icons.border_bottom;
    }
  }
}
