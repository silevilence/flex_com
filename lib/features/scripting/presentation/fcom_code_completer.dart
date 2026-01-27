import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';

/// 带描述的代码提示
class DescribedCodePrompt extends CodePrompt {
  /// 说明文本
  final String description;

  /// 方法签名（仅方法类型需要）
  final String? signature;

  const DescribedCodePrompt({
    required super.word,
    required this.description,
    this.signature,
  });

  @override
  CodeAutocompleteResult get autocomplete =>
      CodeAutocompleteResult.fromWord(word);

  @override
  bool match(String input) {
    return word.toLowerCase().startsWith(input.toLowerCase());
  }
}

/// 带描述的关键字提示
class DescribedKeywordPrompt extends DescribedCodePrompt {
  const DescribedKeywordPrompt({
    required super.word,
    required super.description,
  });
}

/// 带描述的字段提示
class DescribedFieldPrompt extends DescribedCodePrompt {
  final String type;

  const DescribedFieldPrompt({
    required super.word,
    required this.type,
    required super.description,
  });
}

/// 带描述的函数提示
class DescribedFunctionPrompt extends DescribedCodePrompt {
  final String returnType;
  final Map<String, String> parameters;

  const DescribedFunctionPrompt({
    required super.word,
    required this.returnType,
    this.parameters = const {},
    required super.description,
    super.signature,
  });
}

/// FCom API 代码补全提示构建器
///
/// 为脚本编辑器提供 FCom API 和 Lua 关键字的自动补全功能
class FComCodePromptsBuilder extends CodeAutocompletePromptsBuilder {
  @override
  CodeAutocompleteEditingValue? build(
    BuildContext context,
    CodeLine codeLine,
    CodeLineSelection selection,
  ) {
    // 获取光标位置的单词
    final text = codeLine.text;
    final cursorOffset = selection.extentOffset;

    // 找到光标前的单词边界（不包含点号）
    int wordStart = cursorOffset;
    while (wordStart > 0 && _isWordChar(text[wordStart - 1])) {
      wordStart--;
    }

    // 当前输入的单词
    final currentWord = text.substring(wordStart, cursorOffset);

    // 如果光标前有点号，检查是否是 FCom. 或 FCom.input.
    if (wordStart > 0 && text[wordStart - 1] == '.') {
      final dotOffset = wordStart - 1;
      // 查找点号前的标识符
      int prefixStart = dotOffset;
      while (prefixStart > 0 && _isWordChar(text[prefixStart - 1])) {
        prefixStart--;
      }
      final prefix = text.substring(prefixStart, dotOffset);

      // 检查是否是 FCom.input.
      if (prefix == 'input' && prefixStart >= 5) {
        final beforeInput = text.substring(0, prefixStart);
        if (beforeInput.endsWith('FCom.')) {
          return _buildPrompts(currentWord, _fcomInputFields);
        }
      }

      // 检查是否是 FCom.
      if (prefix == 'FCom') {
        return _buildPrompts(currentWord, _fcomApis);
      }
    }

    // 普通关键字补全（需要至少输入一个字符）
    if (currentWord.isNotEmpty) {
      return _buildPrompts(currentWord, _allKeywords);
    }

    return null;
  }

