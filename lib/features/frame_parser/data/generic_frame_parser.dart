import 'dart:typed_data';

import '../../checksum_calculator/data/algorithm_strategies.dart';
import '../domain/frame_config.dart';
import '../domain/parser_types.dart';
import '../domain/protocol_parser.dart';

/// 通用帧解析器
///
/// 基于配置的可扩展帧解析器，支持：
/// - 帧头/帧尾识别
/// - 多种校验算法验证
/// - 字节数据提取（支持多种数据类型和端序）
/// - 位域数据提取（支持掩码和位偏移）
class GenericFrameParser implements IProtocolParser {
  const GenericFrameParser();

  @override
  String get name => '通用帧解析器';

  @override
  String get description => '基于配置的通用协议帧解析器，支持自定义帧结构和字段定义';

  @override
  ParsedFrame parse(Uint8List data, {FrameConfig? config}) {
    if (config == null) {
      return ParsedFrame(
        config: const FrameConfig(id: '', name: ''),
        rawData: data,
        fields: [],
        isValid: false,
        errorMessage: '未提供帧配置',
      );
    }

    // 验证帧长度
    final minLen = config.minLength ?? _calculateMinLength(config);
    if (data.length < minLen) {
      return ParsedFrame(
        config: config,
        rawData: data,
        fields: [],
        isValid: false,
        errorMessage: '帧长度不足：期望至少 $minLen 字节，实际 ${data.length} 字节',
      );
    }

    if (config.maxLength != null && data.length > config.maxLength!) {
      return ParsedFrame(
        config: config,
        rawData: data,
        fields: [],
        isValid: false,
        errorMessage: '帧长度超限：期望最多 ${config.maxLength} 字节，实际 ${data.length} 字节',
      );
    }

    // 验证帧头
    if (config.header.isNotEmpty) {
      if (!_matchHeader(data, config.header)) {
        return ParsedFrame(
          config: config,
          rawData: data,
          fields: [],
          isValid: false,
          errorMessage: '帧头不匹配',
        );
      }
    }

    // 验证帧尾
    if (config.footer.isNotEmpty) {
      if (!_matchFooter(data, config.footer)) {
        return ParsedFrame(
          config: config,
          rawData: data,
          fields: [],
          isValid: false,
          errorMessage: '帧尾不匹配',
        );
      }
    }

    // 验证校验位
    bool? checksumValid;
    if (config.checksumType != ChecksumType.none) {
      checksumValid = _validateChecksum(data, config);
    }

    // 解析字段
    final fields = <ParsedField>[];
    String? fieldError;

    for (final fieldDef in config.fields) {
      try {
        final parsedField = _parseField(data, fieldDef);
        fields.add(parsedField);
      } catch (e) {
        fieldError = '解析字段 "${fieldDef.name}" 失败: $e';
        break;
      }
    }

    final isValid =
        fieldError == null && (checksumValid == null || checksumValid);

    return ParsedFrame(
      config: config,
      rawData: data,
      fields: fields,
      isValid: isValid,
      checksumValid: checksumValid,
      errorMessage: fieldError ?? (checksumValid == false ? '校验失败' : null),
    );
  }

  @override
  bool validate(Uint8List data, FrameConfig config) {
    final result = parse(data, config: config);
    return result.isValid;
  }

  @override
  ({int start, int end})? findFrame(Uint8List buffer, FrameConfig config) {
    if (buffer.isEmpty) return null;

    // 如果没有帧头，无法进行帧同步
    if (config.header.isEmpty) {
      return null;
    }

    // 查找帧头
    final headerLen = config.header.length;
    for (var start = 0; start <= buffer.length - headerLen; start++) {
      if (_matchHeader(buffer.sublist(start), config.header)) {
        // 找到帧头，尝试确定帧尾位置
        final minLen = config.minLength ?? _calculateMinLength(config);

        if (config.footer.isNotEmpty) {
          // 有帧尾，查找帧尾
          final footerLen = config.footer.length;
          for (var end = start + minLen; end <= buffer.length; end++) {
            if (end >= footerLen &&
                _matchFooter(buffer.sublist(start, end), config.footer)) {
              return (start: start, end: end);
            }
          }
        } else if (config.maxLength != null) {
          // 无帧尾但有固定长度
          final end = start + config.maxLength!;
          if (end <= buffer.length) {
            return (start: start, end: end);
          }
        } else if (config.minLength != null &&
            config.minLength == _calculateMinLength(config)) {
          // 固定长度帧
          final end = start + config.minLength!;
          if (end <= buffer.length) {
            return (start: start, end: end);
          }
        }
      }
    }

    return null;
  }

