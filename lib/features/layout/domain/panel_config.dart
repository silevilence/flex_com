import 'package:flutter/material.dart';

/// 面板位置枚举
enum PanelLocation {
  left,
  right,
  bottom;

  String get displayName {
    switch (this) {
      case PanelLocation.left:
        return '左侧';
      case PanelLocation.right:
        return '右侧';
      case PanelLocation.bottom:
        return '底部';
    }
  }
}

/// 面板配置
class PanelConfig {
  const PanelConfig({
    required this.id,
    required this.title,
    required this.icon,
    required this.defaultLocation,
    this.isMovable = true,
  });

  /// 面板唯一标识
  final String id;

  /// 面板标题
  final String title;

  /// 面板图标
  final IconData icon;

  /// 默认位置
  final PanelLocation defaultLocation;

  /// 是否可移动（串口配置固定在左侧）
  final bool isMovable;
}

/// 预定义的面板配置
class PanelConfigs {
  PanelConfigs._();

  /// 连接配置面板（固定在左侧）
  static const serial = PanelConfig(
    id: 'serial',
    title: '连接配置',
    icon: Icons.settings_ethernet,
    defaultLocation: PanelLocation.left,
    isMovable: false,
  );

  /// 指令列表面板
  static const commands = PanelConfig(
    id: 'commands',
    title: '指令列表',
    icon: Icons.list_alt,
    defaultLocation: PanelLocation.right,
  );

  /// 自动回复面板
  static const autoReply = PanelConfig(
    id: 'autoReply',
    title: '自动回复',
    icon: Icons.reply_all,
    defaultLocation: PanelLocation.right,
  );

  /// 脚本控制面板
  static const scripts = PanelConfig(
    id: 'scripts',
    title: '脚本控制',
    icon: Icons.code,
    defaultLocation: PanelLocation.bottom,
  );

  /// 波形图面板
  static const chart = PanelConfig(
    id: 'chart',
    title: '波形图',
    icon: Icons.show_chart,
    defaultLocation: PanelLocation.bottom,
  );

  /// 协议解析器面板
  static const frameParser = PanelConfig(
    id: 'frameParser',
    title: '协议解析',
    icon: Icons.settings_input_component,
    defaultLocation: PanelLocation.right,
  );

  /// 所有面板配置列表
  static const List<PanelConfig> all = [
    serial,
    commands,
    autoReply,
    scripts,
    chart,
    frameParser,
  ];

  /// 根据 ID 获取面板配置
  static PanelConfig? getById(String id) {
    try {
      return all.firstWhere((config) => config.id == id);
    } catch (_) {
      return null;
    }
  }
}
