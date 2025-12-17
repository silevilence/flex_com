// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unified_connection_config_panel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 当前选择的连接类型 Provider

@ProviderFor(SelectedConnectionType)
const selectedConnectionTypeProvider = SelectedConnectionTypeProvider._();

/// 当前选择的连接类型 Provider
final class SelectedConnectionTypeProvider
    extends $NotifierProvider<SelectedConnectionType, ConnectionType> {
  /// 当前选择的连接类型 Provider
  const SelectedConnectionTypeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedConnectionTypeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedConnectionTypeHash();

  @$internal
  @override
  SelectedConnectionType create() => SelectedConnectionType();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectionType value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectionType>(value),
    );
  }
}

String _$selectedConnectionTypeHash() =>
    r'cd88f42f7aaf8f7c4fc088062c25d8782c299342';

/// 当前选择的连接类型 Provider

abstract class _$SelectedConnectionType extends $Notifier<ConnectionType> {
  ConnectionType build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ConnectionType, ConnectionType>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ConnectionType, ConnectionType>,
              ConnectionType,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
