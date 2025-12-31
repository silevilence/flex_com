import 'dart:async';
import '../domain/script_entity.dart';
import '../domain/script_interfaces.dart';
import 'script_data_source.dart';

/// 脚本仓库实现
class ScriptRepositoryImpl implements IScriptRepository {
  final ScriptJsonDataSource _dataSource;
  final StreamController<List<ScriptEntity>> _scriptsController =
      StreamController<List<ScriptEntity>>.broadcast();

  ScriptRepositoryImpl(this._dataSource);

  @override
  Future<List<ScriptEntity>> getAllScripts() async {
    final dtos = await _dataSource.readScripts();
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<ScriptEntity?> getScriptById(String id) async {
    final scripts = await getAllScripts();
    try {
      return scripts.firstWhere((script) => script.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveScript(ScriptEntity script) async {
    final scripts = await getAllScripts();
    final index = scripts.indexWhere((s) => s.id == script.id);

    if (index >= 0) {
      // 更新现有脚本
      scripts[index] = script.copyWith(updatedAt: DateTime.now());
    } else {
      // 新增脚本
      scripts.add(script);
    }

    final dtos = scripts.map((s) => ScriptDto.fromEntity(s)).toList();
    await _dataSource.writeScripts(dtos);

    // 通知监听者
    _scriptsController.add(scripts);
  }

  @override
  Future<void> deleteScript(String id) async {
    final scripts = await getAllScripts();
    scripts.removeWhere((script) => script.id == id);

    final dtos = scripts.map((s) => ScriptDto.fromEntity(s)).toList();
    await _dataSource.writeScripts(dtos);

    // 通知监听者
    _scriptsController.add(scripts);
  }

  @override
  Stream<List<ScriptEntity>> watchScripts() {
    // 初始加载
    getAllScripts().then((scripts) {
      if (!_scriptsController.isClosed) {
        _scriptsController.add(scripts);
      }
    });

    return _scriptsController.stream;
  }

  /// 释放资源
  void dispose() {
    _scriptsController.close();
  }
}
