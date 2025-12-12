// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layout_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 布局状态管理 Notifier

@ProviderFor(LayoutNotifier)
const layoutProvider = LayoutNotifierProvider._();

/// 布局状态管理 Notifier
final class LayoutNotifierProvider
    extends $NotifierProvider<LayoutNotifier, LayoutState> {
  /// 布局状态管理 Notifier
  const LayoutNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'layoutProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$layoutNotifierHash();

  @$internal
  @override
  LayoutNotifier create() => LayoutNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LayoutState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LayoutState>(value),
    );
  }
}

String _$layoutNotifierHash() => r'0db9b5913edbb8aa015d8a1d12508f5cad9c9691';

/// 布局状态管理 Notifier

abstract class _$LayoutNotifier extends $Notifier<LayoutState> {
  LayoutState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<LayoutState, LayoutState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LayoutState, LayoutState>,
              LayoutState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
