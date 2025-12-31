import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/update_providers.dart';
import '../domain/update_info.dart';

/// Dialog for displaying update information and download progress.
class UpdateDialog extends ConsumerWidget {
  const UpdateDialog({
    super.key,
    required this.updateInfo,
    required this.currentVersion,
  });

  final UpdateInfo updateInfo;
  final String currentVersion;

  static Future<void> show(
    BuildContext context, {
    required UpdateInfo updateInfo,
    required String currentVersion,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          UpdateDialog(updateInfo: updateInfo, currentVersion: currentVersion),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadState = ref.watch(updateDownloaderProvider);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.system_update, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('发现新版本'),
        ],
      ),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Version info
            _buildVersionInfo(context),
            const Divider(height: 24),

            // Release notes
            Text(
              '更新内容:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: SelectableText(
                  updateInfo.releaseNotes.isEmpty
                      ? '暂无更新说明'
                      : updateInfo.releaseNotes,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),

            // Download progress
            if (downloadState is DownloadInProgress) ...[
              const SizedBox(height: 16),
              _buildDownloadProgress(context, downloadState),
            ],

            // Error message
            if (downloadState is DownloadFailed) ...[
              const SizedBox(height: 16),
              _buildErrorMessage(context, downloadState),
            ],
          ],
        ),
      ),
      actions: _buildActions(context, ref, downloadState),
    );
  }

  Widget _buildVersionInfo(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '当前版本',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text('v$currentVersion', style: theme.textTheme.titleMedium),
            ],
          ),
        ),
        Icon(Icons.arrow_forward, color: theme.colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '最新版本',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                updateInfo.tagName,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadProgress(
    BuildContext context,
    DownloadInProgress state,
  ) {
    final theme = Theme.of(context);
    final progress = state.progress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('下载中...', style: theme.textTheme.bodyMedium),
            Text(
              '${progress.percentage}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress.progress,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        Text(
          _formatBytes(progress.received, progress.total),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(BuildContext context, DownloadFailed state) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '下载失败: ${state.error}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions(
    BuildContext context,
    WidgetRef ref,
    DownloadState downloadState,
  ) {
    final downloader = ref.read(updateDownloaderProvider.notifier);

    // Download completed - show install button
    if (downloadState is DownloadCompleted) {
      return [
        TextButton(
          onPressed: () {
            downloader.reset();
            Navigator.of(context).pop();
          },
          child: const Text('稍后'),
        ),
        FilledButton.icon(
          onPressed: () {
            downloader.installAndExit(downloadState.filePath);
          },
          icon: const Icon(Icons.install_desktop),
          label: const Text('立即安装'),
        ),
      ];
    }

    // Download in progress - show cancel button
    if (downloadState is DownloadInProgress) {
      return [
        TextButton(
          onPressed: () {
            downloader.cancelDownload();
          },
          child: const Text('取消下载'),
        ),
      ];
    }

    // Default or error state - show download/retry button
    return [
      TextButton(
        onPressed: () {
          downloader.reset();
          Navigator.of(context).pop();
        },
        child: const Text('以后再说'),
      ),
      if (updateInfo.hasDownload)
        FilledButton.icon(
          onPressed: () {
            downloader.downloadUpdate(updateInfo);
          },
          icon: const Icon(Icons.download),
          label: Text(downloadState is DownloadFailed ? '重试下载' : '下载更新'),
        )
      else
        FilledButton.icon(
          onPressed: () {
            // Open GitHub releases page in browser
            // This is a fallback when no .exe is available
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.open_in_new),
          label: const Text('查看发布页'),
        ),
    ];
  }

  String _formatBytes(int received, int total) {
    String formatSize(int bytes) {
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }

    return '${formatSize(received)} / ${formatSize(total)}';
  }
}
