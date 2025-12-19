// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_reply_engine.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 自动回复引擎 Provider
///
/// 监听连接数据流，自动处理接收到的数据并发送回复

@ProviderFor(AutoReplyEngine)
const autoReplyEngineProvider = AutoReplyEngineProvider._();

/// 自动回复引擎 Provider
///
/// 监听连接数据流，自动处理接收到的数据并发送回复
final class AutoReplyEngineProvider
    extends $NotifierProvider<AutoReplyEngine, AutoReplyEngineState> {
  /// 自动回复引擎 Provider
  ///
  /// 监听连接数据流，自动处理接收到的数据并发送回复
  const AutoReplyEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoReplyEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoReplyEngineHash();

  @$internal
  @override
  AutoReplyEngine create() => AutoReplyEngine();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AutoReplyEngineState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AutoReplyEngineState>(value),
    );
  }
}

String _$autoReplyEngineHash() => r'86412e475c1ad024170c33dadfd51d9b8595ef7f';

/// 自动回复引擎 Provider
///
/// 监听连接数据流，自动处理接收到的数据并发送回复

abstract class _$AutoReplyEngine extends $Notifier<AutoReplyEngineState> {
  AutoReplyEngineState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AutoReplyEngineState, AutoReplyEngineState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AutoReplyEngineState, AutoReplyEngineState>,
              AutoReplyEngineState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// 自动回复统计 Provider（只读）

@ProviderFor(autoReplyStats)
const autoReplyStatsProvider = AutoReplyStatsProvider._();

/// 自动回复统计 Provider（只读）

final class AutoReplyStatsProvider
    extends $FunctionalProvider<AutoReplyStats, AutoReplyStats, AutoReplyStats>
    with $Provider<AutoReplyStats> {
  /// 自动回复统计 Provider（只读）
  const AutoReplyStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoReplyStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoReplyStatsHash();

  @$internal
  @override
  $ProviderElement<AutoReplyStats> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AutoReplyStats create(Ref ref) {
    return autoReplyStats(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AutoReplyStats value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AutoReplyStats>(value),
    );
  }
}

String _$autoReplyStatsHash() => r'e6d61c0da57339dde6c594f509ac80e68ee80252';

/// 自动回复是否正在处理 Provider

@ProviderFor(autoReplyProcessing)
const autoReplyProcessingProvider = AutoReplyProcessingProvider._();

/// 自动回复是否正在处理 Provider

final class AutoReplyProcessingProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 自动回复是否正在处理 Provider
  const AutoReplyProcessingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoReplyProcessingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoReplyProcessingHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return autoReplyProcessing(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$autoReplyProcessingHash() =>
    r'183ba523736f6515c9911340430f701b28c3d8fc';
