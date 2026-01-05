import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/auto_reply_providers.dart';
import '../../domain/auto_reply_config.dart';
import '../../domain/auto_reply_mode.dart';
import 'match_reply_rule_list.dart';
import 'sequential_reply_frame_list.dart';

/// 辅助方法：安全获取 AsyncValue 的值
T? _getValueOrNull<T>(AsyncValue<T> asyncValue) {
  return asyncValue.when(
    data: (data) => data,
    loading: () => null,
    error: (_, __) => null,
  );
}

/// 自动回复面板
///
/// 包含全局设置和两种回复模式的切换
class AutoReplyPanel extends ConsumerStatefulWidget {
  const AutoReplyPanel({super.key});

  @override
  ConsumerState<AutoReplyPanel> createState() => _AutoReplyPanelState();
}

class _AutoReplyPanelState extends ConsumerState<AutoReplyPanel> {
  late TextEditingController _delayController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _delayController = TextEditingController();
  }

  @override
  void dispose() {
    _delayController.dispose();
    super.dispose();
  }

  void _initializeControllerIfNeeded(AutoReplyConfig config) {
    if (!_isInitialized) {
      _delayController.text = config.globalDelayMs.toString();
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final globalConfigAsync = ref.watch(autoReplyConfigProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 标题栏
          _buildHeader(context, globalConfigAsync),
          const Divider(height: 1),
          // 内容区
          Expanded(
            child: globalConfigAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('加载失败: $error')),
              data: (config) {
                _initializeControllerIfNeeded(config);
                return _buildContent(context, config);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AsyncValue<AutoReplyConfig> globalConfigAsync,
  ) {
    final theme = Theme.of(context);
    final config = _getValueOrNull(globalConfigAsync);
    final isEnabled = config?.enabled ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Text('自动回复', style: theme.textTheme.titleMedium),
          const SizedBox(width: 8),
          // 状态标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isEnabled
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isEnabled ? '运行中' : '已停止',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isEnabled
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const Spacer(),
          // 总开关
          Switch(
            value: isEnabled,
            onChanged: (_) {
              ref.read(autoReplyConfigProvider.notifier).toggleEnabled();
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AutoReplyConfig config) {
    return Column(
      children: [
        // 全局设置区
        _buildGlobalSettings(context, config),
        const Divider(height: 1),
        // 模式切换标签
        _buildModeTabs(context, config),
        // 模式内容
        Expanded(child: _buildModeContent(context, config)),
      ],
    );
  }

  Widget _buildGlobalSettings(BuildContext context, AutoReplyConfig config) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // 延迟设置
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('回复延迟', style: theme.textTheme.bodySmall),
              const SizedBox(width: 8),
              SizedBox(
                width: 72,
                height: 32,
                child: TextField(
                  controller: _delayController,
                  decoration: const InputDecoration(
                    suffixText: 'ms',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  style: theme.textTheme.bodySmall,
                  onSubmitted: (value) {
                    final delay = int.tryParse(value) ?? 0;
                    ref
                        .read(autoReplyConfigProvider.notifier)
                        .setGlobalDelay(delay);
                  },
                  onChanged: (value) {
                    // 实时保存延迟值（用户输入时）
                    final delay = int.tryParse(value);
                    if (delay != null) {
                      ref
                          .read(autoReplyConfigProvider.notifier)
                          .setGlobalDelay(delay);
                    }
                  },
                ),
              ),
            ],
          ),
          // 模式选择
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('模式:', style: theme.textTheme.bodySmall),
              const SizedBox(width: 8),
              SegmentedButton<AutoReplyMode>(
                segments: [
                  ButtonSegment(
                    value: AutoReplyMode.matchReply,
                    label: Text(
                      AutoReplyMode.matchReply.displayName,
                      style: theme.textTheme.labelSmall,
                    ),
                    icon: const Icon(Icons.rule, size: 16),
                  ),
                  ButtonSegment(
                    value: AutoReplyMode.sequentialReply,
                    label: Text(
                      AutoReplyMode.sequentialReply.displayName,
                      style: theme.textTheme.labelSmall,
                    ),
                    icon: const Icon(Icons.playlist_play, size: 16),
                  ),
                ],
                selected: {config.activeMode},
                onSelectionChanged: (modes) {
                  ref
                      .read(autoReplyConfigProvider.notifier)
                      .setActiveMode(modes.first);
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeTabs(BuildContext context, AutoReplyConfig config) {
    final theme = Theme.of(context);
    final activeMode = config.activeMode;

    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Icon(
            activeMode == AutoReplyMode.matchReply
                ? Icons.rule
                : Icons.playlist_play,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            activeMode.displayName,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              activeMode.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeContent(BuildContext context, AutoReplyConfig config) {
    final activeMode = config.activeMode;

    switch (activeMode) {
      case AutoReplyMode.matchReply:
        return const MatchReplyRuleList();
      case AutoReplyMode.sequentialReply:
        return const SequentialReplyFrameList();
      case AutoReplyMode.scriptReply:
        // 脚本回复模式在 Hook 管理面板中配置
        return const Center(child: Text('脚本回复模式请在脚本管理面板中配置 Hook'));
    }
  }
}
