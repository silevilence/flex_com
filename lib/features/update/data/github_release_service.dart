import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pub_semver/pub_semver.dart';

import '../domain/update_info.dart';

/// Service for interacting with GitHub releases API.
class GitHubReleaseService {
  GitHubReleaseService({
    this.owner = 'silevilence',
    this.repo = 'flex_com',
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String owner;
  final String repo;
  final http.Client _httpClient;

  /// Base URL for GitHub API.
  String get _baseUrl => 'https://api.github.com/repos/$owner/$repo';

  /// Gets the latest release from GitHub.
  ///
  /// Returns [UpdateInfo] if successful, throws an exception otherwise.
  Future<UpdateInfo> getLatestRelease() async {
    final url = Uri.parse('$_baseUrl/releases/latest');

    try {
      final response = await _httpClient.get(
        url,
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'FlexCom-Update-Checker',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return UpdateInfo.fromGitHubJson(json);
      } else if (response.statusCode == 404) {
        throw Exception('No releases found for this repository');
      } else {
        throw Exception(
          'Failed to fetch latest release: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Gets all releases from GitHub.
  ///
  /// Returns a list of [UpdateInfo] for all releases.
  Future<List<UpdateInfo>> getAllReleases({int perPage = 10}) async {
    final url = Uri.parse('$_baseUrl/releases?per_page=$perPage');

    try {
      final response = await _httpClient.get(
        url,
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'FlexCom-Update-Checker',
        },
      );

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body) as List<dynamic>;
        return jsonList
            .map(
              (json) => UpdateInfo.fromGitHubJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception(
          'Failed to fetch releases: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Compares two versions and returns true if remote is newer than local.
  bool isNewerVersion(Version remote, Version local) {
    return remote > local;
  }

  /// Disposes the HTTP client.
  void dispose() {
    _httpClient.close();
  }
}
