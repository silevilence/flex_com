import 'dart:convert';

import 'package:flex_com/features/update/data/github_release_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pub_semver/pub_semver.dart';

void main() {
  group('GitHubReleaseService', () {
    late GitHubReleaseService service;

    final validReleaseJson = {
      'tag_name': 'v1.2.3',
      'body': 'Release notes',
      'published_at': '2024-01-15T10:30:00Z',
      'assets': [
        {
          'name': 'FlexCom-Setup.exe',
          'browser_download_url': 'https://github.com/download/setup.exe',
          'size': 12345678,
        },
      ],
    };

    test('should fetch latest release successfully', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('/releases/latest'));
        expect(
          request.headers['Accept'],
          equals('application/vnd.github.v3+json'),
        );
        return http.Response(jsonEncode(validReleaseJson), 200);
      });

      service = GitHubReleaseService(httpClient: mockClient);

      final result = await service.getLatestRelease();

      expect(result.version, equals(Version.parse('1.2.3')));
      expect(result.tagName, equals('v1.2.3'));
      expect(result.releaseNotes, equals('Release notes'));
    });

    test('should throw exception when no releases found', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"message": "Not Found"}', 404);
      });

      service = GitHubReleaseService(httpClient: mockClient);

      expect(
        () => service.getLatestRelease(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('No releases found'),
          ),
        ),
      );
    });

    test('should throw exception on HTTP error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      service = GitHubReleaseService(httpClient: mockClient);

      expect(
        () => service.getLatestRelease(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('HTTP 500'),
          ),
        ),
      );
    });

    test('should fetch all releases successfully', () async {
      final releasesJson = [
        validReleaseJson,
        {
          'tag_name': 'v1.2.2',
          'body': 'Previous release',
          'published_at': '2024-01-10T10:30:00Z',
          'assets': [],
        },
      ];

      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('/releases'));
        return http.Response(jsonEncode(releasesJson), 200);
      });

      service = GitHubReleaseService(httpClient: mockClient);

      final results = await service.getAllReleases();

      expect(results.length, equals(2));
      expect(results[0].version, equals(Version.parse('1.2.3')));
      expect(results[1].version, equals(Version.parse('1.2.2')));
    });

    group('isNewerVersion', () {
      setUp(() {
        service = GitHubReleaseService();
      });

      test('should return true when remote is newer', () {
        final remote = Version.parse('2.0.0');
        final local = Version.parse('1.0.0');

        expect(service.isNewerVersion(remote, local), isTrue);
      });

      test('should return false when remote is same', () {
        final remote = Version.parse('1.0.0');
        final local = Version.parse('1.0.0');

        expect(service.isNewerVersion(remote, local), isFalse);
      });

      test('should return false when remote is older', () {
        final remote = Version.parse('1.0.0');
        final local = Version.parse('2.0.0');

        expect(service.isNewerVersion(remote, local), isFalse);
      });

      test('should handle patch version differences', () {
        final remote = Version.parse('1.0.1');
        final local = Version.parse('1.0.0');

        expect(service.isNewerVersion(remote, local), isTrue);
      });

      test('should handle pre-release versions', () {
        final remote = Version.parse('2.0.0-beta');
        final local = Version.parse('1.0.0');

        expect(service.isNewerVersion(remote, local), isTrue);
      });
    });

    test('should use correct repository in URL', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), contains('silevilence/flex_com'));
        return http.Response(jsonEncode(validReleaseJson), 200);
      });

      service = GitHubReleaseService(
        owner: 'silevilence',
        repo: 'flex_com',
        httpClient: mockClient,
      );

      await service.getLatestRelease();
    });
  });
}
