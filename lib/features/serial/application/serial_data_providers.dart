import 'dart:async';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/serial_data_entry.dart';
import 'display_settings_providers.dart';
import 'serial_providers.dart';

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
    // Get repository directly and subscribe to its stream
    final repository = ref.watch(serialRepositoryProvider);

    // Cancel any existing subscription
    _subscription?.cancel();

    // Subscribe to the data stream
    _subscription = repository.dataStream.listen((data) {
      _addEntry(SerialDataEntry.received(data));
    });

    ref.onDispose(() {
      _subscription?.cancel();
      _subscription = null;
    });

    return [];
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
