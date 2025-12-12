import 'package:flutter/material.dart';

/// 可折叠侧边栏组件
///
/// 提供类似 IDE 的可折叠侧边栏功能，支持展开/收起动画。
class CollapsibleSidebar extends StatefulWidget {
  const CollapsibleSidebar({
    super.key,
    required this.child,
    this.expandedWidth = 200,
    this.collapsedWidth = 48,
    this.isExpanded = true,
    this.onToggle,
    this.title,
    this.icon,
    this.position = SidebarPosition.left,
  });

  /// 侧边栏内容
  final Widget child;

  /// 展开时的宽度
  final double expandedWidth;

  /// 收起时的宽度
  final double collapsedWidth;

  /// 是否展开
  final bool isExpanded;

  /// 切换回调
  final ValueChanged<bool>? onToggle;

  /// 标题
  final String? title;

  /// 图标
  final IconData? icon;

  /// 侧边栏位置
  final SidebarPosition position;

  @override
  State<CollapsibleSidebar> createState() => _CollapsibleSidebarState();
}

class _CollapsibleSidebarState extends State<CollapsibleSidebar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _widthAnimation =
        Tween<double>(
          begin: widget.collapsedWidth,
          end: widget.expandedWidth,
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
  void didUpdateWidget(CollapsibleSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      _isExpanded = widget.isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    widget.onToggle?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final isLeft = widget.position == SidebarPosition.left;

    return AnimatedBuilder(
      animation: _widthAnimation,
      builder: (context, child) {
        return SizedBox(
          width: _widthAnimation.value,
          child: Column(
            children: [
              // 标题栏
              _buildHeader(context, isLeft),
              // 内容区域
              Expanded(
                child: ClipRect(
                  child: OverflowBox(
                    alignment: isLeft ? Alignment.topLeft : Alignment.topRight,
                    maxWidth: widget.expandedWidth,
                    minWidth: widget.expandedWidth,
                    child: Opacity(
                      opacity: _isExpanded ? 1.0 : 0.0,
                      child: IgnorePointer(
                        ignoring: !_isExpanded,
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isLeft) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          if (!isLeft) _buildToggleButton(context, isLeft),
          if (_isExpanded) ...[
            if (widget.icon != null) ...[
              const SizedBox(width: 8),
              Icon(widget.icon, size: 16),
            ],
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                widget.title ?? '',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          if (isLeft) _buildToggleButton(context, isLeft),
        ],
      ),
    );
  }

  Widget _buildToggleButton(BuildContext context, bool isLeft) {
    final icon = _isExpanded
        ? (isLeft ? Icons.chevron_left : Icons.chevron_right)
        : (isLeft ? Icons.chevron_right : Icons.chevron_left);

    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: _toggle,
        tooltip: _isExpanded ? '收起' : '展开',
        padding: EdgeInsets.zero,
      ),
    );
  }
}

/// 侧边栏位置
enum SidebarPosition { left, right }
