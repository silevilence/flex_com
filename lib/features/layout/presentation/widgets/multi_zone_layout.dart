import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';

import '../../../auto_reply/presentation/widgets/auto_reply_panel.dart';
import '../../../commands/presentation/widgets/command_list_panel.dart';
import '../../../connection/presentation/widgets/unified_connection_config_panel.dart';
import '../../../frame_parser/presentation/frame_parser_panel.dart';
import '../../../scripting/presentation/widgets/script_console_panel.dart';
import '../../../serial/application/send_helper_providers.dart';
import '../../../serial/presentation/widgets/data_display_panel.dart';
import '../../../serial/presentation/widgets/send_panel.dart';
import '../../../visualization/presentation/oscilloscope_panel.dart';
import '../../application/layout_providers.dart';
import '../../domain/layout_state.dart';
import '../../domain/panel_config.dart';
import 'panel_container.dart';

/// 多区域可折叠布局
///
/// 使用 MultiSplitView 实现 VS Code 风格的三区布局（左、右、底）
class MultiZoneLayout extends ConsumerStatefulWidget {
  const MultiZoneLayout({super.key});

  @override
  ConsumerState<MultiZoneLayout> createState() => _MultiZoneLayoutState();
}

class _MultiZoneLayoutState extends ConsumerState<MultiZoneLayout> {
  // 水平分割控制器（左-中-右）
  late MultiSplitViewController _horizontalController;
  // 垂直分割控制器（中央区域的上-下）
  late MultiSplitViewController _verticalController;

  // 追踪上一次的面板状态以优化更新
  bool _lastHasLeft = false;
  bool _lastHasRight = false;
  bool _lastHasBottom = false;

  @override
  void initState() {
    super.initState();
    _horizontalController = MultiSplitViewController();
    _verticalController = MultiSplitViewController();
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layoutState = ref.watch(layoutProvider);

    final hasLeft = layoutState.isLocationActive(PanelLocation.left);
    final hasRight = layoutState.isLocationActive(PanelLocation.right);
    final hasBottom = layoutState.isLocationActive(PanelLocation.bottom);

    // 检测面板状态变化并更新控制器区域
    _updateControllersIfNeeded(hasLeft, hasRight, hasBottom);

    // 如果没有左右面板，直接显示中央区域
    if (!hasLeft && !hasRight) {
      return _buildCenterArea(layoutState, hasBottom);
    }

    return MultiSplitView(
      controller: _horizontalController,
      axis: Axis.horizontal,
      dividerBuilder: _dividerBuilder,
      builder: (context, area) {
        final areaId = area.id;
        if (areaId == 'left') {
          return _buildPanelArea(layoutState, PanelLocation.left);
        } else if (areaId == 'right') {
          return _buildPanelArea(layoutState, PanelLocation.right);
        } else {
          return _buildCenterArea(layoutState, hasBottom);
        }
      },
    );
  }

  /// 根据需要更新控制器区域
  void _updateControllersIfNeeded(bool hasLeft, bool hasRight, bool hasBottom) {
    // 检查水平布局是否变化
    if (hasLeft != _lastHasLeft || hasRight != _lastHasRight) {
      _lastHasLeft = hasLeft;
      _lastHasRight = hasRight;

      final horizontalAreas = <Area>[];
      if (hasLeft) {
        horizontalAreas.add(Area(id: 'left', min: 200, size: 260, max: 400));
      }
      horizontalAreas.add(Area(id: 'center', flex: 1));
      if (hasRight) {
        horizontalAreas.add(Area(id: 'right', min: 200, size: 280, max: 450));
      }
      _horizontalController.areas = horizontalAreas;
    }

    // 检查垂直布局是否变化
    if (hasBottom != _lastHasBottom) {
      _lastHasBottom = hasBottom;

      if (hasBottom) {
        _verticalController.areas = [
          Area(id: 'main', flex: 1),
          Area(id: 'bottom', min: 120, size: 200, max: 400),
        ];
      } else {
        _verticalController.areas = [Area(id: 'main', flex: 1)];
      }
    }
  }

  /// 构建中央区域（主内容 + 可选底部面板）
  Widget _buildCenterArea(LayoutState layoutState, bool hasBottom) {
    if (!hasBottom) {
      return _buildMainContent();
    }

    return MultiSplitView(
      controller: _verticalController,
      axis: Axis.vertical,
      dividerBuilder: _dividerBuilder,
      builder: (context, area) {
        if (area.id == 'bottom') {
          return _buildPanelArea(layoutState, PanelLocation.bottom);
        }
        return _buildMainContent();
      },
    );
  }

  /// 分隔条构建器
  Widget _dividerBuilder(
    Axis axis,
    int index,
    bool resizable,
    bool dragging,
    bool highlighted,
    MultiSplitViewThemeData themeData,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isHovered = dragging || highlighted;

    return Container(
      width: axis == Axis.vertical ? null : 4,
      height: axis == Axis.horizontal ? null : 4,
      color: isHovered
          ? colorScheme.primary.withAlpha(128)
          : colorScheme.outlineVariant.withAlpha(64),
      child: MouseRegion(
        cursor: axis == Axis.vertical
            ? SystemMouseCursors.resizeColumn
            : SystemMouseCursors.resizeRow,
        child: const SizedBox.expand(),
      ),
    );
  }

  /// 构建主内容区域（数据显示 + 发送面板）
  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // 数据显示区域
          const Expanded(child: DataDisplayPanel()),
          const SizedBox(height: 8),
          // 发送面板
          const SendPanel(),
        ],
      ),
    );
  }

  /// 构建面板区域
  Widget _buildPanelArea(LayoutState layoutState, PanelLocation location) {
    final activePanelId = layoutState.getActivePanel(location);
    if (activePanelId == null) {
      return const SizedBox.shrink();
    }

    return PanelContainer(
      panelId: activePanelId,
      child: _buildPanelContent(activePanelId),
    );
  }

  /// 构建面板内容
  Widget _buildPanelContent(String panelId) {
    switch (panelId) {
      case 'serial':
        return const SingleChildScrollView(
          padding: EdgeInsets.all(8),
          child: UnifiedConnectionConfigPanel(),
        );
      case 'commands':
        return Padding(
          padding: const EdgeInsets.all(8),
          child: CommandListPanel(
            onSendCommand: (command) {
              ref
                  .read(sendPanelControllerProvider.notifier)
                  .sendCommand(command);
            },
          ),
        );
      case 'autoReply':
        return const Padding(
          padding: EdgeInsets.all(8),
          child: AutoReplyPanel(),
        );
      case 'scripts':
        return const ScriptConsolePanel();
      case 'frameParser':
        return const FrameParserPanel();
      case 'chart':
        return const OscilloscopePanel();
      default:
        return const Center(child: Text('未知面板'));
    }
  }
}
