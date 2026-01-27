import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../update/application/update_providers.dart';
import '../../update/domain/update_info.dart';
import '../../update/presentation/update_dialog.dart';
import '../application/config_providers.dart';

/// Settings page of the FlexCom application.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildThemeSection(context, ref),
          const SizedBox(height: 16),
          _buildAboutSection(context, ref),
        ],
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeModeAsync = ref.watch(themeModeProvider);
    final currentMode = themeModeAsync.value ?? ThemeMode.system;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '外观',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(
                  Icons.brightness_6,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('主题模式', style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildThemeModeSelector(context, ref, currentMode),
          ],
        ),
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
          icon: Icon(Icons.light_mode),
          label: Text('日间'),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          icon: Icon(Icons.dark_mode),
          label: Text('夜间'),
        ),
        ButtonSegment(
          value: ThemeMode.system,
          icon: Icon(Icons.settings_suggest),
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
    final currentVersion = ref.watch(currentVersionProvider);
    final updateCheckState = ref.watch(updateCheckerProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '关于',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // App name and version
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.usb,
                    color: theme.colorScheme.onPrimaryContainer,
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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      currentVersion.when(
                        data: (version) => Text(
                          '版本 $version',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        loading: () => Text(
                          '加载中...',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        error: (_, __) => Text(
                          '版本未知',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Update check button and status
            _buildUpdateCheckRow(context, ref, updateCheckState),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateCheckRow(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<UpdateCheckResult?> updateCheckState,
  ) {
    final theme = Theme.of(context);
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
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text('正在检查更新...', style: theme.textTheme.bodyMedium),
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
          Icon(Icons.refresh, size: 18),
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

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.new_releases,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '新版本 ${updateInfo.tagName}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
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

    return Row(
      children: [
        Icon(Icons.check_circle, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          '已是最新版本',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => checker.checkForUpdates(),
          child: const Text('重新检查'),
        ),
      ],
    );
  }

  Widget _buildCheckFailed(
    BuildContext context,
    UpdateChecker checker,
    String error,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.error_outline, size: 20, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '检查更新失败',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
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
          padding: const EdgeInsets.only(left: 28),
          child: Text(
            error,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
