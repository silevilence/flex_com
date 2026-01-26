import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../settings/application/config_providers.dart';
import '../../settings/data/config_service.dart';
import '../data/frame_config_repository.dart';
import '../data/parser_registry.dart';
import '../domain/frame_config.dart';
import '../domain/parser_state.dart';
import '../domain/parser_types.dart';
import '../domain/protocol_parser.dart';

part 'parser_providers.g.dart';

/// 辅助方法：安全获取 AsyncValue 的值
T? _getValueOrNull<T>(AsyncValue<T> asyncValue) {
  return asyncValue.when(
    data: (data) => data,
    loading: () => null,
    error: (_, __) => null,
  );
}

/// 解析器注册表 Provider
@Riverpod(keepAlive: true)
ParserRegistry parserRegistry(Ref ref) {
  return ParserRegistry();
}

/// 配置仓库 Provider
@Riverpod(keepAlive: true)
FrameConfigRepository frameConfigRepository(Ref ref) {
  return FrameConfigRepository.instance;
}

/// 解析器状态管理
@riverpod
class ParserNotifier extends _$ParserNotifier {
  @override
  Future<ParserState> build() async {
    final repository = ref.read(frameConfigRepositoryProvider);
    final configs = await repository.loadConfigs();

    // 加载保存的状态配置
    final configService = ref.read(configServiceProvider);
    final savedState = await configService.loadParserStateConfig();

    return ParserState(
      configs: configs,
      isEnabled: savedState?.isEnabled ?? false,
      activeConfigId: savedState?.activeConfigId,
    );
  }

  /// 保存解析器状态配置
  Future<void> _saveStateConfig() async {
    final current = _getValueOrNull(state);
    if (current == null) return;

    final configService = ref.read(configServiceProvider);
    final config = ParserStateConfig(
      isEnabled: current.isEnabled,
      activeConfigId: current.activeConfigId,
    );
    await configService.saveParserStateConfig(config);
  }

  /// 添加新配置
  Future<void> addConfig(FrameConfig config) async {
    final current = await future;
    final newConfigs = [...current.configs, config];

    state = AsyncData(current.copyWith(configs: newConfigs));

    final repository = ref.read(frameConfigRepositoryProvider);
    await repository.saveConfigs(newConfigs);
  }

  /// 更新配置
  Future<void> updateConfig(FrameConfig config) async {
    final current = await future;
    final newConfigs = current.configs.map((c) {
      return c.id == config.id ? config : c;
    }).toList();

    state = AsyncData(current.copyWith(configs: newConfigs));

    final repository = ref.read(frameConfigRepositoryProvider);
    await repository.saveConfigs(newConfigs);
  }

  /// 删除配置
  Future<void> deleteConfig(String configId) async {
    final current = await future;
    final newConfigs = current.configs.where((c) => c.id != configId).toList();

    // 如果删除的是当前激活的配置，清除激活状态
    final clearActive = current.activeConfigId == configId;

    state = AsyncData(
      current.copyWith(configs: newConfigs, clearActiveConfigId: clearActive),
    );

    final repository = ref.read(frameConfigRepositoryProvider);
    await repository.saveConfigs(newConfigs);

    // 如果清除了激活配置，保存状态
    if (clearActive) {
      await _saveStateConfig();
    }
  }

  /// 设置激活的配置
  Future<void> setActiveConfig(String? configId) async {
    final current = await future;
    state = AsyncData(
      current.copyWith(
        activeConfigId: configId,
        clearActiveConfigId: configId == null,
      ),
    );
    await _saveStateConfig();
  }

  /// 切换解析器启用状态
  Future<void> toggleEnabled() async {
    final current = await future;
    state = AsyncData(current.copyWith(isEnabled: !current.isEnabled));
    await _saveStateConfig();
  }

  /// 设置解析器启用状态
  Future<void> setEnabled(bool enabled) async {
    final current = await future;
    state = AsyncData(current.copyWith(isEnabled: enabled));
    await _saveStateConfig();
  }

  /// 解析数据
  Future<ParsedFrame?> parseData(List<int> data) async {
    final current = await future;

    if (!current.isEnabled || current.activeConfig == null) {
      return null;
    }

    final parser = ref.read(parserRegistryProvider).defaultParser;
    final result = parser.parse(
      data is Uint8List ? data : Uint8List.fromList(data),
      config: current.activeConfig,
    );

    // 更新最近解析结果
    state = AsyncData(current.copyWith(lastParsedFrame: result));

    return result;
  }

  /// 添加到解析历史
  Future<void> addToHistory(ParsedFrame frame) async {
    final current = await future;
    final newHistory = [...current.parseHistory, frame];
    // 限制历史记录数量
    if (newHistory.length > 100) {
      newHistory.removeAt(0);
    }
    state = AsyncData(current.copyWith(parseHistory: newHistory));
  }

  /// 清空解析历史
  Future<void> clearHistory() async {
    final current = await future;
    state = AsyncData(
      current.copyWith(parseHistory: [], clearLastParsedFrame: true),
    );
  }

