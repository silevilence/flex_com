import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../serial/domain/serial_data_entry.dart';
import '../data/command_service.dart';
import '../domain/command.dart';

part 'command_providers.g.dart';

/// 指令服务 Provider
@Riverpod(keepAlive: true)
CommandService commandService(Ref ref) {
  return CommandService();
}

/// 指令列表状态
class CommandListState {
  const CommandListState({
    this.commands = const [],
    this.isLoading = false,
    this.error,
    this.selectedCommandId,
  });

  /// 指令列表
  final List<Command> commands;

  /// 是否正在加载
  final bool isLoading;

  /// 错误信息
  final String? error;

  /// 当前选中的指令 ID
  final String? selectedCommandId;

  /// 获取选中的指令
  Command? get selectedCommand {
    if (selectedCommandId == null) return null;
    try {
      return commands.firstWhere((e) => e.id == selectedCommandId);
    } catch (_) {
      return null;
    }
  }

  CommandListState copyWith({
    List<Command>? commands,
    bool? isLoading,
    String? error,
    String? selectedCommandId,
    bool clearError = false,
    bool clearSelection = false,
  }) {
    return CommandListState(
      commands: commands ?? this.commands,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedCommandId: clearSelection
          ? null
          : (selectedCommandId ?? this.selectedCommandId),
    );
  }
}

/// 指令列表管理器
@Riverpod(keepAlive: true)
class CommandListNotifier extends _$CommandListNotifier {
  @override
  CommandListState build() {
    // 启动时异步加载指令，使用 Future.microtask 确保 build 先返回
    Future.microtask(_loadCommands);
    return const CommandListState(isLoading: true);
  }

  /// 加载指令列表
  Future<void> _loadCommands() async {
    // 此时 state 已经可用
    try {
      final service = ref.read(commandServiceProvider);
      final commands = await service.loadCommands();
      state = state.copyWith(commands: commands, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '加载指令失败: $e');
    }
  }

  /// 刷新指令列表
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _loadCommands();
  }

  /// 添加指令
  Future<bool> addCommand({
    required String name,
    required String data,
    required DataDisplayMode mode,
    String description = '',
  }) async {
    final command = Command.create(
      name: name,
      data: data,
      mode: mode,
      description: description,
    );

    try {
      final service = ref.read(commandServiceProvider);
      final success = await service.addCommand(command);

      if (success) {
        state = state.copyWith(
          commands: [...state.commands, command],
          clearError: true,
        );
        return true;
      } else {
        state = state.copyWith(error: '保存指令失败');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '添加指令失败: $e');
      return false;
    }
  }

  /// 更新指令
  Future<bool> updateCommand(Command command) async {
    try {
      final service = ref.read(commandServiceProvider);
      final success = await service.updateCommand(command);

      if (success) {
        final updatedCommands = state.commands.map((e) {
          return e.id == command.id ? command : e;
        }).toList();

        state = state.copyWith(commands: updatedCommands, clearError: true);
        return true;
      } else {
        state = state.copyWith(error: '更新指令失败');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '更新指令失败: $e');
      return false;
    }
  }

  /// 删除指令
  Future<bool> deleteCommand(String id) async {
    try {
      final service = ref.read(commandServiceProvider);
      final success = await service.deleteCommand(id);

      if (success) {
        final updatedCommands = state.commands
            .where((e) => e.id != id)
            .toList();

        // 如果删除的是当前选中的指令，清除选择
        final shouldClearSelection = state.selectedCommandId == id;

        state = state.copyWith(
          commands: updatedCommands,
          clearError: true,
          clearSelection: shouldClearSelection,
        );
        return true;
      } else {
        state = state.copyWith(error: '删除指令失败');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '删除指令失败: $e');
      return false;
    }
  }

  /// 选择指令
  void selectCommand(String? id) {
    if (id == null) {
      state = state.copyWith(clearSelection: true);
    } else {
      state = state.copyWith(selectedCommandId: id);
    }
  }

  /// 重新排序指令
  Future<bool> reorderCommands(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return true;

    // 先在本地更新状态
    final commands = List<Command>.from(state.commands);
    final command = commands.removeAt(oldIndex);

    // 调整新索引（如果从前面移到后面）
    final adjustedNewIndex = oldIndex < newIndex ? newIndex - 1 : newIndex;
    commands.insert(adjustedNewIndex, command);

    state = state.copyWith(commands: commands);

    // 持久化保存
    try {
      final service = ref.read(commandServiceProvider);
      final success = await service.saveCommands(commands);
      if (!success) {
        // 如果保存失败，回滚
        await _loadCommands();
        return false;
      }
      return true;
    } catch (e) {
      await _loadCommands();
      return false;
    }
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
