import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'display_settings_providers.g.dart';

/// Settings for data display in the receive area.
class DisplaySettings {
  const DisplaySettings({this.showTimestamp = true, this.autoWrap = true});

  /// Whether to show timestamp for each data entry.
  final bool showTimestamp;

  /// Whether to automatically wrap long lines.
  final bool autoWrap;

  DisplaySettings copyWith({bool? showTimestamp, bool? autoWrap}) {
    return DisplaySettings(
      showTimestamp: showTimestamp ?? this.showTimestamp,
      autoWrap: autoWrap ?? this.autoWrap,
    );
  }
}

/// Notifier for managing display settings.
@Riverpod(keepAlive: true)
class DisplaySettingsNotifier extends _$DisplaySettingsNotifier {
  @override
  DisplaySettings build() {
    return const DisplaySettings();
  }

  /// Toggles the timestamp display.
  void toggleTimestamp() {
    state = state.copyWith(showTimestamp: !state.showTimestamp);
  }

  /// Toggles the auto-wrap feature.
  void toggleAutoWrap() {
    state = state.copyWith(autoWrap: !state.autoWrap);
  }

  /// Sets the timestamp display explicitly.
  void setShowTimestamp(bool value) {
    state = state.copyWith(showTimestamp: value);
  }

  /// Sets the auto-wrap feature explicitly.
  void setAutoWrap(bool value) {
    state = state.copyWith(autoWrap: value);
  }
}

/// Counter for tracking bytes received and sent.
class ByteCounter {
  const ByteCounter({this.rxBytes = 0, this.txBytes = 0});

  /// Total bytes received.
  final int rxBytes;

  /// Total bytes sent.
  final int txBytes;

  ByteCounter copyWith({int? rxBytes, int? txBytes}) {
    return ByteCounter(
      rxBytes: rxBytes ?? this.rxBytes,
      txBytes: txBytes ?? this.txBytes,
    );
  }
}

/// Notifier for managing byte counters.
@Riverpod(keepAlive: true)
class ByteCounterNotifier extends _$ByteCounterNotifier {
  @override
  ByteCounter build() {
    return const ByteCounter();
  }

  /// Adds to the received byte counter.
  void addRxBytes(int count) {
    state = state.copyWith(rxBytes: state.rxBytes + count);
  }

  /// Adds to the sent byte counter.
  void addTxBytes(int count) {
    state = state.copyWith(txBytes: state.txBytes + count);
  }

  /// Resets all counters to zero.
  void reset() {
    state = const ByteCounter();
  }
}
