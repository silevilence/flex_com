// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_page.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 左侧面板展开状态的 Notifier

@ProviderFor(LeftPanelExpanded)
const leftPanelExpandedProvider = LeftPanelExpandedProvider._();

/// 左侧面板展开状态的 Notifier
final class LeftPanelExpandedProvider
    extends $NotifierProvider<LeftPanelExpanded, bool> {
  /// 左侧面板展开状态的 Notifier
  const LeftPanelExpandedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leftPanelExpandedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leftPanelExpandedHash();

  @$internal
  @override
  LeftPanelExpanded create() => LeftPanelExpanded();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$leftPanelExpandedHash() => r'25ee6b366a1bc6ecbe4493ab6b951584554d4bdd';

/// 左侧面板展开状态的 Notifier

abstract class _$LeftPanelExpanded extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// 底部面板展开状态的 Notifier

@ProviderFor(BottomPanelExpanded)
const bottomPanelExpandedProvider = BottomPanelExpandedProvider._();

/// 底部面板展开状态的 Notifier
final class BottomPanelExpandedProvider
    extends $NotifierProvider<BottomPanelExpanded, bool> {
  /// 底部面板展开状态的 Notifier
  const BottomPanelExpandedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bottomPanelExpandedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bottomPanelExpandedHash();

  @$internal
  @override
  BottomPanelExpanded create() => BottomPanelExpanded();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$bottomPanelExpandedHash() =>
    r'fee4c6fbb79abd48addd648c01803dcd60ecd920';

/// 底部面板展开状态的 Notifier

abstract class _$BottomPanelExpanded extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
