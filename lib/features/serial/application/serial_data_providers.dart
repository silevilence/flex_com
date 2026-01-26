import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../connection/application/connection_providers.dart';
import '../../frame_parser/application/parser_providers.dart';
import '../../scripting/application/hook_service.dart';
import '../../visualization/application/visualization_providers.dart';
import '../domain/serial_data_entry.dart';
import 'display_settings_providers.dart';

part 'serial_data_providers.g.dart';

/// Maximum number of entries to keep in memory.
const int _maxEntries = 1000;

/// Notifier that manages the list of serial data entries.
///
/// This collects both sent and received data into a single log.
@Riverpod(keepAlive: true)
class SerialDataLog extends _$SerialDataLog {
  StreamSubscription<Uint8List>? _subscription;

  @override
  List<SerialDataEntry> build() {
    // Listen to connection state changes (not watch, to avoid rebuild)
    ref.listen<UnifiedConnectionState>(unifiedConnectionProvider, (
      previous,
      next,
    ) {
      _handleConnectionChange(previous, next);
    }, fireImmediately: true);

    ref.onDispose(() {
      _subscription?.cancel();
      _subscription = null;
    });

    return [];
  }

  void _handleConnectionChange(
    UnifiedConnectionState? previous,
    UnifiedConnectionState next,
  ) {
    final wasConnected = previous?.isConnected ?? false;
    final isConnected = next.isConnected;

    // Only re-subscribe when connection state actually changes
    if (wasConnected != isConnected) {
      _subscription?.cancel();
      _subscription = null;

      if (isConnected) {
        final notifier = ref.read(unifiedConnectionProvider.notifier);
        final stream = notifier.dataStream;
        if (stream != null) {
          _subscription = stream.listen(
            (data) {
              // IMPORTANT: Copy data immediately before async processing
              // libserialport may reuse/free the buffer after callback returns
              final dataCopy = Uint8List.fromList(data);
              // Process data synchronously first, then through hook
              _processAndAddEntry(dataCopy);
            },
            onError: (Object error) {
              // Ignore stream errors to prevent crash
            },
          );
        }
      }
    }
  }

  /// Process received data and add to log
  void _processAndAddEntry(Uint8List data) {
    // Try to process through Rx Hook if available
    _processRxHookAsync(data);
  }

  /// Process data through Rx Hook asynchronously
  Future<void> _processRxHookAsync(Uint8List data) async {
    try {
      final hookService = ref.read(hookServiceProvider.notifier);
      final processedData = await hookService.processRxData(data);
      _addEntry(SerialDataEntry.received(processedData));

      // 协议解析并推送到波形图（使用同步缓冲方法）
      _processFrameParserSync(processedData);
    } catch (e) {
      // Fallback: add original data if hook processing fails
      _addEntry(SerialDataEntry.received(data));
    }
  }

  /// 协议解析并推送解析结果到波形图（同步缓冲，不阻塞）
  void _processFrameParserSync(Uint8List data) {
    try {
      // 直接读取 parser 状态
      final parserState = ref.read(parserProvider);
      final parserData = parserState.value;
      if (parserData == null ||
          !parserData.isEnabled ||
          parserData.activeConfig == null) {
        debugPrint('[Oscilloscope] Parser 未启用或无配置');
        return;
      }

      // 直接使用解析器解析
      final parser = ref.read(parserRegistryProvider).defaultParser;
      final parsedFrame = parser.parse(data, config: parserData.activeConfig);

      debugPrint(
        '[Oscilloscope] 解析结果: isValid=${parsedFrame.isValid}, fields=${parsedFrame.fields.length}',
      );

      // 如果解析成功，使用同步缓冲方法推送数据到波形图
      if (parsedFrame.isValid) {
        final oscilloscope = ref.read(oscilloscopeProvider.notifier);
        oscilloscope.addDataFromParsedFrameBuffered(parsedFrame);
      }
    } catch (e) {
      debugPrint('[Oscilloscope] 解析异常: $e');
    }
  }

  void _addEntry(SerialDataEntry entry) {
    // Update byte counter
    if (entry.direction == DataDirection.received) {
      ref.read(byteCounterProvider.notifier).addRxBytes(entry.data.length);
    } else {
      ref.read(byteCounterProvider.notifier).addTxBytes(entry.data.length);
    }

    final newState = [...state, entry];
    // Limit entries to prevent memory issues
    if (newState.length > _maxEntries) {
      state = newState.sublist(newState.length - _maxEntries);
    } else {
      state = newState;
    }
  }

  /// Adds a sent data entry to the log.
  /// Note: TX Hook processing should be done BEFORE calling this method,
  /// as the actual send happens before logging.
  void addSentData(Uint8List data) {
    _addEntry(SerialDataEntry.sent(data));
  }

  /// Clears all entries from the log.
  void clear() {
    state = [];
  }
}

/// Notifier for the data display mode (Hex or ASCII).
@Riverpod(keepAlive: true)
class DataDisplayModeNotifier extends _$DataDisplayModeNotifier {
  @override
  DataDisplayMode build() {
    return DataDisplayMode.hex;
  }

  /// Toggles between Hex and ASCII display modes.
  void toggle() {
    state = state == DataDisplayMode.hex
        ? DataDisplayMode.ascii
        : DataDisplayMode.hex;
  }

  /// Sets the display mode explicitly.
  void setMode(DataDisplayMode mode) {
    state = mode;
  }
}

/// Notifier for the send mode (Hex or ASCII).
@Riverpod(keepAlive: true)
class SendModeNotifier extends _$SendModeNotifier {
  @override
  DataDisplayMode build() {
    return DataDisplayMode.ascii;
  }

  /// Toggles between Hex and ASCII send modes.
  void toggle() {
    state = state == DataDisplayMode.hex
        ? DataDisplayMode.ascii
        : DataDisplayMode.hex;
  }

  /// Sets the send mode explicitly.
  void setMode(DataDisplayMode mode) {
    state = mode;
  }
}
