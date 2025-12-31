import 'package:equatable/equatable.dart';
import 'package:pub_semver/pub_semver.dart';

/// Represents information about an available update from GitHub releases.
class UpdateInfo extends Equatable {
  const UpdateInfo({
    required this.version,
    required this.tagName,
    required this.releaseNotes,
    required this.downloadUrl,
    required this.publishedAt,
    required this.assetName,
    required this.assetSize,
  });

  /// The semantic version of the release.
  final Version version;

  /// The tag name (e.g., "v1.0.0").
  final String tagName;

  /// The release notes/changelog (body of the release).
  final String releaseNotes;

  /// Direct download URL for the Windows installer.
  final String downloadUrl;

  /// When the release was published.
  final DateTime publishedAt;

  /// The name of the asset file.
  final String assetName;

  /// The size of the asset in bytes.
  final int assetSize;

  /// Creates an UpdateInfo from GitHub API response JSON.
  factory UpdateInfo.fromGitHubJson(Map<String, dynamic> json) {
    final tagName = json['tag_name'] as String;
    // Remove leading 'v' or 'V' if present for version parsing
    final versionString = tagName.startsWith('v') || tagName.startsWith('V')
        ? tagName.substring(1)
        : tagName;

    // Find the Windows installer asset (.exe)
    final assets = json['assets'] as List<dynamic>? ?? [];
    Map<String, dynamic>? windowsAsset;

    for (final asset in assets) {
      final assetMap = asset as Map<String, dynamic>;
      final name = assetMap['name'] as String? ?? '';
      if (name.toLowerCase().endsWith('.exe')) {
        windowsAsset = assetMap;
        break;
      }
    }

    return UpdateInfo(
      version: Version.parse(versionString),
      tagName: tagName,
      releaseNotes: json['body'] as String? ?? '',
      downloadUrl: windowsAsset?['browser_download_url'] as String? ?? '',
      publishedAt:
          DateTime.tryParse(json['published_at'] as String? ?? '') ??
          DateTime.now(),
      assetName: windowsAsset?['name'] as String? ?? '',
      assetSize: windowsAsset?['size'] as int? ?? 0,
    );
  }

  /// Whether a download is available for this update.
  bool get hasDownload => downloadUrl.isNotEmpty;

  @override
  List<Object?> get props => [
    version,
    tagName,
    releaseNotes,
    downloadUrl,
    publishedAt,
    assetName,
    assetSize,
  ];
}

/// Represents the result of checking for updates.
sealed class UpdateCheckResult extends Equatable {
  const UpdateCheckResult();
}

/// Update is available.
class UpdateAvailable extends UpdateCheckResult {
  const UpdateAvailable({
    required this.updateInfo,
    required this.currentVersion,
  });

  final UpdateInfo updateInfo;
  final Version currentVersion;

  @override
  List<Object?> get props => [updateInfo, currentVersion];
}

/// Already up to date.
class UpToDate extends UpdateCheckResult {
  const UpToDate({required this.currentVersion});

  final Version currentVersion;

  @override
  List<Object?> get props => [currentVersion];
}

/// Failed to check for updates.
class UpdateCheckFailed extends UpdateCheckResult {
  const UpdateCheckFailed({required this.error});

  final String error;

  @override
  List<Object?> get props => [error];
}

/// Represents download progress.
class DownloadProgress extends Equatable {
  const DownloadProgress({required this.received, required this.total});

  final int received;
  final int total;

  /// Progress as a value between 0.0 and 1.0.
  double get progress => total > 0 ? received / total : 0.0;

  /// Progress as a percentage (0-100).
  int get percentage => (progress * 100).round();

  /// Whether the download is complete.
  bool get isComplete => total > 0 && received >= total;

  @override
  List<Object?> get props => [received, total];
}

/// Represents the state of an update download.
sealed class DownloadState extends Equatable {
  const DownloadState();
}

/// Download has not started.
class DownloadIdle extends DownloadState {
  const DownloadIdle();

  @override
  List<Object?> get props => [];
}

/// Download is in progress.
class DownloadInProgress extends DownloadState {
  const DownloadInProgress({required this.progress, required this.filePath});

  final DownloadProgress progress;
  final String filePath;

  @override
  List<Object?> get props => [progress, filePath];
}

/// Download completed successfully.
class DownloadCompleted extends DownloadState {
  const DownloadCompleted({required this.filePath});

  final String filePath;

  @override
  List<Object?> get props => [filePath];
}

/// Download failed.
class DownloadFailed extends DownloadState {
  const DownloadFailed({required this.error});

  final String error;

  @override
  List<Object?> get props => [error];
}

/// Download was cancelled.
class DownloadCancelled extends DownloadState {
  const DownloadCancelled();

  @override
  List<Object?> get props => [];
}
