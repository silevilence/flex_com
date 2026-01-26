import '../domain/protocol_parser.dart';
import 'generic_frame_parser.dart';

/// 协议解析器注册表
///
/// 管理所有可用的协议解析器，采用策略模式
class ParserRegistry {
  ParserRegistry() {
    // 注册内置解析器
    registerParser(const GenericFrameParser());
  }

  final Map<String, IProtocolParser> _parsers = {};

  /// 注册解析器
  void registerParser(IProtocolParser parser) {
    _parsers[parser.name] = parser;
  }

  /// 获取解析器
  IProtocolParser? getParser(String name) {
    return _parsers[name];
  }

  /// 获取默认解析器（通用帧解析器）
  IProtocolParser get defaultParser => const GenericFrameParser();

  /// 获取所有已注册的解析器
  List<IProtocolParser> get allParsers => _parsers.values.toList();

  /// 获取所有解析器名称
  List<String> get parserNames => _parsers.keys.toList();
}
