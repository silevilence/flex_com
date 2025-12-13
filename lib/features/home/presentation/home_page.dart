import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auto_reply/application/auto_reply_engine.dart';
import '../../layout/presentation/widgets/activity_bar.dart';
import '../../layout/presentation/widgets/multi_zone_layout.dart';
import '../../serial/presentation/widgets/status_bar.dart';

/// Home page of the FlexCom application
///
/// 使用 VS Code 风格的多区域布局：
/// - 左侧 Activity Bar（48px 宽度，始终可见）
/// - 中央 MultiSplitView（支持左/中/右/底四区域）
/// - 底部状态栏
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 初始化自动回复引擎（读取一次以激活 Provider）
    ref.watch(autoReplyEngineProvider);

    return Scaffold(
      body: Column(
        children: [
          // 主内容区域
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Activity Bar - 始终可见
                const ActivityBar(),
                // 分隔线
                Container(
                  width: 1,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                // 多区域布局
                const Expanded(child: MultiZoneLayout()),
              ],
            ),
          ),
          // 状态栏
          const StatusBar(),
        ],
      ),
    );
  }
}
