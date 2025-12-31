import 'package:flex_com/features/update/domain/update_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

void main() {
  group('UpdateInfo', () {
    test('should parse version from GitHub JSON correctly', () {
      final json = {
        'tag_name': 'v1.2.3',
        'body': 'Release notes content',
        'published_at': '2024-01-15T10:30:00Z',
        'assets': [
          {
            'name': 'FlexCom-Setup-1.2.3.exe',
            'browser_download_url': 'https://example.com/download.exe',
            'size': 12345678,
          },
        ],
      };

      final updateInfo = UpdateInfo.fromGitHubJson(json);

      expect(updateInfo.version, equals(Version.parse('1.2.3')));
      expect(updateInfo.tagName, equals('v1.2.3'));
      expect(updateInfo.releaseNotes, equals('Release notes content'));
      expect(
        updateInfo.downloadUrl,
        equals('https://example.com/download.exe'),
      );
      expect(updateInfo.assetName, equals('FlexCom-Setup-1.2.3.exe'));
      expect(updateInfo.assetSize, equals(12345678));
      expect(updateInfo.hasDownload, isTrue);
    });

    test('should handle version without v prefix', () {
      final json = {
        'tag_name': '2.0.0',
        'body': '',
        'published_at': '2024-01-15T10:30:00Z',
        'assets': [],
      };

      final updateInfo = UpdateInfo.fromGitHubJson(json);

      expect(updateInfo.version, equals(Version.parse('2.0.0')));
      expect(updateInfo.tagName, equals('2.0.0'));
    });

    test('should handle missing assets', () {
      final json = {
        'tag_name': 'v1.0.0',
        'body': 'No assets release',
        'published_at': '2024-01-15T10:30:00Z',
        'assets': [],
      };

      final updateInfo = UpdateInfo.fromGitHubJson(json);

      expect(updateInfo.hasDownload, isFalse);
      expect(updateInfo.downloadUrl, isEmpty);
      expect(updateInfo.assetName, isEmpty);
      expect(updateInfo.assetSize, equals(0));
    });

    test('should find exe file from multiple assets', () {
      final json = {
        'tag_name': 'v1.0.0',
        'body': '',
        'published_at': '2024-01-15T10:30:00Z',
        'assets': [
          {
            'name': 'source.zip',
            'browser_download_url': 'https://example.com/source.zip',
            'size': 1000,
          },
          {
            'name': 'FlexCom-Setup.exe',
            'browser_download_url': 'https://example.com/setup.exe',
            'size': 50000000,
          },
          {
            'name': 'readme.md',
            'browser_download_url': 'https://example.com/readme.md',
            'size': 500,
          },
        ],
      };

      final updateInfo = UpdateInfo.fromGitHubJson(json);

      expect(updateInfo.assetName, equals('FlexCom-Setup.exe'));
      expect(updateInfo.downloadUrl, equals('https://example.com/setup.exe'));
      expect(updateInfo.assetSize, equals(50000000));
    });

    test('should handle null body', () {
      final json = {
        'tag_name': 'v1.0.0',
        'body': null,
        'published_at': '2024-01-15T10:30:00Z',
        'assets': [],
      };

      final updateInfo = UpdateInfo.fromGitHubJson(json);

      expect(updateInfo.releaseNotes, isEmpty);
    });
  });

  group('DownloadProgress', () {
    test('should calculate progress correctly', () {
      const progress = DownloadProgress(received: 50, total: 100);

      expect(progress.progress, equals(0.5));
      expect(progress.percentage, equals(50));
      expect(progress.isComplete, isFalse);
    });

    test('should handle complete download', () {
      const progress = DownloadProgress(received: 100, total: 100);

      expect(progress.progress, equals(1.0));
      expect(progress.percentage, equals(100));
      expect(progress.isComplete, isTrue);
    });

    test('should handle zero total', () {
      const progress = DownloadProgress(received: 50, total: 0);

      expect(progress.progress, equals(0.0));
      expect(progress.percentage, equals(0));
      expect(progress.isComplete, isFalse);
    });
  });

  group('UpdateCheckResult', () {
    test('UpdateAvailable should contain update info', () {
      final updateInfo = UpdateInfo(
        version: Version.parse('2.0.0'),
        tagName: 'v2.0.0',
        releaseNotes: 'New features',
        downloadUrl: 'https://example.com/download.exe',
        publishedAt: DateTime(2024, 1, 15),
        assetName: 'setup.exe',
        assetSize: 1000,
      );

      final result = UpdateAvailable(
        updateInfo: updateInfo,
        currentVersion: Version.parse('1.0.0'),
      );

      expect(result.updateInfo.version, equals(Version.parse('2.0.0')));
      expect(result.currentVersion, equals(Version.parse('1.0.0')));
    });

    test('UpToDate should contain current version', () {
      final result = UpToDate(currentVersion: Version.parse('1.0.0'));

      expect(result.currentVersion, equals(Version.parse('1.0.0')));
    });

    test('UpdateCheckFailed should contain error message', () {
      const result = UpdateCheckFailed(error: 'Network error');

      expect(result.error, equals('Network error'));
    });
  });

  group('DownloadState', () {
    test('DownloadIdle should be initial state', () {
      const state = DownloadIdle();
      expect(state, isA<DownloadState>());
    });

    test('DownloadInProgress should contain progress', () {
      const progress = DownloadProgress(received: 50, total: 100);
      const state = DownloadInProgress(
        progress: progress,
        filePath: '/tmp/file',
      );

      expect(state.progress.percentage, equals(50));
      expect(state.filePath, equals('/tmp/file'));
    });

    test('DownloadCompleted should contain file path', () {
      const state = DownloadCompleted(filePath: '/tmp/downloaded.exe');

      expect(state.filePath, equals('/tmp/downloaded.exe'));
    });

    test('DownloadFailed should contain error', () {
      const state = DownloadFailed(error: 'Download failed');

      expect(state.error, equals('Download failed'));
    });
  });
}
