/// 数据可视化模块
///
/// 提供实时示波器功能，支持：
/// - 与协议解析引擎联动，从解析字段中选择数据源
/// - 多通道实时波形显示
/// - 暂停/继续、X/Y 轴缩放、十字游标测量
library;

export 'application/visualization_providers.dart';
export 'domain/chart_types.dart';
export 'domain/oscilloscope_state.dart';
export 'presentation/channel_config_dialog.dart';
export 'presentation/oscilloscope_panel.dart';
