import 'package:flutter/material.dart';

/// 可停靠面板项
class DockablePanelItem {
  const DockablePanelItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.builder,
  });

  /// 唯一标识
  final String id;

  /// 标题
  final String title;

  /// 图标
  final IconData icon;

  /// 内容构建器
  final WidgetBuilder builder;
}

/// 可停靠底部面板
///
/// 提供类似 IDE 的可折叠底部面板，支持多个 Tab 页。
class DockableBottomPanel extends StatefulWidget {
  const DockableBottomPanel({
    super.key,
    required this.items,
    this.expandedHeight = 250,
    this.collapsedHeight = 36,
    this.initialSelectedId,
    this.initialExpanded = false,
    this.onExpandedChanged,
    this.onTabChanged,
  });

  /// 面板项列表
  final List<DockablePanelItem> items;

  /// 展开时的高度
  final double expandedHeight;

  /// 收起时的高度（仅标签栏）
  final double collapsedHeight;

  /// 初始选中的标签 ID
  final String? initialSelectedId;

  /// 是否初始展开
  final bool initialExpanded;

  /// 展开状态变化回调
  final ValueChanged<bool>? onExpandedChanged;

  /// 标签切换回调
  final ValueChanged<String>? onTabChanged;

  @override
  State<DockableBottomPanel> createState() => _DockableBottomPanelState();
}

class _DockableBottomPanelState extends State<DockableBottomPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  late bool _isExpanded;
  late String _selectedId;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialExpanded;
    _selectedId =
        widget.initialSelectedId ??
        (widget.items.isNotEmpty ? widget.items.first.id : '');

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _heightAnimation =
        Tween<double>(
          begin: widget.collapsedHeight,
          end: widget.expandedHeight,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    widget.onExpandedChanged?.call(_isExpanded);
  }

  void _selectTab(String id) {
    if (_selectedId == id) {
      // 点击当前标签时切换展开状态
      _toggleExpanded();
    } else {
      setState(() {
        _selectedId = id;
        if (!_isExpanded) {
          _isExpanded = true;
          _animationController.forward();
          widget.onExpandedChanged?.call(true);
        }
      });
      widget.onTabChanged?.call(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedItem = widget.items.firstWhere(
      (item) => item.id == _selectedId,
      orElse: () => widget.items.first,
    );

    return AnimatedBuilder(
      animation: _heightAnimation,
      builder: (context, child) {
        final currentHeight = _heightAnimation.value;
        final showContent =
            _isExpanded && currentHeight > widget.collapsedHeight + 1;

        return ClipRect(
          child: SizedBox(
            height: currentHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标签栏
                  _buildTabBarContent(context),
                  // 内容区域
                  if (showContent)
                    Expanded(
                      child: ClipRect(child: selectedItem.builder(context)),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBarContent(BuildContext context) {
    return Container(
      height: widget.collapsedHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        children: [
          // Tab 按钮列表
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final isSelected = item.id == _selectedId;
                return _buildTabButton(context, item, isSelected);
              },
            ),
          ),
          // 展开/收起按钮
          SizedBox(
            width: 36,
            height: 36,
            child: IconButton(
              icon: Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_up,
                size: 18,
              ),
              onPressed: _toggleExpanded,
              tooltip: _isExpanded ? '收起面板' : '展开面板',
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context,
    DockablePanelItem item,
    bool isSelected,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectTab(item.id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                size: 16,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                item.title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
