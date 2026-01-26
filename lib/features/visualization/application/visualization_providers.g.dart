// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visualization_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 配置仓库 Provider

@ProviderFor(oscilloscopeConfigRepository)
const oscilloscopeConfigRepositoryProvider =
    OscilloscopeConfigRepositoryProvider._();

/// 配置仓库 Provider

final class OscilloscopeConfigRepositoryProvider
    extends
        $FunctionalProvider<
          OscilloscopeConfigRepository,
          OscilloscopeConfigRepository,
          OscilloscopeConfigRepository
        >
    with $Provider<OscilloscopeConfigRepository> {
  /// 配置仓库 Provider
  const OscilloscopeConfigRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'oscilloscopeConfigRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$oscilloscopeConfigRepositoryHash();

  @$internal
  @override
  $ProviderElement<OscilloscopeConfigRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OscilloscopeConfigRepository create(Ref ref) {
    return oscilloscopeConfigRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OscilloscopeConfigRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OscilloscopeConfigRepository>(value),
    );
  }
}

String _$oscilloscopeConfigRepositoryHash() =>
    r'a2d51c5372c35c534fdc68f675503d7d7c25fc41';

/// 示波器状态管理

@ProviderFor(OscilloscopeNotifier)
const oscilloscopeProvider = OscilloscopeNotifierProvider._();

/// 示波器状态管理
final class OscilloscopeNotifierProvider
    extends $AsyncNotifierProvider<OscilloscopeNotifier, OscilloscopeState> {
  /// 示波器状态管理
  const OscilloscopeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'oscilloscopeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$oscilloscopeNotifierHash();

  @$internal
  @override
  OscilloscopeNotifier create() => OscilloscopeNotifier();
}

String _$oscilloscopeNotifierHash() =>
    r'9ab78013eb3cf3db3d95c0dd1bc99de6ee734c5d';

/// 示波器状态管理

abstract class _$OscilloscopeNotifier
    extends $AsyncNotifier<OscilloscopeState> {
  FutureOr<OscilloscopeState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<OscilloscopeState>, OscilloscopeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<OscilloscopeState>, OscilloscopeState>,
              AsyncValue<OscilloscopeState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// 通道选择器状态管理

@ProviderFor(ChannelSelectorNotifier)
const channelSelectorProvider = ChannelSelectorNotifierProvider._();

/// 通道选择器状态管理
final class ChannelSelectorNotifierProvider
    extends
        $AsyncNotifierProvider<ChannelSelectorNotifier, ChannelSelectorState> {
  /// 通道选择器状态管理
  const ChannelSelectorNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'channelSelectorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$channelSelectorNotifierHash();

  @$internal
  @override
  ChannelSelectorNotifier create() => ChannelSelectorNotifier();
}

String _$channelSelectorNotifierHash() =>
    r'7610707136469fccad291abfffb872ad19aced63';

/// 通道选择器状态管理

abstract class _$ChannelSelectorNotifier
    extends $AsyncNotifier<ChannelSelectorState> {
  FutureOr<ChannelSelectorState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<ChannelSelectorState>, ChannelSelectorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ChannelSelectorState>,
                ChannelSelectorState
              >,
              AsyncValue<ChannelSelectorState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// 便捷 Provider：获取示波器配置

@ProviderFor(oscilloscopeConfig)
const oscilloscopeConfigProvider = OscilloscopeConfigProvider._();

/// 便捷 Provider：获取示波器配置

final class OscilloscopeConfigProvider
    extends
        $FunctionalProvider<
          OscilloscopeConfig?,
          OscilloscopeConfig?,
          OscilloscopeConfig?
        >
    with $Provider<OscilloscopeConfig?> {
  /// 便捷 Provider：获取示波器配置
  const OscilloscopeConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'oscilloscopeConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$oscilloscopeConfigHash();

  @$internal
  @override
  $ProviderElement<OscilloscopeConfig?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OscilloscopeConfig? create(Ref ref) {
    return oscilloscopeConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OscilloscopeConfig? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OscilloscopeConfig?>(value),
    );
  }
}

String _$oscilloscopeConfigHash() =>
    r'49c03f209b180e5d937b060cdf57a12d31e29167';

/// 便捷 Provider：获取是否正在运行

@ProviderFor(isOscilloscopeRunning)
const isOscilloscopeRunningProvider = IsOscilloscopeRunningProvider._();

/// 便捷 Provider：获取是否正在运行

final class IsOscilloscopeRunningProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 便捷 Provider：获取是否正在运行
  const IsOscilloscopeRunningProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isOscilloscopeRunningProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isOscilloscopeRunningHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isOscilloscopeRunning(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isOscilloscopeRunningHash() =>
    r'752fd19585d9faea1eebae2805672cd77265288a';

/// 便捷 Provider：获取是否暂停

@ProviderFor(isOscilloscopePaused)
const isOscilloscopePausedProvider = IsOscilloscopePausedProvider._();

/// 便捷 Provider：获取是否暂停

final class IsOscilloscopePausedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 便捷 Provider：获取是否暂停
  const IsOscilloscopePausedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isOscilloscopePausedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isOscilloscopePausedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isOscilloscopePaused(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isOscilloscopePausedHash() =>
    r'b29f70db96fa841156f10c4e2e501948cc5b4248';