  /// 计算最小帧长度
  int _calculateMinLength(FrameConfig config) {
    var len = config.header.length + config.footer.length;
    len += config.checksumType.byteSize;

    // 根据字段定义计算
    for (final field in config.fields) {
      final fieldEnd = field.startByte + field.byteLength;
      if (fieldEnd > len) {
        len = fieldEnd;
      }
    }

    return len;
  }

  /// 匹配帧头
  bool _matchHeader(Uint8List data, List<int> header) {
    if (data.length < header.length) return false;
    for (var i = 0; i < header.length; i++) {
      if (data[i] != header[i]) return false;
    }
    return true;
  }

  /// 匹配帧尾
  bool _matchFooter(Uint8List data, List<int> footer) {
    if (data.length < footer.length) return false;
    final start = data.length - footer.length;
    for (var i = 0; i < footer.length; i++) {
      if (data[start + i] != footer[i]) return false;
    }
    return true;
  }

  /// 验证校验位
  bool _validateChecksum(Uint8List data, FrameConfig config) {
    if (config.checksumType == ChecksumType.none) return true;

    final checksumSize = config.checksumType.byteSize;
    final footerSize = config.footer.length;

    // 校验位在数据末尾、帧尾之前
    final checksumPos = data.length - footerSize - checksumSize;
    if (checksumPos < 0) return false;

    // 计算范围
    final startByte = config.checksumStartByte;
    final endByte = config.checksumEndByte ?? checksumPos;

    if (startByte >= endByte || endByte > data.length) return false;

    final checksumData = data.sublist(startByte, endByte);
    final expectedChecksum = _extractChecksumBytes(
      data,
      checksumPos,
      checksumSize,
      config.checksumEndianness,
    );

    final calculatedChecksum = _calculateChecksum(
      checksumData,
      config.checksumType,
    );

    return _compareBytes(expectedChecksum, calculatedChecksum);
  }

  /// 提取校验位字节
  Uint8List _extractChecksumBytes(
    Uint8List data,
    int position,
    int size,
    Endianness endianness,
  ) {
    final bytes = data.sublist(position, position + size);
    if (endianness == Endianness.little && size > 1) {
      // 转换为大端序以便比较
      return Uint8List.fromList(bytes.reversed.toList());
    }
    return bytes;
  }

  /// 计算校验值
  Uint8List _calculateChecksum(Uint8List data, ChecksumType type) {
    switch (type) {
      case ChecksumType.none:
        return Uint8List(0);
      case ChecksumType.sum8:
        return const Sum8Strategy().calculate(data);
      case ChecksumType.sum16:
        return const Sum16Strategy().calculate(data);
      case ChecksumType.xor8:
        return const Xor8Strategy().calculate(data);
      case ChecksumType.crc8:
        return const Crc8Strategy().calculate(data);
      case ChecksumType.crc16Modbus:
        return const Crc16ModbusStrategy().calculate(data);
      case ChecksumType.crc16Ccitt:
        return const Crc16CcittStrategy().calculate(data);
      case ChecksumType.crc32:
        return const Crc32Strategy().calculate(data);
    }
  }

