import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';

import 'script_list_panel.dart';
import 'script_log_panel.dart';

/// 脚本控制台主面板
///
/// 包含：
/// - 左侧：脚本列表
/// - 右侧：脚本日志
class ScriptConsolePanel extends ConsumerStatefulWidget {
  const ScriptConsolePanel({super.key});

  @override
  ConsumerState<ScriptConsolePanel> createState() => _ScriptConsolePanelState();
}

class _ScriptConsolePanelState extends ConsumerState<ScriptConsolePanel> {
  late final MultiSplitViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MultiSplitViewController(
      areas: [
        Area(id: 'scripts', min: 200, size: 280),
        Area(id: 'logs', flex: 1, min: 200),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MultiSplitView(
      controller: _controller,
      axis: Axis.horizontal,
      dividerBuilder:
          (axis, index, resizable, dragging, highlighted, themeData) {
            final isHovered = dragging || highlighted;
            return Container(
              width: 4,
              color: isHovered
                  ? colorScheme.primary.withAlpha(128)
                  : colorScheme.outlineVariant.withAlpha(64),
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: const SizedBox.expand(),
              ),
            );
          },
      builder: (context, area) {
        if (area.id == 'scripts') {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: const ScriptListPanel(),
          );
        } else {
          return const ScriptLogPanel();
        }
      },
    );
  }
}
