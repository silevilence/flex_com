// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'display_settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing display settings.

@ProviderFor(DisplaySettingsNotifier)
const displaySettingsProvider = DisplaySettingsNotifierProvider._();

/// Notifier for managing display settings.
final class DisplaySettingsNotifierProvider
    extends $NotifierProvider<DisplaySettingsNotifier, DisplaySettings> {
  /// Notifier for managing display settings.
  const DisplaySettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'displaySettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$displaySettingsNotifierHash();

  @$internal
  @override
  DisplaySettingsNotifier create() => DisplaySettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DisplaySettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DisplaySettings>(value),
    );
  }
}

String _$displaySettingsNotifierHash() =>
    r'5993943549d442b3ef6d69e3eabf8ed926ff6fc4';

/// Notifier for managing display settings.

abstract class _$DisplaySettingsNotifier extends $Notifier<DisplaySettings> {
  DisplaySettings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DisplaySettings, DisplaySettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DisplaySettings, DisplaySettings>,
              DisplaySettings,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Notifier for managing byte counters.

@ProviderFor(ByteCounterNotifier)
const byteCounterProvider = ByteCounterNotifierProvider._();

/// Notifier for managing byte counters.
final class ByteCounterNotifierProvider
    extends $NotifierProvider<ByteCounterNotifier, ByteCounter> {
  /// Notifier for managing byte counters.
  const ByteCounterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'byteCounterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$byteCounterNotifierHash();

  @$internal
  @override
  ByteCounterNotifier create() => ByteCounterNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ByteCounter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ByteCounter>(value),
    );
  }
}

String _$byteCounterNotifierHash() =>
    r'e36d6681526cf2673ec17bdbb3a4b48a0888ccb8';

/// Notifier for managing byte counters.

abstract class _$ByteCounterNotifier extends $Notifier<ByteCounter> {
  ByteCounter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ByteCounter, ByteCounter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ByteCounter, ByteCounter>,
              ByteCounter,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
