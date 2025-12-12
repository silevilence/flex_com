// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_helper_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 发送设置状态管理

@ProviderFor(SendSettingsNotifier)
const sendSettingsProvider = SendSettingsNotifierProvider._();

/// 发送设置状态管理
final class SendSettingsNotifierProvider
    extends $NotifierProvider<SendSettingsNotifier, SendSettings> {
  /// 发送设置状态管理
  const SendSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sendSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sendSettingsNotifierHash();

  @$internal
  @override
  SendSettingsNotifier create() => SendSettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SendSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SendSettings>(value),
    );
  }
}

String _$sendSettingsNotifierHash() =>
    r'f2512d711fc5bb05a0636721a0dee02fbc74f4cc';

/// 发送设置状态管理

abstract class _$SendSettingsNotifier extends $Notifier<SendSettings> {
  SendSettings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SendSettings, SendSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SendSettings, SendSettings>,
              SendSettings,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// 循环发送控制器

@ProviderFor(CyclicSendController)
const cyclicSendControllerProvider = CyclicSendControllerProvider._();

/// 循环发送控制器
final class CyclicSendControllerProvider
    extends $NotifierProvider<CyclicSendController, CyclicSendState> {
  /// 循环发送控制器
  const CyclicSendControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cyclicSendControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cyclicSendControllerHash();

  @$internal
  @override
  CyclicSendController create() => CyclicSendController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CyclicSendState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CyclicSendState>(value),
    );
  }
}

String _$cyclicSendControllerHash() =>
    r'ddbdd694c6eb461ab95c0c59832a0b1c9dbdb739';

/// 循环发送控制器

abstract class _$CyclicSendController extends $Notifier<CyclicSendState> {
  CyclicSendState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<CyclicSendState, CyclicSendState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CyclicSendState, CyclicSendState>,
              CyclicSendState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
