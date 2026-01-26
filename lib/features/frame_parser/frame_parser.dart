/// 通用帧协议解析引擎
///
/// 提供可扩展的协议解析框架，支持：
/// - 基于配置的帧结构定义
/// - 字节/位域数据提取
/// - 多种校验算法
/// - JSON 序列化持久化
library;

export 'application/parser_providers.dart';
export 'data/frame_config_repository.dart';
export 'data/generic_frame_parser.dart';
export 'data/parser_registry.dart';
export 'domain/frame_config.dart';
export 'domain/parser_state.dart';
export 'domain/parser_types.dart';
export 'domain/protocol_parser.dart';
export 'presentation/frame_parser_config_dialog.dart';
export 'presentation/frame_parser_panel.dart';
