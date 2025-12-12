import 'package:equatable/equatable.dart';
import 'panel_config.dart';

/// 布局状态
class LayoutState extends Equatable {
  const LayoutState({required this.panelLocations, required this.activePanels});

  /// 默认初始状态
  factory LayoutState.initial() {
    return LayoutState(
      panelLocations: {
        for (final config in PanelConfigs.all)
          config.id: config.defaultLocation,
      },
      activePanels: {
        // 初始时左侧显示串口配置
        PanelLocation.left: 'serial',
        // 右侧和底部初始为收起状态
        PanelLocation.right: null,
        PanelLocation.bottom: null,
      },
    );
  }

  /// 每个面板 ID 对应的位置
  final Map<String, PanelLocation> panelLocations;

  /// 每个位置当前激活的面板 ID（null 表示收起）
  final Map<PanelLocation, String?> activePanels;

  /// 获取指定位置当前激活的面板 ID
  String? getActivePanel(PanelLocation location) => activePanels[location];

  /// 获取指定面板的位置
  PanelLocation? getPanelLocation(String panelId) => panelLocations[panelId];

  /// 检查指定面板是否激活
  bool isPanelActive(String panelId) {
    final location = panelLocations[panelId];
    if (location == null) return false;
    return activePanels[location] == panelId;
  }

  /// 检查指定位置是否有激活的面板
  bool isLocationActive(PanelLocation location) =>
      activePanels[location] != null;

  /// 获取指定位置的所有面板
  List<String> getPanelsAt(PanelLocation location) {
    return panelLocations.entries
        .where((e) => e.value == location)
        .map((e) => e.key)
        .toList();
  }

  LayoutState copyWith({
    Map<String, PanelLocation>? panelLocations,
    Map<PanelLocation, String?>? activePanels,
  }) {
    return LayoutState(
      panelLocations: panelLocations ?? this.panelLocations,
      activePanels: activePanels ?? this.activePanels,
    );
  }

  @override
  List<Object?> get props => [panelLocations, activePanels];
}
