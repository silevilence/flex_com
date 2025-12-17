// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing unified connections.
///
/// This provider manages connections of any type (Serial, TCP, UDP)
/// using the unified [IConnection] interface.

@ProviderFor(UnifiedConnection)
const unifiedConnectionProvider = UnifiedConnectionProvider._();

/// Notifier for managing unified connections.
///
/// This provider manages connections of any type (Serial, TCP, UDP)
/// using the unified [IConnection] interface.
final class UnifiedConnectionProvider
    extends $NotifierProvider<UnifiedConnection, UnifiedConnectionState> {
  /// Notifier for managing unified connections.
  ///
  /// This provider manages connections of any type (Serial, TCP, UDP)
  /// using the unified [IConnection] interface.
  const UnifiedConnectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unifiedConnectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unifiedConnectionHash();

  @$internal
  @override
  UnifiedConnection create() => UnifiedConnection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UnifiedConnectionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UnifiedConnectionState>(value),
    );
  }
}

String _$unifiedConnectionHash() => r'64e4a8a023a7a7703ebcf6d16e53222fb2930b44';

/// Notifier for managing unified connections.
///
/// This provider manages connections of any type (Serial, TCP, UDP)
/// using the unified [IConnection] interface.

abstract class _$UnifiedConnection extends $Notifier<UnifiedConnectionState> {
  UnifiedConnectionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<UnifiedConnectionState, UnifiedConnectionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UnifiedConnectionState, UnifiedConnectionState>,
              UnifiedConnectionState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for available serial ports.

@ProviderFor(availableSerialPorts)
const availableSerialPortsProvider = AvailableSerialPortsProvider._();

/// Provider for available serial ports.

final class AvailableSerialPortsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Provider for available serial ports.
  const AvailableSerialPortsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availableSerialPortsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availableSerialPortsHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return availableSerialPorts(ref);
  }
}

String _$availableSerialPortsHash() =>
    r'a14ec579f461ef532f87bb496f57acf4e7502b2d';

/// Provider for the data stream from the current connection.
///
/// Returns an empty stream if not connected.

@ProviderFor(connectionDataStream)
const connectionDataStreamProvider = ConnectionDataStreamProvider._();

/// Provider for the data stream from the current connection.
///
/// Returns an empty stream if not connected.

final class ConnectionDataStreamProvider
    extends
        $FunctionalProvider<AsyncValue<Uint8List>, Uint8List, Stream<Uint8List>>
    with $FutureModifier<Uint8List>, $StreamProvider<Uint8List> {
  /// Provider for the data stream from the current connection.
  ///
  /// Returns an empty stream if not connected.
  const ConnectionDataStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionDataStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionDataStreamHash();

  @$internal
  @override
  $StreamProviderElement<Uint8List> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Uint8List> create(Ref ref) {
    return connectionDataStream(ref);
  }
}

String _$connectionDataStreamHash() =>
    r'06d9464bf2e5a564c921a6ef5c8dad55e02a7191';
