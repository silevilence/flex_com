import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/widgets/collapsible_sidebar.dart';
import '../../../core/widgets/dockable_bottom_panel.dart';
import '../../commands/presentation/widgets/command_list_panel.dart';
import '../../serial/application/send_helper_providers.dart';
import '../../serial/presentation/widgets/compact_serial_config_panel.dart';
import '../../serial/presentation/widgets/data_display_panel.dart';
import '../../serial/presentation/widgets/send_panel.dart';
import '../../serial/presentation/widgets/status_bar.dart';

part 'home_page.g.dart';

/// 左侧面板展开状态的 Notifier
@riverpod
class LeftPanelExpanded extends _$LeftPanelExpanded {
  @override
  bool build() => true;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}

/// 底部面板展开状态的 Notifier
@riverpod
class BottomPanelExpanded extends _$BottomPanelExpanded {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}

/// Home page of the FlexCom application
///
/// 优化后的 UI 布局：
/// - 左侧紧凑型串口配置面板（可折叠）
/// - 中央数据显示区域
/// - 底部可停靠面板（指令列表等高级功能）
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLeftPanelExpanded = ref.watch(leftPanelExpandedProvider);
    final isBottomPanelExpanded = ref.watch(bottomPanelExpandedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FlexCom'),
        centerTitle: true,
        toolbarHeight: 40,
        titleTextStyle: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      body: Column(
        children: [
          // 主内容区域
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 左侧可折叠面板 - 串口配置
                CollapsibleSidebar(
                  expandedWidth: 280,
                  collapsedWidth: 36,
                  isExpanded: isLeftPanelExpanded,
                  onToggle: (expanded) {
                    ref.read(leftPanelExpandedProvider.notifier).set(expanded);
                  },
                  title: '串口配置',
                  icon: Icons.settings_ethernet,
                  position: SidebarPosition.left,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(8),
                    child: const CompactSerialConfigPanel(),
                  ),
                ),
                // 主内容区域 - 数据显示和发送
                Expanded(
                  child: Padding(
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
                  ),
                ),
              ],
            ),
          ),
          // 底部可停靠面板 - 高级功能
          DockableBottomPanel(
            expandedHeight: 220,
            collapsedHeight: 36,
            initialExpanded: isBottomPanelExpanded,
            onExpandedChanged: (expanded) {
              ref.read(bottomPanelExpandedProvider.notifier).set(expanded);
            },
            items: [
              DockablePanelItem(
                id: 'commands',
                title: '指令列表',
                icon: Icons.list_alt,
                builder: (context) => _buildCommandListPanel(ref),
              ),
              DockablePanelItem(
                id: 'scripts',
                title: '脚本控制',
                icon: Icons.code,
                builder: (context) => _buildPlaceholderPanel(
                  context,
                  '脚本控制',
                  '即将推出：支持 Lua/Dart 脚本自动化',
                  Icons.code,
                ),
              ),
              DockablePanelItem(
                id: 'chart',
                title: '波形图',
                icon: Icons.show_chart,
                builder: (context) => _buildPlaceholderPanel(
                  context,
                  '波形图',
                  '即将推出：实时数据可视化',
                  Icons.show_chart,
                ),
              ),
            ],
          ),
          // 状态栏
          const StatusBar(),
        ],
      ),
    );
  }

  /// 构建指令列表面板
  Widget _buildCommandListPanel(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: CommandListPanel(
        onSendCommand: (command) {
          ref.read(sendPanelControllerProvider.notifier).sendCommand(command);
        },
      ),
    );
  }

  /// 构建占位面板
  Widget _buildPlaceholderPanel(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
