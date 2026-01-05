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
    r'0dd7b7bdfcd6a85fdedef8f2b7df81eb3054d1c2';

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

/// 发送面板控制器
///
/// 用于从外部（如指令列表）触发发送操作

@ProviderFor(SendPanelController)
const sendPanelControllerProvider = SendPanelControllerProvider._();

/// 发送面板控制器
///
/// 用于从外部（如指令列表）触发发送操作
final class SendPanelControllerProvider
    extends $NotifierProvider<SendPanelController, SendPanelControllerState> {
  /// 发送面板控制器
  ///
  /// 用于从外部（如指令列表）触发发送操作
  const SendPanelControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sendPanelControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sendPanelControllerHash();

  @$internal
  @override
  SendPanelController create() => SendPanelController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SendPanelControllerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SendPanelControllerState>(value),
    );
  }
}

String _$sendPanelControllerHash() =>
    r'9b2a5f274c96f462fa5a09e21d18c2d4b355b246';

/// 发送面板控制器
///
/// 用于从外部（如指令列表）触发发送操作

abstract class _$SendPanelController
    extends $Notifier<SendPanelControllerState> {
  SendPanelControllerState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<SendPanelControllerState, SendPanelControllerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SendPanelControllerState, SendPanelControllerState>,
              SendPanelControllerState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
