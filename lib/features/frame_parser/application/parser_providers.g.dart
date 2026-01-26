// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parser_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 解析器注册表 Provider

@ProviderFor(parserRegistry)
const parserRegistryProvider = ParserRegistryProvider._();

/// 解析器注册表 Provider

final class ParserRegistryProvider
    extends $FunctionalProvider<ParserRegistry, ParserRegistry, ParserRegistry>
    with $Provider<ParserRegistry> {
  /// 解析器注册表 Provider
  const ParserRegistryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parserRegistryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parserRegistryHash();

  @$internal
  @override
  $ProviderElement<ParserRegistry> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ParserRegistry create(Ref ref) {
    return parserRegistry(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ParserRegistry value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ParserRegistry>(value),
    );
  }
}

String _$parserRegistryHash() => r'b105270166938665ac3f07fb1bf6a8ce16173d06';

/// 配置仓库 Provider

@ProviderFor(frameConfigRepository)
const frameConfigRepositoryProvider = FrameConfigRepositoryProvider._();

/// 配置仓库 Provider

final class FrameConfigRepositoryProvider
    extends
        $FunctionalProvider<
          FrameConfigRepository,
          FrameConfigRepository,
          FrameConfigRepository
        >
    with $Provider<FrameConfigRepository> {
  /// 配置仓库 Provider
  const FrameConfigRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'frameConfigRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$frameConfigRepositoryHash();

  @$internal
  @override
  $ProviderElement<FrameConfigRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FrameConfigRepository create(Ref ref) {
    return frameConfigRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FrameConfigRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FrameConfigRepository>(value),
    );
  }
}

String _$frameConfigRepositoryHash() =>
    r'68d2a8571c1c7b1de90c3b4ed1f8bdb1b0c6bf74';

/// 解析器状态管理

@ProviderFor(ParserNotifier)
const parserProvider = ParserNotifierProvider._();

/// 解析器状态管理
final class ParserNotifierProvider
    extends $AsyncNotifierProvider<ParserNotifier, ParserState> {
  /// 解析器状态管理
  const ParserNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parserNotifierHash();

  @$internal
  @override
  ParserNotifier create() => ParserNotifier();
}

String _$parserNotifierHash() => r'a118d7fa450d9dc3043fb9ae8dc96c1b4f3e079a';

/// 解析器状态管理

abstract class _$ParserNotifier extends $AsyncNotifier<ParserState> {
  FutureOr<ParserState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<ParserState>, ParserState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ParserState>, ParserState>,
              AsyncValue<ParserState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// 配置编辑器状态管理

@ProviderFor(EditorNotifier)
const editorProvider = EditorNotifierProvider._();

/// 配置编辑器状态管理
final class EditorNotifierProvider
    extends $NotifierProvider<EditorNotifier, EditorState> {
  /// 配置编辑器状态管理
  const EditorNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'editorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$editorNotifierHash();

  @$internal
  @override
  EditorNotifier create() => EditorNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EditorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EditorState>(value),
    );
  }
}

String _$editorNotifierHash() => r'e257623fe6756c05173b5f75f851da25d8368d02';

/// 配置编辑器状态管理

abstract class _$EditorNotifier extends $Notifier<EditorState> {
  EditorState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<EditorState, EditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EditorState, EditorState>,
              EditorState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// 当前激活配置的便捷 Provider

@ProviderFor(activeFrameConfig)
const activeFrameConfigProvider = ActiveFrameConfigProvider._();

/// 当前激活配置的便捷 Provider

final class ActiveFrameConfigProvider
    extends $FunctionalProvider<FrameConfig?, FrameConfig?, FrameConfig?>
    with $Provider<FrameConfig?> {
  /// 当前激活配置的便捷 Provider
  const ActiveFrameConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeFrameConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeFrameConfigHash();

  @$internal
  @override
  $ProviderElement<FrameConfig?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FrameConfig? create(Ref ref) {
    return activeFrameConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FrameConfig? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FrameConfig?>(value),
    );
  }
}

String _$activeFrameConfigHash() => r'512cff76fa60383b0dd01cd74c882366e59e58ab';

/// 解析器是否启用的便捷 Provider

@ProviderFor(isParserEnabled)
const isParserEnabledProvider = IsParserEnabledProvider._();

/// 解析器是否启用的便捷 Provider

final class IsParserEnabledProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 解析器是否启用的便捷 Provider
  const IsParserEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isParserEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isParserEnabledHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isParserEnabled(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isParserEnabledHash() => r'44fec187fcd0cd6504e6dee81a1ac3c369245bc5';

/// 所有配置列表的便捷 Provider

@ProviderFor(frameConfigs)
const frameConfigsProvider = FrameConfigsProvider._();

/// 所有配置列表的便捷 Provider

final class FrameConfigsProvider
    extends
        $FunctionalProvider<
          List<FrameConfig>,
          List<FrameConfig>,
          List<FrameConfig>
        >
    with $Provider<List<FrameConfig>> {
  /// 所有配置列表的便捷 Provider
  const FrameConfigsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'frameConfigsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$frameConfigsHash();

  @$internal
  @override
  $ProviderElement<List<FrameConfig>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<FrameConfig> create(Ref ref) {
    return frameConfigs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<FrameConfig> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<FrameConfig>>(value),
    );
  }
}

String _$frameConfigsHash() => r'ad1bdbdf7738f6fb3ffb857f4d757d7a20bd1ad2';

/// 最近解析结果的便捷 Provider

@ProviderFor(lastParsedFrame)
const lastParsedFrameProvider = LastParsedFrameProvider._();

/// 最近解析结果的便捷 Provider

final class LastParsedFrameProvider
    extends $FunctionalProvider<ParsedFrame?, ParsedFrame?, ParsedFrame?>
    with $Provider<ParsedFrame?> {
  /// 最近解析结果的便捷 Provider
  const LastParsedFrameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastParsedFrameProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastParsedFrameHash();

  @$internal
  @override
  $ProviderElement<ParsedFrame?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ParsedFrame? create(Ref ref) {
    return lastParsedFrame(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ParsedFrame? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ParsedFrame?>(value),
    );
  }
}

String _$lastParsedFrameHash() => r'da41101015255ab4bd2a81d8fb9164af395f50b0';
