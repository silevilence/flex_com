import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/github_release_service.dart';
import '../data/update_download_service.dart';
import '../data/update_service.dart';
import '../domain/update_info.dart';

part 'update_providers.g.dart';

/// Provider for the GitHub release service.
@Riverpod(keepAlive: true)
GitHubReleaseService gitHubReleaseService(Ref ref) {
  final service = GitHubReleaseService();
  ref.onDispose(() => service.dispose());
  return service;
}

/// Provider for the update download service.
@Riverpod(keepAlive: true)
UpdateDownloadService updateDownloadService(Ref ref) {
  final service = UpdateDownloadService();
  ref.onDispose(() => service.dispose());
  return service;
}

/// Provider for the main update service.
@Riverpod(keepAlive: true)
UpdateService updateService(Ref ref) {
  final releaseService = ref.watch(gitHubReleaseServiceProvider);
  final downloadService = ref.watch(updateDownloadServiceProvider);
  final service = UpdateService(
    releaseService: releaseService,
    downloadService: downloadService,
  );
  ref.onDispose(() => service.dispose());
  return service;
}

/// Provider for the current app version string.
@riverpod
Future<String> currentVersion(Ref ref) async {
  final service = ref.watch(updateServiceProvider);
  return service.getCurrentVersionString();
}

/// Notifier for managing update check state.
@riverpod
class UpdateChecker extends _$UpdateChecker {
  @override
  AsyncValue<UpdateCheckResult?> build() {
    return const AsyncValue.data(null);
  }

  /// Checks for available updates.
  Future<void> checkForUpdates() async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(updateServiceProvider);
      final result = await service.checkForUpdates();
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Resets the update check state.
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Notifier for managing download state.
@riverpod
class UpdateDownloader extends _$UpdateDownloader {
  @override
  DownloadState build() {
    return const DownloadIdle();
  }

  /// Downloads the specified update.
  Future<void> downloadUpdate(UpdateInfo updateInfo) async {
    if (state is DownloadInProgress) {
      return; // Already downloading
    }

    state = DownloadInProgress(
      progress: const DownloadProgress(received: 0, total: 0),
      filePath: '',
    );

    try {
      final service = ref.read(updateServiceProvider);
      final filePath = await service.downloadUpdate(
        updateInfo,
        onProgress: (progress) {
          state = DownloadInProgress(progress: progress, filePath: '');
        },
      );
      state = DownloadCompleted(filePath: filePath);
    } catch (e) {
      if (e.toString().contains('cancelled')) {
        state = const DownloadCancelled();
      } else {
        state = DownloadFailed(error: e.toString());
      }
    }
  }

  /// Cancels the current download.
  void cancelDownload() {
    final service = ref.read(updateServiceProvider);
    service.cancelDownload();
    state = const DownloadCancelled();
  }

  /// Resets the download state.
  void reset() {
    state = const DownloadIdle();
  }

  /// Opens the installer and exits the app.
  Future<void> installAndExit(String filePath) async {
    final service = ref.read(updateServiceProvider);
    await service.installAndExit(filePath);
  }
}
