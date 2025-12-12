// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the config service.

@ProviderFor(configService)
const configServiceProvider = ConfigServiceProvider._();

/// Provider for the config service.

final class ConfigServiceProvider
    extends $FunctionalProvider<ConfigService, ConfigService, ConfigService>
    with $Provider<ConfigService> {
  /// Provider for the config service.
  const ConfigServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'configServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$configServiceHash();

  @$internal
  @override
  $ProviderElement<ConfigService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ConfigService create(Ref ref) {
    return configService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConfigService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConfigService>(value),
    );
  }
}

String _$configServiceHash() => r'61290a5d2807ead1e9d37c8d6ff5b931cea27b18';

/// Provider for loading saved serial port configuration.
///
/// This is used to restore the last used configuration on app startup.

@ProviderFor(savedSerialConfig)
const savedSerialConfigProvider = SavedSerialConfigProvider._();

/// Provider for loading saved serial port configuration.
///
/// This is used to restore the last used configuration on app startup.

final class SavedSerialConfigProvider
    extends
        $FunctionalProvider<
          AsyncValue<SerialPortConfig?>,
          SerialPortConfig?,
          FutureOr<SerialPortConfig?>
        >
    with
        $FutureModifier<SerialPortConfig?>,
        $FutureProvider<SerialPortConfig?> {
  /// Provider for loading saved serial port configuration.
  ///
  /// This is used to restore the last used configuration on app startup.
  const SavedSerialConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedSerialConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedSerialConfigHash();

  @$internal
  @override
  $FutureProviderElement<SerialPortConfig?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SerialPortConfig?> create(Ref ref) {
    return savedSerialConfig(ref);
  }
}

String _$savedSerialConfigHash() => r'b6695d64e18b7bf95a01e5454139cba8ecdb7aea';

/// Notifier for managing saved serial port configuration.

@ProviderFor(SavedConfigNotifier)
const savedConfigProvider = SavedConfigNotifierProvider._();

/// Notifier for managing saved serial port configuration.
final class SavedConfigNotifierProvider
    extends $AsyncNotifierProvider<SavedConfigNotifier, SerialPortConfig?> {
  /// Notifier for managing saved serial port configuration.
  const SavedConfigNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedConfigNotifierHash();

  @$internal
  @override
  SavedConfigNotifier create() => SavedConfigNotifier();
}

String _$savedConfigNotifierHash() =>
    r'6860b2f2f1f9ddc88c5bd92e3587909f4c4ec877';

/// Notifier for managing saved serial port configuration.

abstract class _$SavedConfigNotifier extends $AsyncNotifier<SerialPortConfig?> {
  FutureOr<SerialPortConfig?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<SerialPortConfig?>, SerialPortConfig?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SerialPortConfig?>, SerialPortConfig?>,
              AsyncValue<SerialPortConfig?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
