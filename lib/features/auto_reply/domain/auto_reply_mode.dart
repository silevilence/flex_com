/// 自动回复模式枚举
///
/// 定义系统支持的所有自动回复模式类型。
/// 新增回复模式时只需在此枚举添加新值并实现对应的 Handler。
enum AutoReplyMode {
  /// 匹配回复模式
  /// 检测接收数据中的特定特征码，匹配后触发回复
  matchReply,

  /// 顺序回复模式
  /// 每次收到数据后按顺序发送预设列表中的下一帧
  sequentialReply,

  /// 脚本回复模式
  /// 使用 Lua 脚本实现复杂的条件判断应答逻辑
  scriptReply;

  /// UI 显示名称
  String get displayName {
    switch (this) {
      case AutoReplyMode.matchReply:
        return '匹配回复';
      case AutoReplyMode.sequentialReply:
        return '顺序回复';
      case AutoReplyMode.scriptReply:
        return '脚本回复';
    }
  }

  /// 模式描述
  String get description {
    switch (this) {
      case AutoReplyMode.matchReply:
        return '检测到特定数据时自动回复指定内容';
      case AutoReplyMode.sequentialReply:
        return '每次收到数据按顺序回复预设帧列表';
      case AutoReplyMode.scriptReply:
        return '使用 Lua 脚本实现复杂条件判断';
    }
  }
}
