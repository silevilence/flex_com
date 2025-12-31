import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/update_info.dart';

/// Service for downloading update files with progress tracking.
class UpdateDownloadService {
  UpdateDownloadService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  CancelToken? _cancelToken;

  /// Downloads the update file to a temporary directory.
  ///
  /// [updateInfo] - The update information containing download URL.
  /// [onProgress] - Callback for download progress updates.
  ///
  /// Returns the path to the downloaded file.
  Future<String> downloadUpdate(
    UpdateInfo updateInfo, {
    void Function(DownloadProgress progress)? onProgress,
  }) async {
    if (!updateInfo.hasDownload) {
      throw Exception('No download URL available for this update');
    }

    _cancelToken = CancelToken();

    // Get the download directory
    final downloadDir = await _getDownloadDirectory();
    final filePath =
        '$downloadDir${Platform.pathSeparator}${updateInfo.assetName}';

    // Check if file already exists and matches expected size
    final existingFile = File(filePath);
    if (await existingFile.exists()) {
      final existingSize = await existingFile.length();
      if (existingSize == updateInfo.assetSize) {
        // File already downloaded and complete
        onProgress?.call(
          DownloadProgress(received: existingSize, total: existingSize),
        );
        return filePath;
      } else {
        // Incomplete or corrupted file, delete it
        await existingFile.delete();
      }
    }

    try {
      await _dio.download(
        updateInfo.downloadUrl,
        filePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          onProgress?.call(
            DownloadProgress(
              received: received,
              total: total > 0 ? total : updateInfo.assetSize,
            ),
          );
        },
        options: Options(headers: {'User-Agent': 'FlexCom-Update-Downloader'}),
      );

      return filePath;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        // Clean up partial download
        final partialFile = File(filePath);
        if (await partialFile.exists()) {
          await partialFile.delete();
        }
        throw Exception('Download cancelled');
      }
      throw Exception('Download failed: ${e.message}');
    } catch (e) {
      throw Exception('Download failed: $e');
    }
  }

  /// Cancels the current download if any.
  void cancelDownload() {
    _cancelToken?.cancel('User cancelled download');
    _cancelToken = null;
  }

  /// Gets the directory for storing downloaded updates.
  Future<String> _getDownloadDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final updateDir = Directory(
      '${tempDir.path}${Platform.pathSeparator}flex_com_updates',
    );

    if (!await updateDir.exists()) {
      await updateDir.create(recursive: true);
    }

    return updateDir.path;
  }

  /// Cleans up old downloaded update files.
  Future<void> cleanupOldDownloads() async {
    try {
      final downloadDir = await _getDownloadDirectory();
      final dir = Directory(downloadDir);

      if (await dir.exists()) {
        final files = await dir.list().toList();
        for (final file in files) {
          if (file is File) {
            await file.delete();
          }
        }
      }
    } catch (_) {
      // Ignore cleanup errors
    }
  }

  /// Disposes resources.
  void dispose() {
    cancelDownload();
    _dio.close();
  }
}