  bool _isWordChar(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 65 && code <= 90) || // A-Z
        (code >= 97 && code <= 122) || // a-z
        (code >= 48 && code <= 57) || // 0-9
        code == 95; // _
  }

  CodeAutocompleteEditingValue? _buildPrompts(
    String input,
    List<CodePrompt> candidates,
  ) {
    // 如果输入为空，显示所有候选项（用于 FCom. 后立即显示）
    final matched = input.isEmpty
        ? candidates
        : candidates.where((p) => p.match(input)).toList();
    if (matched.isEmpty) {
      return null;
    }
    return CodeAutocompleteEditingValue(
      input: input,
      prompts: matched,
      index: 0,
    );
  }

  /// FCom API 方法列表
  static final List<CodePrompt> _fcomApis = [
    // === 基础通信 API ===
    const DescribedFunctionPrompt(
      word: 'send',
      returnType: 'void',
      parameters: {'data': 'string|table'},
      description: '发送数据到串口',
      signature: 'send(data: string|table)',
    ),
    const DescribedFunctionPrompt(
      word: 'log',
      returnType: 'void',
      parameters: {'message': 'string', 'level?': 'string'},
      description: '输出日志到控制台',
      signature:
          'log(message: string, level?: "info"|"warning"|"error"|"debug")',
    ),
    const DescribedFunctionPrompt(
      word: 'delay',
      returnType: 'void',
      parameters: {'ms': 'number'},
      description: '延迟指定毫秒（仅做标记，不阻塞）',
      signature: 'delay(ms: number)',
    ),

    // === 校验计算 API ===
    const DescribedFunctionPrompt(
      word: 'crc16',
      returnType: 'string',
      parameters: {'data': 'string'},
      description: '计算 CRC16 校验值（Modbus）',
      signature: 'crc16(data: string) → string',
    ),
    const DescribedFunctionPrompt(
      word: 'crc32',
      returnType: 'string',
      parameters: {'data': 'string'},
      description: '计算 CRC32 校验值',
      signature: 'crc32(data: string) → string',
    ),
    const DescribedFunctionPrompt(
      word: 'checksum',
      returnType: 'string',
      parameters: {'data': 'string'},
      description: '计算累加和校验值（8位）',
      signature: 'checksum(data: string) → string',
    ),

    // === 工具函数 ===
    const DescribedFunctionPrompt(
      word: 'getTimestamp',
      returnType: 'number',
      description: '获取当前 Unix 时间戳（毫秒）',
      signature: 'getTimestamp() → number',
    ),
    const DescribedFunctionPrompt(
      word: 'hexToBytes',
      returnType: 'table',
      parameters: {'hex': 'string'},
      description: 'Hex 字符串转字节数组',
      signature: 'hexToBytes(hex: string) → table',
    ),
    const DescribedFunctionPrompt(
      word: 'bytesToHex',
      returnType: 'string',
      parameters: {'bytes': 'table'},
      description: '字节数组转 Hex 字符串',
      signature: 'bytesToHex(bytes: table) → string',
    ),

    // === 输入数据 ===
    const DescribedFieldPrompt(
      word: 'input',
      type: 'table',
      description: '当前输入数据对象，包含 raw/hex/length/isRx',
    ),

    // === Hook 专用 API ===
    const DescribedFunctionPrompt(
      word: 'setResponse',
      returnType: 'void',
      parameters: {'data': 'string|table'},
      description: '[Reply Hook] 设置自动回复的响应数据',
      signature: 'setResponse(data: string|table)',
    ),
    const DescribedFunctionPrompt(
      word: 'setProcessedData',
      returnType: 'void',
      parameters: {'data': 'string|table'},
      description: '[Pipeline Hook] 设置处理后的数据',
      signature: 'setProcessedData(data: string|table)',
    ),
    const DescribedFunctionPrompt(
      word: 'skipReply',
      returnType: 'void',
      description: '[Reply Hook] 跳过本次自动回复',
      signature: 'skipReply()',
    ),
    const DescribedFunctionPrompt(
      word: 'getData',
      returnType: 'table',
      description: '获取输入数据（等同于 FCom.input）',
      signature: 'getData() → table',
    ),
  ];

  /// FCom.input 字段列表
  static final List<CodePrompt> _fcomInputFields = [
    const DescribedFieldPrompt(
      word: 'raw',
      type: 'table',
      description: '原始字节数组，Lua 索引从 1 开始',
    ),
    const DescribedFieldPrompt(
      word: 'hex',
      type: 'string',
      description: '十六进制字符串表示（大写，无空格）',
    ),
    const DescribedFieldPrompt(
      word: 'length',
      type: 'number',
      description: '数据长度（字节数）',
    ),
    const DescribedFieldPrompt(
      word: 'isRx',
      type: 'boolean',
      description: '是否为接收数据（true=接收, false=发送）',
    ),
  ];

  /// 所有关键字（Lua 关键字 + FCom 入口）
  static final List<CodePrompt> _allKeywords = [
    // FCom 入口
    const DescribedFieldPrompt(
      word: 'FCom',
      type: 'table',
      description: 'FlexCom 脚本 API 入口对象',
    ),

    // Lua 关键字
    const DescribedKeywordPrompt(word: 'if', description: '条件判断'),
    const DescribedKeywordPrompt(word: 'then', description: '条件判断体开始'),
    const DescribedKeywordPrompt(word: 'else', description: '否则分支'),
    const DescribedKeywordPrompt(word: 'elseif', description: '否则如果'),
    const DescribedKeywordPrompt(word: 'end', description: '代码块结束'),
    const DescribedKeywordPrompt(word: 'for', description: '循环'),
    const DescribedKeywordPrompt(word: 'while', description: 'while 循环'),
    const DescribedKeywordPrompt(word: 'do', description: '循环体开始'),
    const DescribedKeywordPrompt(
      word: 'repeat',
      description: 'repeat-until 循环',
    ),
    const DescribedKeywordPrompt(word: 'until', description: 'repeat 循环条件'),
    const DescribedKeywordPrompt(word: 'break', description: '跳出循环'),
    const DescribedKeywordPrompt(word: 'return', description: '返回值'),
    const DescribedKeywordPrompt(word: 'local', description: '局部变量声明'),
    const DescribedKeywordPrompt(word: 'function', description: '函数定义'),
    const DescribedKeywordPrompt(word: 'and', description: '逻辑与'),
    const DescribedKeywordPrompt(word: 'or', description: '逻辑或'),
    const DescribedKeywordPrompt(word: 'not', description: '逻辑非'),
    const DescribedKeywordPrompt(word: 'nil', description: '空值'),
    const DescribedKeywordPrompt(word: 'true', description: '布尔真'),
    const DescribedKeywordPrompt(word: 'false', description: '布尔假'),
    const DescribedKeywordPrompt(word: 'in', description: '泛型 for 循环'),

    // 常用内置函数
    const DescribedFunctionPrompt(
      word: 'print',
      returnType: 'void',
      parameters: {'...': 'any'},
      description: '打印输出',
      signature: 'print(...)',
    ),
    const DescribedFunctionPrompt(
      word: 'type',
      returnType: 'string',
      parameters: {'v': 'any'},
      description: '获取值的类型',
      signature: 'type(v) → string',
    ),
    const DescribedFunctionPrompt(
      word: 'tostring',
      returnType: 'string',
      parameters: {'v': 'any'},
      description: '转换为字符串',
      signature: 'tostring(v) → string',
    ),
    const DescribedFunctionPrompt(
      word: 'tonumber',
      returnType: 'number',
      parameters: {'v': 'any'},
      description: '转换为数字',
      signature: 'tonumber(v) → number|nil',
    ),
    const DescribedFunctionPrompt(
      word: 'pairs',
      returnType: 'function',
      parameters: {'t': 'table'},
      description: '遍历表的所有键值对',
      signature: 'pairs(t) → iterator',
    ),
    const DescribedFunctionPrompt(
      word: 'ipairs',
      returnType: 'function',
      parameters: {'t': 'table'},
      description: '遍历表的数组部分（从索引1开始）',
      signature: 'ipairs(t) → iterator',
    ),
    const DescribedFunctionPrompt(
      word: 'next',
      returnType: 'any',
      parameters: {'t': 'table', 'index?': 'any'},
      description: '获取表的下一个键值对',
      signature: 'next(t, index?) → key, value',
    ),
    const DescribedFunctionPrompt(
      word: 'select',
      returnType: 'any',
      parameters: {'n': 'number|"#"', '...': 'any'},
      description: '选择可变参数中的部分',
      signature: 'select(n, ...) → ...',
    ),
    const DescribedFunctionPrompt(
      word: 'unpack',
      returnType: 'any',
      parameters: {'t': 'table'},
      description: '展开表为多个返回值',
      signature: 'unpack(t) → ...',
    ),
    const DescribedFunctionPrompt(
      word: 'pcall',
      returnType: 'boolean',
      parameters: {'f': 'function', '...': 'any'},
      description: '保护模式调用函数',
      signature: 'pcall(f, ...) → success, result|error',
    ),
    const DescribedFunctionPrompt(
      word: 'error',
      returnType: 'void',
      parameters: {'msg': 'string'},
      description: '抛出错误',
      signature: 'error(msg)',
    ),
    const DescribedFunctionPrompt(
      word: 'assert',
      returnType: 'any',
      parameters: {'v': 'any', 'msg?': 'string'},
      description: '断言，v 为假时抛出错误',
      signature: 'assert(v, msg?) → v',
    ),
  ];
}

