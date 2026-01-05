// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_reply_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 自动回复配置服务 Provider

@ProviderFor(autoReplyConfigService)
const autoReplyConfigServiceProvider = AutoReplyConfigServiceProvider._();

/// 自动回复配置服务 Provider

final class AutoReplyConfigServiceProvider
    extends
        $FunctionalProvider<
          AutoReplyConfigService,
          AutoReplyConfigService,
          AutoReplyConfigService
        >
    with $Provider<AutoReplyConfigService> {
  /// 自动回复配置服务 Provider
  const AutoReplyConfigServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoReplyConfigServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoReplyConfigServiceHash();

  @$internal
  @override
  $ProviderElement<AutoReplyConfigService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AutoReplyConfigService create(Ref ref) {
    return autoReplyConfigService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AutoReplyConfigService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AutoReplyConfigService>(value),
    );
  }
}

String _$autoReplyConfigServiceHash() =>
    r'759706099a0f20fd21d22343cb3935abd20d9a29';

/// 全局自动回复配置 Provider

@ProviderFor(AutoReplyConfigNotifier)
const autoReplyConfigProvider = AutoReplyConfigNotifierProvider._();

/// 全局自动回复配置 Provider
final class AutoReplyConfigNotifierProvider
    extends $AsyncNotifierProvider<AutoReplyConfigNotifier, AutoReplyConfig> {
  /// 全局自动回复配置 Provider
  const AutoReplyConfigNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoReplyConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoReplyConfigNotifierHash();

  @$internal
  @override
  AutoReplyConfigNotifier create() => AutoReplyConfigNotifier();
}

String _$autoReplyConfigNotifierHash() =>
    r'cc840edea73c0282a6c32b37b841c6c2601a8a90';

/// 全局自动回复配置 Provider

abstract class _$AutoReplyConfigNotifier
    extends $AsyncNotifier<AutoReplyConfig> {
  FutureOr<AutoReplyConfig> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<AutoReplyConfig>, AutoReplyConfig>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AutoReplyConfig>, AutoReplyConfig>,
              AsyncValue<AutoReplyConfig>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// 匹配回复配置 Provider

@ProviderFor(MatchReplyConfigNotifier)
const matchReplyConfigProvider = MatchReplyConfigNotifierProvider._();

/// 匹配回复配置 Provider
final class MatchReplyConfigNotifierProvider
    extends $AsyncNotifierProvider<MatchReplyConfigNotifier, MatchReplyConfig> {
  /// 匹配回复配置 Provider
  const MatchReplyConfigNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'matchReplyConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$matchReplyConfigNotifierHash();

  @$internal
  @override
  MatchReplyConfigNotifier create() => MatchReplyConfigNotifier();
}

String _$matchReplyConfigNotifierHash() =>
    r'a8b90cbd490b2bf324da216d2cd1c78cfab2661d';

/// 匹配回复配置 Provider

abstract class _$MatchReplyConfigNotifier
    extends $AsyncNotifier<MatchReplyConfig> {
  FutureOr<MatchReplyConfig> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<MatchReplyConfig>, MatchReplyConfig>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MatchReplyConfig>, MatchReplyConfig>,
              AsyncValue<MatchReplyConfig>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// 顺序回复配置 Provider

@ProviderFor(SequentialReplyConfigNotifier)
const sequentialReplyConfigProvider = SequentialReplyConfigNotifierProvider._();

/// 顺序回复配置 Provider
final class SequentialReplyConfigNotifierProvider
    extends
        $AsyncNotifierProvider<
          SequentialReplyConfigNotifier,
          SequentialReplyConfig
        > {
  /// 顺序回复配置 Provider
  const SequentialReplyConfigNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sequentialReplyConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sequentialReplyConfigNotifierHash();

  @$internal
  @override
  SequentialReplyConfigNotifier create() => SequentialReplyConfigNotifier();
}

String _$sequentialReplyConfigNotifierHash() =>
    r'd780857ed5b729f3e2b7b2df6d1a3060bba9fcc7';

/// 顺序回复配置 Provider

abstract class _$SequentialReplyConfigNotifier
    extends $AsyncNotifier<SequentialReplyConfig> {
  FutureOr<SequentialReplyConfig> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<SequentialReplyConfig>, SequentialReplyConfig>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<SequentialReplyConfig>,
                SequentialReplyConfig
              >,
              AsyncValue<SequentialReplyConfig>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// 当前活动的回复处理器 Provider
///
/// 根据全局配置自动选择对应的处理器实现

@ProviderFor(activeReplyHandler)
const activeReplyHandlerProvider = ActiveReplyHandlerProvider._();

/// 当前活动的回复处理器 Provider
///
/// 根据全局配置自动选择对应的处理器实现

final class ActiveReplyHandlerProvider
    extends $FunctionalProvider<ReplyHandler?, ReplyHandler?, ReplyHandler?>
    with $Provider<ReplyHandler?> {
  /// 当前活动的回复处理器 Provider
  ///
  /// 根据全局配置自动选择对应的处理器实现
  const ActiveReplyHandlerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeReplyHandlerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeReplyHandlerHash();

  @$internal
  @override
  $ProviderElement<ReplyHandler?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReplyHandler? create(Ref ref) {
    return activeReplyHandler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReplyHandler? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReplyHandler?>(value),
    );
  }
}

String _$activeReplyHandlerHash() =>
    r'd12888e0cb218fcc6349224504ac87674598f8bc';