  /// 重新加载配置
  Future<void> reloadConfigs() async {
    final repository = ref.read(frameConfigRepositoryProvider);
    final configs = await repository.loadConfigs();
    final current = await future;
    state = AsyncData(current.copyWith(configs: configs));
  }
}

/// 配置编辑器状态管理
@riverpod
class EditorNotifier extends _$EditorNotifier {
  @override
  EditorState build() {
    return const EditorState();
  }

  /// 开始编辑配置（新建或修改）
  void startEditing(FrameConfig? config) {
    if (config == null) {
      // 新建配置
      state = EditorState(
        editingConfig: FrameConfig(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: '新协议配置',
        ),
        isModified: false,
      );
    } else {
      // 编辑现有配置
      state = EditorState(editingConfig: config, isModified: false);
    }
  }

  /// 取消编辑
  void cancelEditing() {
    state = const EditorState();
  }

  /// 更新正在编辑的配置
  void updateEditingConfig(FrameConfig config) {
    state = state.copyWith(editingConfig: config, isModified: true);
  }

  /// 更新配置基本信息
  void updateBasicInfo({
    String? name,
    String? description,
    List<int>? header,
    List<int>? footer,
  }) {
    if (state.editingConfig == null) return;

    state = state.copyWith(
      editingConfig: state.editingConfig!.copyWith(
        name: name,
        description: description,
        header: header,
        footer: footer,
      ),
      isModified: true,
    );
  }

  /// 更新校验配置
  void updateChecksumConfig({
    ChecksumType? checksumType,
    int? checksumStartByte,
    int? checksumEndByte,
    Endianness? checksumEndianness,
  }) {
    if (state.editingConfig == null) return;

    state = state.copyWith(
      editingConfig: state.editingConfig!.copyWith(
        checksumType: checksumType,
        checksumStartByte: checksumStartByte,
        checksumEndByte: checksumEndByte,
        checksumEndianness: checksumEndianness,
      ),
      isModified: true,
    );
  }

  /// 添加字段
  void addField(FieldDefinition field) {
    if (state.editingConfig == null) return;

    final newFields = [...state.editingConfig!.fields, field];
    state = state.copyWith(
      editingConfig: state.editingConfig!.copyWith(fields: newFields),
      isModified: true,
    );
  }

  /// 更新字段
  void updateField(int index, FieldDefinition field) {
    if (state.editingConfig == null) return;
    if (index < 0 || index >= state.editingConfig!.fields.length) return;

    final newFields = [...state.editingConfig!.fields];
    newFields[index] = field;
    state = state.copyWith(
      editingConfig: state.editingConfig!.copyWith(fields: newFields),
      isModified: true,
    );
  }

  /// 删除字段
  void removeField(int index) {
    if (state.editingConfig == null) return;
    if (index < 0 || index >= state.editingConfig!.fields.length) return;

    final newFields = [...state.editingConfig!.fields];
    newFields.removeAt(index);
    state = state.copyWith(
      editingConfig: state.editingConfig!.copyWith(fields: newFields),
      isModified: true,
      clearEditingFieldIndex: state.editingFieldIndex == index,
    );
  }

  /// 移动字段顺序
  void reorderFields(int oldIndex, int newIndex) {
    if (state.editingConfig == null) return;

    final fields = [...state.editingConfig!.fields];
    if (oldIndex < 0 || oldIndex >= fields.length) return;
    if (newIndex < 0 || newIndex > fields.length) return;

    final field = fields.removeAt(oldIndex);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    fields.insert(newIndex, field);

    state = state.copyWith(
      editingConfig: state.editingConfig!.copyWith(fields: fields),
      isModified: true,
    );
  }

  /// 选择要编辑的字段
  void selectField(int? index) {
    state = state.copyWith(
      editingFieldIndex: index,
      clearEditingFieldIndex: index == null,
    );
  }

  /// 标记为已保存
  void markSaved() {
    state = state.copyWith(isModified: false);
  }
}

/// 当前激活配置的便捷 Provider
@riverpod
FrameConfig? activeFrameConfig(Ref ref) {
  final parserState = ref.watch(parserProvider);
  return _getValueOrNull(parserState)?.activeConfig;
}

/// 解析器是否启用的便捷 Provider
@riverpod
bool isParserEnabled(Ref ref) {
  final parserState = ref.watch(parserProvider);
  return _getValueOrNull(parserState)?.isEnabled ?? false;
}

/// 所有配置列表的便捷 Provider
@riverpod
List<FrameConfig> frameConfigs(Ref ref) {
  final parserState = ref.watch(parserProvider);
  return _getValueOrNull(parserState)?.configs ?? [];
}

/// 最近解析结果的便捷 Provider
@riverpod
ParsedFrame? lastParsedFrame(Ref ref) {
  final parserState = ref.watch(parserProvider);
  return _getValueOrNull(parserState)?.lastParsedFrame;
}
