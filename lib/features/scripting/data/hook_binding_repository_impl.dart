import '../domain/script_hook.dart';
import 'hook_binding_data_source.dart';

/// Hook 绑定仓库接口
abstract class IHookBindingRepository {
  /// 获取所有绑定
  Future<List<ScriptHookBinding>> getAllBindings();

  /// 保存绑定
  Future<void> saveBinding(ScriptHookBinding binding);

  /// 删除绑定
  Future<void> deleteBinding(String bindingId);

  /// 根据脚本 ID 获取绑定
  Future<List<ScriptHookBinding>> getBindingsByScriptId(String scriptId);

  /// 根据 Hook 类型获取启用的绑定（按优先级排序）
  Future<List<ScriptHookBinding>> getEnabledBindingsByHookType(
    HookType hookType,
  );

  /// 根据 Hook 类型获取所有绑定
  Future<List<ScriptHookBinding>> getBindingsByHookType(HookType hookType);

  /// 更新绑定启用状态
  Future<void> updateBindingEnabled(String bindingId, bool enabled);

  /// 更新绑定优先级
  Future<void> updateBindingPriority(String bindingId, int priority);

  /// 删除脚本相关的所有绑定
  Future<void> deleteBindingsByScriptId(String scriptId);
}

/// Hook 绑定仓库实现
class HookBindingRepositoryImpl implements IHookBindingRepository {
  final IHookBindingDataSource _dataSource;

  HookBindingRepositoryImpl(this._dataSource);

  @override
  Future<List<ScriptHookBinding>> getAllBindings() {
    return _dataSource.getAllBindings();
  }

  @override
  Future<void> saveBinding(ScriptHookBinding binding) {
    return _dataSource.saveBinding(binding);
  }

  @override
  Future<void> deleteBinding(String bindingId) {
    return _dataSource.deleteBinding(bindingId);
  }

  @override
  Future<List<ScriptHookBinding>> getBindingsByScriptId(String scriptId) {
    return _dataSource.getBindingsByScriptId(scriptId);
  }

  @override
  Future<List<ScriptHookBinding>> getEnabledBindingsByHookType(
    HookType hookType,
  ) async {
    final bindings = await _dataSource.getBindingsByHookType(hookType);
    return bindings.where((b) => b.enabled).toList();
  }

  @override
  Future<List<ScriptHookBinding>> getBindingsByHookType(HookType hookType) {
    return _dataSource.getBindingsByHookType(hookType);
  }

  @override
  Future<void> updateBindingEnabled(String bindingId, bool enabled) async {
    final bindings = await _dataSource.getAllBindings();
    final index = bindings.indexWhere((b) => b.id == bindingId);
    if (index >= 0) {
      bindings[index] = bindings[index].copyWith(enabled: enabled);
      await _dataSource.saveAllBindings(bindings);
    }
  }

  @override
  Future<void> updateBindingPriority(String bindingId, int priority) async {
    final bindings = await _dataSource.getAllBindings();
    final index = bindings.indexWhere((b) => b.id == bindingId);
    if (index >= 0) {
      bindings[index] = bindings[index].copyWith(priority: priority);
      await _dataSource.saveAllBindings(bindings);
    }
  }

  @override
  Future<void> deleteBindingsByScriptId(String scriptId) async {
    final bindings = await _dataSource.getAllBindings();
    final filtered = bindings.where((b) => b.scriptId != scriptId).toList();
    await _dataSource.saveAllBindings(filtered);
  }
}