/// 自动补全弹窗组件
class FComAutocompleteView extends StatefulWidget
    implements PreferredSizeWidget {
  static const double kItemHeight = 52; // 增加高度以显示说明
  static const double kMaxWidth = 420;
  static const double kMaxHeight = 260;

  const FComAutocompleteView({
    super.key,
    required this.notifier,
    required this.onSelected,
  });

  final ValueNotifier<CodeAutocompleteEditingValue> notifier;
  final ValueChanged<CodeAutocompleteResult> onSelected;

  @override
  Size get preferredSize {
    final count = notifier.value.prompts.length;
    // 2 是边框大小，8 是内边距
    final height = (kItemHeight * count + 10).clamp(0.0, kMaxHeight);
    return Size(kMaxWidth, height);
  }

  @override
  State<FComAutocompleteView> createState() => _FComAutocompleteViewState();
}

class _FComAutocompleteViewState extends State<FComAutocompleteView> {
  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_onValueChanged);
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onValueChanged);
    super.dispose();
  }

  void _onValueChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final value = widget.notifier.value;
    final prompts = value.prompts;

    if (prompts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: BoxConstraints.loose(widget.preferredSize),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: prompts.length,
          itemBuilder: (context, index) {
            final prompt = prompts[index];
            final isSelected = index == value.index;
            return _AutocompleteItem(
              prompt: prompt,
              isSelected: isSelected,
              onTap: () =>
                  widget.onSelected(value.copyWith(index: index).autocomplete),
            );
          },
        ),
      ),
    );
  }
}

