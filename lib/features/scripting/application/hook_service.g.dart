// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hook_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Hook 服务 Provider

@ProviderFor(HookService)
const hookServiceProvider = HookServiceProvider._();

/// Hook 服务 Provider
final class HookServiceProvider
    extends $NotifierProvider<HookService, HookServiceState> {
  /// Hook 服务 Provider
  const HookServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hookServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hookServiceHash();

  @$internal
  @override
  HookService create() => HookService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HookServiceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HookServiceState>(value),
    );
  }
}

String _$hookServiceHash() => r'd2e7fdf41b591b01bacbd658ff57c325ff1b0709';

/// Hook 服务 Provider

abstract class _$HookService extends $Notifier<HookServiceState> {
  HookServiceState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<HookServiceState, HookServiceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HookServiceState, HookServiceState>,
              HookServiceState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Hook 绑定列表 Provider (只读)

@ProviderFor(hookBindings)
const hookBindingsProvider = HookBindingsProvider._();

/// Hook 绑定列表 Provider (只读)

final class HookBindingsProvider
    extends
        $FunctionalProvider<
          List<ScriptHookBinding>,
          List<ScriptHookBinding>,
          List<ScriptHookBinding>
        >
    with $Provider<List<ScriptHookBinding>> {
  /// Hook 绑定列表 Provider (只读)
  const HookBindingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hookBindingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hookBindingsHash();

  @$internal
  @override
  $ProviderElement<List<ScriptHookBinding>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ScriptHookBinding> create(Ref ref) {
    return hookBindings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ScriptHookBinding> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ScriptHookBinding>>(value),
    );
  }
}

String _$hookBindingsHash() => r'0dc1d1e0952ed31a3211bc02614adc6ac17fe3cd';

/// 指定类型的 Hook 绑定 Provider

@ProviderFor(hookBindingsByType)
const hookBindingsByTypeProvider = HookBindingsByTypeFamily._();

/// 指定类型的 Hook 绑定 Provider

final class HookBindingsByTypeProvider
    extends
        $FunctionalProvider<
          List<ScriptHookBinding>,
          List<ScriptHookBinding>,
          List<ScriptHookBinding>
        >
    with $Provider<List<ScriptHookBinding>> {
  /// 指定类型的 Hook 绑定 Provider
  const HookBindingsByTypeProvider._({
    required HookBindingsByTypeFamily super.from,
    required HookType super.argument,
  }) : super(
         retry: null,
         name: r'hookBindingsByTypeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hookBindingsByTypeHash();

  @override
  String toString() {
    return r'hookBindingsByTypeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<ScriptHookBinding>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ScriptHookBinding> create(Ref ref) {
    final argument = this.argument as HookType;
    return hookBindingsByType(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ScriptHookBinding> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ScriptHookBinding>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HookBindingsByTypeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hookBindingsByTypeHash() =>
    r'1dc1646988c9881edb77bb2d85e619271943b1fa';

/// 指定类型的 Hook 绑定 Provider

final class HookBindingsByTypeFamily extends $Family
    with $FunctionalFamilyOverride<List<ScriptHookBinding>, HookType> {
  const HookBindingsByTypeFamily._()
    : super(
        retry: null,
        name: r'hookBindingsByTypeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 指定类型的 Hook 绑定 Provider

  HookBindingsByTypeProvider call(HookType type) =>
      HookBindingsByTypeProvider._(argument: type, from: this);

  @override
  String toString() => r'hookBindingsByTypeProvider';
}

/// 是否有激活的 Rx Hook

@ProviderFor(hasActiveRxHook)
const hasActiveRxHookProvider = HasActiveRxHookProvider._();

/// 是否有激活的 Rx Hook

final class HasActiveRxHookProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 是否有激活的 Rx Hook
  const HasActiveRxHookProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasActiveRxHookProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasActiveRxHookHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return hasActiveRxHook(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hasActiveRxHookHash() => r'6322b82beff68fc5501c5e53eb5317d9de778bdf';

/// 是否有激活的 Tx Hook

@ProviderFor(hasActiveTxHook)
const hasActiveTxHookProvider = HasActiveTxHookProvider._();

/// 是否有激活的 Tx Hook

final class HasActiveTxHookProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 是否有激活的 Tx Hook
  const HasActiveTxHookProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasActiveTxHookProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasActiveTxHookHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return hasActiveTxHook(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hasActiveTxHookHash() => r'e29a27eb4069ba4e686b8f9d0c1491461b5c3fe7';

/// 是否有激活的 Reply Hook

@ProviderFor(hasActiveReplyHook)
const hasActiveReplyHookProvider = HasActiveReplyHookProvider._();

/// 是否有激活的 Reply Hook

final class HasActiveReplyHookProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 是否有激活的 Reply Hook
  const HasActiveReplyHookProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasActiveReplyHookProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasActiveReplyHookHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return hasActiveReplyHook(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hasActiveReplyHookHash() =>
    r'a0832e24236e875af7ada21ac5941c4fef47c845';

/// Hook 日志 Provider

@ProviderFor(hookLogs)
const hookLogsProvider = HookLogsProvider._();

/// Hook 日志 Provider

final class HookLogsProvider
    extends
        $FunctionalProvider<List<ScriptLog>, List<ScriptLog>, List<ScriptLog>>
    with $Provider<List<ScriptLog>> {
  /// Hook 日志 Provider
  const HookLogsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hookLogsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hookLogsHash();

  @$internal
  @override
  $ProviderElement<List<ScriptLog>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<ScriptLog> create(Ref ref) {
    return hookLogs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ScriptLog> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ScriptLog>>(value),
    );
  }
}

String _$hookLogsHash() => r'adae0a875f9c47844b7226fb27e03deb67bf82ff';
