// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serial_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the serial repository.
///
/// This is a singleton that manages the serial port isolate.
/// It is disposed when the provider is no longer used.

@ProviderFor(serialRepository)
const serialRepositoryProvider = SerialRepositoryProvider._();

/// Provider for the serial repository.
///
/// This is a singleton that manages the serial port isolate.
/// It is disposed when the provider is no longer used.

final class SerialRepositoryProvider
    extends
        $FunctionalProvider<
          SerialRepository,
          SerialRepository,
          SerialRepository
        >
    with $Provider<SerialRepository> {
  /// Provider for the serial repository.
  ///
  /// This is a singleton that manages the serial port isolate.
  /// It is disposed when the provider is no longer used.
  const SerialRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serialRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serialRepositoryHash();

  @$internal
  @override
  $ProviderElement<SerialRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SerialRepository create(Ref ref) {
    return serialRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SerialRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SerialRepository>(value),
    );
  }
}

String _$serialRepositoryHash() => r'9397a1b7f25ce7486cbae3d56f833e765a91d6f7';

/// Provider for the list of available serial ports.
///
/// This refreshes each time it is read and can be manually refreshed
/// by invalidating the provider.

@ProviderFor(availablePorts)
const availablePortsProvider = AvailablePortsProvider._();

/// Provider for the list of available serial ports.
///
/// This refreshes each time it is read and can be manually refreshed
/// by invalidating the provider.

final class AvailablePortsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Provider for the list of available serial ports.
  ///
  /// This refreshes each time it is read and can be manually refreshed
  /// by invalidating the provider.
  const AvailablePortsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availablePortsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availablePortsHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return availablePorts(ref);
  }
}

String _$availablePortsHash() => r'e2c026d29fa4ba9f5c337d5647ba8d14478eee87';

/// Notifier for managing serial connection state.

@ProviderFor(SerialConnection)
const serialConnectionProvider = SerialConnectionProvider._();

/// Notifier for managing serial connection state.
final class SerialConnectionProvider
    extends $NotifierProvider<SerialConnection, SerialConnectionState> {
  /// Notifier for managing serial connection state.
  const SerialConnectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serialConnectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serialConnectionHash();

  @$internal
  @override
  SerialConnection create() => SerialConnection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SerialConnectionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SerialConnectionState>(value),
    );
  }
}

String _$serialConnectionHash() => r'546639a292b6916a303ea96eecda96039807fa70';

/// Notifier for managing serial connection state.

abstract class _$SerialConnection extends $Notifier<SerialConnectionState> {
  SerialConnectionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SerialConnectionState, SerialConnectionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SerialConnectionState, SerialConnectionState>,
              SerialConnectionState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for the serial data stream.
///
/// This exposes the stream of data received from the serial port.

@ProviderFor(serialDataStream)
const serialDataStreamProvider = SerialDataStreamProvider._();

/// Provider for the serial data stream.
///
/// This exposes the stream of data received from the serial port.

final class SerialDataStreamProvider
    extends
        $FunctionalProvider<AsyncValue<Uint8List>, Uint8List, Stream<Uint8List>>
    with $FutureModifier<Uint8List>, $StreamProvider<Uint8List> {
  /// Provider for the serial data stream.
  ///
  /// This exposes the stream of data received from the serial port.
  const SerialDataStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serialDataStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serialDataStreamHash();

  @$internal
  @override
  $StreamProviderElement<Uint8List> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Uint8List> create(Ref ref) {
    return serialDataStream(ref);
  }
}

String _$serialDataStreamHash() => r'eea2a526f58bb4830df92918807051a533549ebc';
