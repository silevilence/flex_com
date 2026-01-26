// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serial_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier that manages the list of serial data entries.
///
/// This collects both sent and received data into a single log.

@ProviderFor(SerialDataLog)
const serialDataLogProvider = SerialDataLogProvider._();

/// Notifier that manages the list of serial data entries.
///
/// This collects both sent and received data into a single log.
final class SerialDataLogProvider
    extends $NotifierProvider<SerialDataLog, List<SerialDataEntry>> {
  /// Notifier that manages the list of serial data entries.
  ///
  /// This collects both sent and received data into a single log.
  const SerialDataLogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serialDataLogProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serialDataLogHash();

  @$internal
  @override
  SerialDataLog create() => SerialDataLog();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SerialDataEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SerialDataEntry>>(value),
    );
  }
}

String _$serialDataLogHash() => r'99bba852cbe48357923e377ab541d1fe9d9febdd';

/// Notifier that manages the list of serial data entries.
///
/// This collects both sent and received data into a single log.

abstract class _$SerialDataLog extends $Notifier<List<SerialDataEntry>> {
  List<SerialDataEntry> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<SerialDataEntry>, List<SerialDataEntry>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<SerialDataEntry>, List<SerialDataEntry>>,
              List<SerialDataEntry>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Notifier for the data display mode (Hex or ASCII).

@ProviderFor(DataDisplayModeNotifier)
const dataDisplayModeProvider = DataDisplayModeNotifierProvider._();

/// Notifier for the data display mode (Hex or ASCII).
final class DataDisplayModeNotifierProvider
    extends $NotifierProvider<DataDisplayModeNotifier, DataDisplayMode> {
  /// Notifier for the data display mode (Hex or ASCII).
  const DataDisplayModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataDisplayModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataDisplayModeNotifierHash();

  @$internal
  @override
  DataDisplayModeNotifier create() => DataDisplayModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DataDisplayMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DataDisplayMode>(value),
    );
  }
}

String _$dataDisplayModeNotifierHash() =>
    r'bd7bb36bac40dcae22a7b7aa6ef8802fc0421d00';

/// Notifier for the data display mode (Hex or ASCII).

abstract class _$DataDisplayModeNotifier extends $Notifier<DataDisplayMode> {
  DataDisplayMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DataDisplayMode, DataDisplayMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DataDisplayMode, DataDisplayMode>,
              DataDisplayMode,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Notifier for the send mode (Hex or ASCII).

@ProviderFor(SendModeNotifier)
const sendModeProvider = SendModeNotifierProvider._();

/// Notifier for the send mode (Hex or ASCII).
final class SendModeNotifierProvider
    extends $NotifierProvider<SendModeNotifier, DataDisplayMode> {
  /// Notifier for the send mode (Hex or ASCII).
  const SendModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sendModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sendModeNotifierHash();

  @$internal
  @override
  SendModeNotifier create() => SendModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DataDisplayMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DataDisplayMode>(value),
    );
  }
}

String _$sendModeNotifierHash() => r'23cf33ac9c39b67ef080001071772182e897062b';

/// Notifier for the send mode (Hex or ASCII).

abstract class _$SendModeNotifier extends $Notifier<DataDisplayMode> {
  DataDisplayMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DataDisplayMode, DataDisplayMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DataDisplayMode, DataDisplayMode>,
              DataDisplayMode,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