/// 构建自动补全视图
PreferredSizeWidget buildAutocompleteView(
  BuildContext context,
  ValueNotifier<CodeAutocompleteEditingValue> notifier,
  ValueChanged<CodeAutocompleteResult> onSelected,
) {
  return FComAutocompleteView(notifier: notifier, onSelected: onSelected);
}

class _AutocompleteItem extends StatefulWidget {
  const _AutocompleteItem({
    required this.prompt,
    required this.isSelected,
    required this.onTap,
  });

  final CodePrompt prompt;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_AutocompleteItem> createState() => _AutocompleteItemState();
}

class _AutocompleteItemState extends State<_AutocompleteItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isHighlighted = widget.isSelected || _isHovered;
    final prompt = widget.prompt;

    // 根据类型获取图标和颜色
    IconData icon;
    Color iconColor;
    String? typeText;
    String? description;
    String? signature;

    if (prompt is DescribedKeywordPrompt) {
      icon = Icons.code;
      iconColor = const Color(0xFF569CD6);
      typeText = 'keyword';
      description = prompt.description;
    } else if (prompt is DescribedFunctionPrompt) {
      icon = Icons.functions;
      iconColor = const Color(0xFFDCDCAA);
      typeText = prompt.returnType;
      description = prompt.description;
      signature = prompt.signature;
    } else if (prompt is DescribedFieldPrompt) {
      icon = Icons.data_object;
      iconColor = const Color(0xFF9CDCFE);
      typeText = prompt.type;
      description = prompt.description;
    } else if (prompt is CodeKeywordPrompt) {
      icon = Icons.code;
      iconColor = const Color(0xFF569CD6);
      typeText = 'keyword';
    } else if (prompt is CodeFunctionPrompt) {
      icon = Icons.functions;
      iconColor = const Color(0xFFDCDCAA);
      typeText = prompt.type;
    } else if (prompt is CodeFieldPrompt) {
      icon = Icons.data_object;
      iconColor = const Color(0xFF9CDCFE);
      typeText = prompt.type;
    } else {
      icon = Icons.code;
      iconColor = colorScheme.onSurface;
    }

    // 显示名称：如果有签名则显示签名，否则显示 word
    final displayName = signature ?? prompt.word;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: FComAutocompleteView.kItemHeight,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          color: isHighlighted
              ? colorScheme.primary.withAlpha(30)
              : Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Consolas, Monaco, monospace',
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (typeText != null)
                          Text(
                            typeText,
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
