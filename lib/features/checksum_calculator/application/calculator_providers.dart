import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/hex_utils.dart';
import '../data/algorithm_strategies.dart';
import '../domain/algorithm_strategy.dart';
import '../domain/algorithm_type.dart';
import '../domain/calculator_state.dart';

part 'calculator_providers.g.dart';

/// 算法注册表 Provider
@Riverpod(keepAlive: true)
AlgorithmRegistry algorithmRegistry(Ref ref) {
  return AlgorithmRegistry();
}

/// 计算器状态管理
@riverpod
class CalculatorNotifier extends _$CalculatorNotifier {
  @override
  CalculatorState build() {
    return const CalculatorState();
  }

  /// 设置输入文本
  void setInputText(String text) {
    state = state.copyWith(
      inputText: text,
      clearResult: true,
      clearError: true,
    );
  }

  /// 设置输入格式
  void setInputFormat(InputFormat format) {
    state = state.copyWith(
      inputFormat: format,
      clearResult: true,
      clearError: true,
    );
  }

  /// 切换格式并自动转换数据
  void switchFormatAndConvert(InputFormat newFormat) {
    if (state.inputFormat == newFormat) return;

    final currentText = state.inputText;
    String convertedText = '';

    if (currentText.isNotEmpty) {
      try {
        if (newFormat == InputFormat.ascii) {
          // Hex -> ASCII
          final bytes = HexUtils.hexStringToBytes(currentText);
          convertedText = String.fromCharCodes(bytes);
        } else {
          // ASCII -> Hex
          final bytes = HexUtils.asciiStringToBytes(currentText);
          convertedText = HexUtils.bytesToHexString(bytes);
        }
      } catch (_) {
        // 转换失败时保留原文本
        convertedText = currentText;
      }
    }

    state = state.copyWith(
      inputFormat: newFormat,
      inputText: convertedText,
      clearResult: true,
      clearError: true,
    );
  }

  /// 设置选中的算法
  void setAlgorithm(String algorithmId) {
    state = state.copyWith(selectedAlgorithmId: algorithmId, clearResult: true);
  }

  /// 执行计算
  void calculate() {
    if (state.inputText.isEmpty) {
      state = state.copyWith(errorMessage: '请输入数据', clearResult: true);
      return;
    }

    // 转换输入为字节数组
    Uint8List data;
    try {
      data = _parseInput(state.inputText, state.inputFormat);
    } on FormatException catch (e) {
      state = state.copyWith(errorMessage: e.message, clearResult: true);
      return;
    }

    // 获取算法策略
    final registry = ref.read(algorithmRegistryProvider);
    final strategy = registry.getStrategy(state.selectedAlgorithmId);

    if (strategy == null) {
      state = state.copyWith(errorMessage: '未知的算法类型', clearResult: true);
      return;
    }

    // 执行计算
    final rawBytes = strategy.calculate(data);
    final hexString = strategy.formatResult(rawBytes);

    state = state.copyWith(
      result: AlgorithmResult(
        type: strategy.type,
        rawBytes: rawBytes,
        hexString: hexString,
      ),
      clearError: true,
    );
  }

  /// 清空所有内容
  void clear() {
    state = const CalculatorState();
  }

  /// 从发送帧导入数据
  void importFromSendFrame(String hexData) {
    state = state.copyWith(
      inputText: hexData,
      inputFormat: InputFormat.hex,
      clearResult: true,
      clearError: true,
    );
  }

  /// 解析输入数据
  Uint8List _parseInput(String text, InputFormat format) {
    switch (format) {
      case InputFormat.hex:
        return HexUtils.hexStringToBytes(text);
      case InputFormat.ascii:
        return HexUtils.asciiStringToBytes(text);
    }
  }
}

/// 计算器输入数据的字节预览
@riverpod
String inputBytesPreview(Ref ref) {
  final state = ref.watch(calculatorProvider);

  if (state.inputText.isEmpty) {
    return '';
  }

  try {
    Uint8List bytes;
    if (state.inputFormat == InputFormat.hex) {
      bytes = HexUtils.hexStringToBytes(state.inputText);
    } else {
      bytes = HexUtils.asciiStringToBytes(state.inputText);
    }

    // 返回格式化的预览
    final length = bytes.length;
    final hexPreview = HexUtils.bytesToHexString(bytes);

    return '$length 字节: $hexPreview';
  } catch (e) {
    return '输入格式错误';
  }
}

/// 按类别分组的算法列表
@riverpod
Map<AlgorithmCategory, List<AlgorithmType>> groupedAlgorithms(Ref ref) {
  final result = <AlgorithmCategory, List<AlgorithmType>>{};

  for (final category in AlgorithmCategory.values) {
    result[category] = AlgorithmTypes.byCategory(category);
  }

  return result;
}
