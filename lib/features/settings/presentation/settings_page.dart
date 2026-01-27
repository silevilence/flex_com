import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../update/application/update_providers.dart';
import '../../update/domain/update_info.dart';
import '../../update/presentation/update_dialog.dart';
import '../application/config_providers.dart';

/// Settings page of the FlexCom application.
///
/// Design: Clean cards with subtle borders, professional spacing.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: '返回',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildThemeSection(context, ref),
          const SizedBox(height: 20),
          _buildAboutSection(context, ref),
        ],
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeModeAsync = ref.watch(themeModeProvider);
    final currentMode = themeModeAsync.value ?? ThemeMode.system;

    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(icon: Icons.palette_outlined, title: '外观'),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.brightness_6_rounded,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text('主题模式', style: theme.textTheme.bodyMedium)),
            ],
          ),
          const SizedBox(height: 12),
          _buildThemeModeSelector(context, ref, currentMode),
        ],
      ),
    );
  }

  Widget _buildThemeModeSelector(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
  ) {
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(
          value: ThemeMode.light,
          icon: Icon(Icons.light_mode_rounded, size: 18),
          label: Text('日间'),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          icon: Icon(Icons.dark_mode_rounded, size: 18),
          label: Text('夜间'),
        ),
        ButtonSegment(
          value: ThemeMode.system,
          icon: Icon(Icons.settings_suggest_rounded, size: 18),
          label: Text('跟随系统'),
        ),
      ],
      selected: {currentMode},
      onSelectionChanged: (Set<ThemeMode> selection) {
        if (selection.isNotEmpty) {
          ref.read(themeModeProvider.notifier).setThemeMode(selection.first);
        }
      },
    );
  }

  Widget _buildAboutSection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentVersion = ref.watch(currentVersionProvider);
    final updateCheckState = ref.watch(updateCheckerProvider);

    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(icon: Icons.info_outline, title: '关于'),
          const SizedBox(height: 16),

          // App name and version - refined card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                // App icon with gradient background
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.usb_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FlexCom',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      currentVersion.when(
                        data: (version) => Text(
                          '版本 $version',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        loading: () => Text(
                          '加载中...',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        error: (_, __) => Text(
                          '版本未知',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Update check button and status
          _buildUpdateCheckRow(context, ref, updateCheckState),
        ],
      ),
    );
  }

  Widget _buildUpdateCheckRow(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<UpdateCheckResult?> updateCheckState,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final checker = ref.read(updateCheckerProvider.notifier);

    return updateCheckState.when(
      data: (result) {
        if (result == null) {
          // Initial state - show check button
          return _buildCheckButton(context, checker);
        }

        return switch (result) {
          UpdateAvailable(:final updateInfo, :final currentVersion) =>
            _buildUpdateAvailable(
              context,
              ref,
              updateInfo,
              currentVersion.toString(),
            ),
          UpToDate() => _buildUpToDate(context, checker),
          UpdateCheckFailed(:final error) => _buildCheckFailed(
            context,
            checker,
            error,
          ),
        };
      },
      loading: () => Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '正在检查更新...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      error: (error, _) =>
          _buildCheckFailed(context, checker, error.toString()),
    );
  }

  Widget _buildCheckButton(BuildContext context, UpdateChecker checker) {
    return FilledButton.tonal(
      onPressed: () => checker.checkForUpdates(),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.refresh_rounded, size: 18),
          SizedBox(width: 8),
          Text('检查更新'),
        ],
      ),
    );
  }

  Widget _buildUpdateAvailable(
    BuildContext context,
    WidgetRef ref,
    UpdateInfo updateInfo,
    String currentVersion,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.new_releases_rounded,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                '新版本 ${updateInfo.tagName}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: () {
            UpdateDialog.show(
              context,
              updateInfo: updateInfo,
              currentVersion: currentVersion,
            );
          },
          child: const Text('查看详情'),
        ),
      ],
    );
  }

  Widget _buildUpToDate(BuildContext context, UpdateChecker checker) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, size: 18, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            '已是最新版本',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          TextButton.icon(
            onPressed: () => checker.checkForUpdates(),
            icon: Icon(
              Icons.refresh_rounded,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            label: Text(
              '重新检查',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckFailed(
    BuildContext context,
    UpdateChecker checker,
    String error,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 18,
                color: colorScheme.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '检查更新失败',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => checker.checkForUpdates(),
                child: const Text('重试'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 26, top: 4),
            child: Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PRIVATE COMPONENTS
// =============================================================================

/// Unified card wrapper for settings sections.
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: child,
    );
  }
}

/// Section header with icon and title.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