  /// 比较字节数组
  bool _compareBytes(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// 解析单个字段
  ParsedField _parseField(Uint8List data, FieldDefinition fieldDef) {
    final startByte = fieldDef.startByte;
    final byteLen = fieldDef.byteLength;

    if (startByte + byteLen > data.length) {
      throw RangeError('字段 "${fieldDef.name}" 超出数据范围');
    }

    final rawBytes = Uint8List.fromList(
      data.sublist(startByte, startByte + byteLen),
    );

    dynamic value;
    String? displayValue;

    // 根据数据类型解析值
    switch (fieldDef.dataType) {
      case DataType.uint8:
        value = rawBytes[0];
        if (fieldDef.isBitField) {
          value = _extractBitField(
            value,
            fieldDef.bitMask!,
            fieldDef.bitOffset,
          );
        }
        final scaledValue =
            (value as int) * fieldDef.scaleFactor + fieldDef.offset;
        displayValue = _formatValue(scaledValue, fieldDef.unit);

      case DataType.int8:
        value = rawBytes[0];
        if (value > 127) value = value - 256;
        if (fieldDef.isBitField) {
          value = _extractBitField(
            value,
            fieldDef.bitMask!,
            fieldDef.bitOffset,
          );
        }
        final scaledValue =
            (value as int) * fieldDef.scaleFactor + fieldDef.offset;
        displayValue = _formatValue(scaledValue, fieldDef.unit);

      case DataType.uint16:
        value = _bytesToUint16(rawBytes, fieldDef.endianness);
        if (fieldDef.isBitField) {
          value = _extractBitField(
            value,
            fieldDef.bitMask!,
            fieldDef.bitOffset,
          );
        }
        final scaledValue =
            (value as int) * fieldDef.scaleFactor + fieldDef.offset;
        displayValue = _formatValue(scaledValue, fieldDef.unit);

      case DataType.int16:
        var raw = _bytesToUint16(rawBytes, fieldDef.endianness);
        if (raw > 32767) raw = raw - 65536;
        value = raw;
        if (fieldDef.isBitField) {
          value = _extractBitField(
            value,
            fieldDef.bitMask!,
            fieldDef.bitOffset,
          );
        }
        final scaledValue =
            (value as int) * fieldDef.scaleFactor + fieldDef.offset;
        displayValue = _formatValue(scaledValue, fieldDef.unit);

      case DataType.uint32:
        value = _bytesToUint32(rawBytes, fieldDef.endianness);
        if (fieldDef.isBitField) {
          value = _extractBitField(
            value,
            fieldDef.bitMask!,
            fieldDef.bitOffset,
          );
        }
        final scaledValue =
            (value as int) * fieldDef.scaleFactor + fieldDef.offset;
        displayValue = _formatValue(scaledValue, fieldDef.unit);

      case DataType.int32:
        var raw = _bytesToUint32(rawBytes, fieldDef.endianness);
        if (raw > 2147483647) raw = raw - 4294967296;
        value = raw;
        if (fieldDef.isBitField) {
          value = _extractBitField(
            value,
            fieldDef.bitMask!,
            fieldDef.bitOffset,
          );
        }
        final scaledValue =
            (value as int) * fieldDef.scaleFactor + fieldDef.offset;
        displayValue = _formatValue(scaledValue, fieldDef.unit);

      case DataType.float32:
        value = _bytesToFloat32(rawBytes, fieldDef.endianness);
        final scaledValue =
            (value as double) * fieldDef.scaleFactor + fieldDef.offset;
        displayValue = _formatValue(scaledValue, fieldDef.unit);

      case DataType.float64:
        value = _bytesToFloat64(rawBytes, fieldDef.endianness);
        final scaledValue =
            (value as double) * fieldDef.scaleFactor + fieldDef.offset;
        displayValue = _formatValue(scaledValue, fieldDef.unit);

      case DataType.bytes:
        value = rawBytes;
        displayValue = rawBytes
            .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
            .join(' ');

      case DataType.ascii:
        value = String.fromCharCodes(rawBytes);
        displayValue = value as String;
    }

    return ParsedField(
      definition: fieldDef,
      rawBytes: rawBytes,
      value: value,
      displayValue: displayValue,
    );
  }

  /// 提取位域值
  int _extractBitField(int value, int mask, int? offset) {
    final masked = value & mask;
    return offset != null ? masked >> offset : masked;
  }

  /// 字节转 uint16
  int _bytesToUint16(Uint8List bytes, Endianness endianness) {
    if (endianness == Endianness.big) {
      return (bytes[0] << 8) | bytes[1];
    } else {
      return (bytes[1] << 8) | bytes[0];
    }
  }

  /// 字节转 uint32
  int _bytesToUint32(Uint8List bytes, Endianness endianness) {
    if (endianness == Endianness.big) {
      return (bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3];
    } else {
      return (bytes[3] << 24) | (bytes[2] << 16) | (bytes[1] << 8) | bytes[0];
    }
  }

  /// 字节转 float32
  double _bytesToFloat32(Uint8List bytes, Endianness endianness) {
    final byteData = ByteData.sublistView(bytes);
    return endianness == Endianness.big
        ? byteData.getFloat32(0, Endian.big)
        : byteData.getFloat32(0, Endian.little);
  }

  /// 字节转 float64
  double _bytesToFloat64(Uint8List bytes, Endianness endianness) {
    final byteData = ByteData.sublistView(bytes);
    return endianness == Endianness.big
        ? byteData.getFloat64(0, Endian.big)
        : byteData.getFloat64(0, Endian.little);
  }

  /// 格式化数值显示
  String _formatValue(num value, String unit) {
    String formatted;
    if (value is int) {
      formatted = value.toString();
    } else {
      // 去除多余的小数位
      final doubleVal = value.toDouble();
      if (doubleVal == doubleVal.roundToDouble()) {
        formatted = doubleVal.toInt().toString();
      } else {
        formatted = doubleVal
            .toStringAsFixed(4)
            .replaceAll(RegExp(r'0+$'), '')
            .replaceAll(RegExp(r'\.$'), '');
      }
    }
    return unit.isEmpty ? formatted : '$formatted $unit';
  }
}
