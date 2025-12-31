import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import '../domain/update_info.dart';
import 'github_release_service.dart';
import 'update_download_service.dart';

/// Unified service for managing application updates.
///
/// This service coordinates version checking, downloading, and installation.
class UpdateService {
  UpdateService({
    GitHubReleaseService? releaseService,
    UpdateDownloadService? downloadService,
  }) : _releaseService = releaseService ?? GitHubReleaseService(),
       _downloadService = downloadService ?? UpdateDownloadService();

  final GitHubReleaseService _releaseService;
  final UpdateDownloadService _downloadService;

  PackageInfo? _cachedPackageInfo;

  /// Gets the current application version.
  Future<Version> getCurrentVersion() async {
    _cachedPackageInfo ??= await PackageInfo.fromPlatform();
    return Version.parse(_cachedPackageInfo!.version);
  }

  /// Gets the current application version as a string.
  Future<String> getCurrentVersionString() async {
    _cachedPackageInfo ??= await PackageInfo.fromPlatform();
    return _cachedPackageInfo!.version;
  }

  /// Gets the full application info.
  Future<PackageInfo> getPackageInfo() async {
    _cachedPackageInfo ??= await PackageInfo.fromPlatform();
    return _cachedPackageInfo!;
  }

  /// Checks for available updates.
  ///
  /// Returns an [UpdateCheckResult] indicating whether an update is available,
  /// if the app is up to date, or if the check failed.
  Future<UpdateCheckResult> checkForUpdates() async {
    try {
      final currentVersion = await getCurrentVersion();
      final latestRelease = await _releaseService.getLatestRelease();

      if (_releaseService.isNewerVersion(
        latestRelease.version,
        currentVersion,
      )) {
        return UpdateAvailable(
          updateInfo: latestRelease,
          currentVersion: currentVersion,
        );
      } else {
        return UpToDate(currentVersion: currentVersion);
      }
    } catch (e) {
      return UpdateCheckFailed(error: e.toString());
    }
  }

  /// Downloads an update.
  ///
  /// [updateInfo] - The update to download.
  /// [onProgress] - Callback for progress updates.
  ///
  /// Returns the path to the downloaded file.
  Future<String> downloadUpdate(
    UpdateInfo updateInfo, {
    void Function(DownloadProgress progress)? onProgress,
  }) {
    return _downloadService.downloadUpdate(updateInfo, onProgress: onProgress);
  }

  /// Cancels the current download.
  void cancelDownload() {
    _downloadService.cancelDownload();
  }

  /// Opens the downloaded installer file.
  ///
  /// [filePath] - Path to the installer file.
  ///
  /// Returns true if the installer was opened successfully.
  Future<bool> openInstaller(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }

      final result = await OpenFilex.open(filePath);
      return result.type == ResultType.done;
    } catch (_) {
      return false;
    }
  }

  /// Opens the installer and exits the application.
  ///
  /// This method opens the installer and then exits the app to avoid
  /// file locking issues during the update process.
  Future<void> installAndExit(String filePath) async {
    final opened = await openInstaller(filePath);
    if (opened) {
      // Give the installer time to start before exiting
      await Future.delayed(const Duration(milliseconds: 500));
      exit(0);
    }
  }

  /// Cleans up old downloaded update files.
  Future<void> cleanupOldDownloads() {
    return _downloadService.cleanupOldDownloads();
  }

  /// Disposes resources.
  void dispose() {
    _releaseService.dispose();
    _downloadService.dispose();
  }
}
