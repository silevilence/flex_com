// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'script_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 脚本服务Provider

@ProviderFor(ScriptService)
const scriptServiceProvider = ScriptServiceProvider._();

/// 脚本服务Provider
final class ScriptServiceProvider
    extends $NotifierProvider<ScriptService, ScriptServiceState> {
  /// 脚本服务Provider
  const ScriptServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scriptServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scriptServiceHash();

  @$internal
  @override
  ScriptService create() => ScriptService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScriptServiceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScriptServiceState>(value),
    );
  }
}

String _$scriptServiceHash() => r'80f8ac167309dea75b3aacfdb3cb3094a91ea93c';

/// 脚本服务Provider

abstract class _$ScriptService extends $Notifier<ScriptServiceState> {
  ScriptServiceState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ScriptServiceState, ScriptServiceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ScriptServiceState, ScriptServiceState>,
              ScriptServiceState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
