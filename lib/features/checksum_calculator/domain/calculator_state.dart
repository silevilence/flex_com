import 'package:equatable/equatable.dart';

import 'algorithm_strategy.dart';
import 'algorithm_type.dart';

/// 输入数据格式
enum InputFormat {
  /// 十六进制格式
  hex,

  /// ASCII 文本格式
  ascii,
}

/// 计算器状态
class CalculatorState extends Equatable {
  const CalculatorState({
    this.inputText = '',
    this.inputFormat = InputFormat.hex,
    this.selectedAlgorithmId = 'crc16_modbus',
    this.result,
    this.errorMessage,
  });

  /// 输入文本
  final String inputText;

  /// 输入格式
  final InputFormat inputFormat;

  /// 选中的算法 ID
  final String selectedAlgorithmId;

  /// 计算结果
  final AlgorithmResult? result;

  /// 错误消息
  final String? errorMessage;

  /// 获取当前选中的算法类型
  AlgorithmType? get selectedAlgorithmType =>
      AlgorithmTypes.findById(selectedAlgorithmId);

  /// 是否有有效的输入
  bool get hasValidInput => inputText.isNotEmpty && errorMessage == null;

  /// 是否有计算结果
  bool get hasResult => result != null;

  CalculatorState copyWith({
    String? inputText,
    InputFormat? inputFormat,
    String? selectedAlgorithmId,
    AlgorithmResult? result,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return CalculatorState(
      inputText: inputText ?? this.inputText,
      inputFormat: inputFormat ?? this.inputFormat,
      selectedAlgorithmId: selectedAlgorithmId ?? this.selectedAlgorithmId,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    inputText,
    inputFormat,
    selectedAlgorithmId,
    result?.hexString,
    errorMessage,
  ];
}
