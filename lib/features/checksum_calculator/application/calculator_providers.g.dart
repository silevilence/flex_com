// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculator_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 算法注册表 Provider

@ProviderFor(algorithmRegistry)
const algorithmRegistryProvider = AlgorithmRegistryProvider._();

/// 算法注册表 Provider

final class AlgorithmRegistryProvider
    extends
        $FunctionalProvider<
          AlgorithmRegistry,
          AlgorithmRegistry,
          AlgorithmRegistry
        >
    with $Provider<AlgorithmRegistry> {
  /// 算法注册表 Provider
  const AlgorithmRegistryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'algorithmRegistryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$algorithmRegistryHash();

  @$internal
  @override
  $ProviderElement<AlgorithmRegistry> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AlgorithmRegistry create(Ref ref) {
    return algorithmRegistry(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AlgorithmRegistry value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AlgorithmRegistry>(value),
    );
  }
}

String _$algorithmRegistryHash() => r'4a15a0aeff2e444cd2bf2a560d6ba14dce499136';

/// 计算器状态管理

@ProviderFor(CalculatorNotifier)
const calculatorProvider = CalculatorNotifierProvider._();

/// 计算器状态管理
final class CalculatorNotifierProvider
    extends $NotifierProvider<CalculatorNotifier, CalculatorState> {
  /// 计算器状态管理
  const CalculatorNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calculatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calculatorNotifierHash();

  @$internal
  @override
  CalculatorNotifier create() => CalculatorNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalculatorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalculatorState>(value),
    );
  }
}

String _$calculatorNotifierHash() =>
    r'7cf5d937f0883a3c09d3415020c6f0d9d9e57ae3';

/// 计算器状态管理

abstract class _$CalculatorNotifier extends $Notifier<CalculatorState> {
  CalculatorState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<CalculatorState, CalculatorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CalculatorState, CalculatorState>,
              CalculatorState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// 计算器输入数据的字节预览

@ProviderFor(inputBytesPreview)
const inputBytesPreviewProvider = InputBytesPreviewProvider._();

/// 计算器输入数据的字节预览

final class InputBytesPreviewProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// 计算器输入数据的字节预览
  const InputBytesPreviewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inputBytesPreviewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inputBytesPreviewHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return inputBytesPreview(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$inputBytesPreviewHash() => r'954e2d4a063a4c16c1dd67aa3b58b39d1513390b';

/// 按类别分组的算法列表

@ProviderFor(groupedAlgorithms)
const groupedAlgorithmsProvider = GroupedAlgorithmsProvider._();

/// 按类别分组的算法列表

final class GroupedAlgorithmsProvider
    extends
        $FunctionalProvider<
          Map<AlgorithmCategory, List<AlgorithmType>>,
          Map<AlgorithmCategory, List<AlgorithmType>>,
          Map<AlgorithmCategory, List<AlgorithmType>>
        >
    with $Provider<Map<AlgorithmCategory, List<AlgorithmType>>> {
  /// 按类别分组的算法列表
  const GroupedAlgorithmsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupedAlgorithmsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupedAlgorithmsHash();

  @$internal
  @override
  $ProviderElement<Map<AlgorithmCategory, List<AlgorithmType>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<AlgorithmCategory, List<AlgorithmType>> create(Ref ref) {
    return groupedAlgorithms(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    Map<AlgorithmCategory, List<AlgorithmType>> value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<Map<AlgorithmCategory, List<AlgorithmType>>>(
            value,
          ),
    );
  }
}

String _$groupedAlgorithmsHash() => r'82f2001ce6c7f77ca6b8b3a3a6e0c4763ac2462b';
