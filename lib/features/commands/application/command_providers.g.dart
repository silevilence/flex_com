// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'command_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 指令服务 Provider

@ProviderFor(commandService)
const commandServiceProvider = CommandServiceProvider._();

/// 指令服务 Provider

final class CommandServiceProvider
    extends $FunctionalProvider<CommandService, CommandService, CommandService>
    with $Provider<CommandService> {
  /// 指令服务 Provider
  const CommandServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'commandServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$commandServiceHash();

  @$internal
  @override
  $ProviderElement<CommandService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CommandService create(Ref ref) {
    return commandService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommandService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommandService>(value),
    );
  }
}

String _$commandServiceHash() => r'22c4c0e8c84637661f1b84261cc5371e30831100';

/// 指令列表管理器

@ProviderFor(CommandListNotifier)
const commandListProvider = CommandListNotifierProvider._();

/// 指令列表管理器
final class CommandListNotifierProvider
    extends $NotifierProvider<CommandListNotifier, CommandListState> {
  /// 指令列表管理器
  const CommandListNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'commandListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$commandListNotifierHash();

  @$internal
  @override
  CommandListNotifier create() => CommandListNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommandListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommandListState>(value),
    );
  }
}

String _$commandListNotifierHash() =>
    r'3ea1998e36c461fa0da5ab62626431e37ba89e88';

/// 指令列表管理器

abstract class _$CommandListNotifier extends $Notifier<CommandListState> {
  CommandListState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<CommandListState, CommandListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CommandListState, CommandListState>,
              CommandListState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
