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

/// Notifier for managing saved TCP client configuration.

@ProviderFor(SavedTcpClientConfig)
const savedTcpClientConfigProvider = SavedTcpClientConfigProvider._();

/// Notifier for managing saved TCP client configuration.
final class SavedTcpClientConfigProvider
    extends $AsyncNotifierProvider<SavedTcpClientConfig, TcpClientConfig?> {
  /// Notifier for managing saved TCP client configuration.
  const SavedTcpClientConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedTcpClientConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedTcpClientConfigHash();

  @$internal
  @override
  SavedTcpClientConfig create() => SavedTcpClientConfig();
}

String _$savedTcpClientConfigHash() =>
    r'98f29c0d29b5f44e4f9cea6027371e64c000c613';

/// Notifier for managing saved TCP client configuration.

abstract class _$SavedTcpClientConfig extends $AsyncNotifier<TcpClientConfig?> {
  FutureOr<TcpClientConfig?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<TcpClientConfig?>, TcpClientConfig?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TcpClientConfig?>, TcpClientConfig?>,
              AsyncValue<TcpClientConfig?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Notifier for managing saved TCP server configuration.

@ProviderFor(SavedTcpServerConfig)
const savedTcpServerConfigProvider = SavedTcpServerConfigProvider._();

/// Notifier for managing saved TCP server configuration.
final class SavedTcpServerConfigProvider
    extends $AsyncNotifierProvider<SavedTcpServerConfig, TcpServerConfig?> {
  /// Notifier for managing saved TCP server configuration.
  const SavedTcpServerConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedTcpServerConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedTcpServerConfigHash();

  @$internal
  @override
  SavedTcpServerConfig create() => SavedTcpServerConfig();
}

String _$savedTcpServerConfigHash() =>
    r'50d24d9cd215389641f6c52d6b72c4ff7997481e';

/// Notifier for managing saved TCP server configuration.

abstract class _$SavedTcpServerConfig extends $AsyncNotifier<TcpServerConfig?> {
  FutureOr<TcpServerConfig?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<TcpServerConfig?>, TcpServerConfig?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TcpServerConfig?>, TcpServerConfig?>,
              AsyncValue<TcpServerConfig?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Notifier for managing saved UDP configuration.

@ProviderFor(SavedUdpConfig)
const savedUdpConfigProvider = SavedUdpConfigProvider._();

/// Notifier for managing saved UDP configuration.
final class SavedUdpConfigProvider
    extends $AsyncNotifierProvider<SavedUdpConfig, UdpConfig?> {
  /// Notifier for managing saved UDP configuration.
  const SavedUdpConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedUdpConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedUdpConfigHash();

  @$internal
  @override
  SavedUdpConfig create() => SavedUdpConfig();
}

String _$savedUdpConfigHash() => r'1284a8d0e55a10b5362342225957c785fa75065d';

/// Notifier for managing saved UDP configuration.

abstract class _$SavedUdpConfig extends $AsyncNotifier<UdpConfig?> {
  FutureOr<UdpConfig?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<UdpConfig?>, UdpConfig?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UdpConfig?>, UdpConfig?>,
              AsyncValue<UdpConfig?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
