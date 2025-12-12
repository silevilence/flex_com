import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/layout_state.dart';
import '../domain/panel_config.dart';

part 'layout_providers.g.dart';

/// 布局状态管理 Notifier
@Riverpod(keepAlive: true)
class LayoutNotifier extends _$LayoutNotifier {
  @override
  LayoutState build() => LayoutState.initial();

  /// 切换面板显示状态
  ///
  /// 如果该面板当前已激活，则收起；否则展开并切换到该面板
  void togglePanel(String panelId) {
    final location = state.panelLocations[panelId];
    if (location == null) return;

    final currentActive = state.activePanels[location];
    final newActivePanels = Map<PanelLocation, String?>.from(
      state.activePanels,
    );

    if (currentActive == panelId) {
      // 当前面板已激活，收起
      newActivePanels[location] = null;
    } else {
      // 展开并切换到该面板
      newActivePanels[location] = panelId;
    }

    state = state.copyWith(activePanels: newActivePanels);
  }

  /// 激活指定面板（不切换，仅激活）
  void activatePanel(String panelId) {
    final location = state.panelLocations[panelId];
    if (location == null) return;

    final currentActive = state.activePanels[location];
    if (currentActive == panelId) return;

    final newActivePanels = Map<PanelLocation, String?>.from(
      state.activePanels,
    );
    newActivePanels[location] = panelId;
    state = state.copyWith(activePanels: newActivePanels);
  }

  /// 收起指定位置的面板
  void collapseLocation(PanelLocation location) {
    if (state.activePanels[location] == null) return;

    final newActivePanels = Map<PanelLocation, String?>.from(
      state.activePanels,
    );
    newActivePanels[location] = null;
    state = state.copyWith(activePanels: newActivePanels);
  }

  /// 移动面板到指定位置
  void movePanel(String panelId, PanelLocation newLocation) {
    final config = PanelConfigs.getById(panelId);
    if (config == null || !config.isMovable) return;

    final oldLocation = state.panelLocations[panelId];
    if (oldLocation == newLocation) return;

    // 更新面板位置
    final newPanelLocations = Map<String, PanelLocation>.from(
      state.panelLocations,
    );
    newPanelLocations[panelId] = newLocation;

    // 更新激活状态
    final newActivePanels = Map<PanelLocation, String?>.from(
      state.activePanels,
    );

    // 如果该面板在旧位置是激活状态，需要处理
    if (oldLocation != null && state.activePanels[oldLocation] == panelId) {
      // 查找旧位置的其他面板
      final otherPanels = state.panelLocations.entries
          .where((e) => e.value == oldLocation && e.key != panelId)
          .map((e) => e.key)
          .toList();

      // 旧位置设为 null 或切换到其他面板
      newActivePanels[oldLocation] = otherPanels.isNotEmpty
          ? otherPanels.first
          : null;
    }

    // 新位置激活该面板
    newActivePanels[newLocation] = panelId;

    state = state.copyWith(
      panelLocations: newPanelLocations,
      activePanels: newActivePanels,
    );
  }

  /// 重置布局到默认状态
  void resetLayout() {
    state = LayoutState.initial();
  }
}
