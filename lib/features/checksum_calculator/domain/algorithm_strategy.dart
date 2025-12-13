import 'dart:typed_data';

import 'algorithm_type.dart';

/// 算法策略接口
///
/// 所有校验和、CRC、摘要算法都需实现此接口
abstract interface class AlgorithmStrategy {
  /// 算法类型标识
  AlgorithmType get type;

  /// 计算校验/摘要值
  ///
  /// 返回计算结果的字节数组
  Uint8List calculate(Uint8List data);

  /// 将结果格式化为十六进制字符串
  String formatResult(Uint8List result, {bool uppercase = true});
}

/// 算法结果
class AlgorithmResult {
  const AlgorithmResult({
    required this.type,
    required this.rawBytes,
    required this.hexString,
  });

  /// 算法类型
  final AlgorithmType type;

  /// 原始字节结果
  final Uint8List rawBytes;

  /// 十六进制字符串结果
  final String hexString;
}
