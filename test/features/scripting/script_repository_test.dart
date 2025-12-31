import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flex_com/features/scripting/data/script_data_source.dart';
import 'package:flex_com/features/scripting/data/script_repository_impl.dart';
import 'package:flex_com/features/scripting/domain/script_entity.dart';

void main() {
  group('ScriptRepositoryImpl', () {
    late ScriptRepositoryImpl repository;
    late ScriptJsonDataSource dataSource;
    late Directory testDir;

    setUp(() async {
      // 创建临时测试目录
      testDir = await Directory.systemTemp.createTemp('repo_test_');
      dataSource = ScriptJsonDataSource(customDir: testDir.path);
      repository = ScriptRepositoryImpl(dataSource);
    });

    tearDown(() async {
      repository.dispose();
      // 清理测试目录
      if (await testDir.exists()) {
        await testDir.delete(recursive: true);
      }
    });

    test('should return empty list initially', () async {
      final scripts = await repository.getAllScripts();
      expect(scripts, isEmpty);
    });

    test('should save and retrieve script', () async {
      final now = DateTime.now();
      final script = ScriptEntity(
        id: '1',
        name: 'Test Script',
        content: 'print("hello")',
        createdAt: now,
        updatedAt: now,
      );

      await repository.saveScript(script);

      final scripts = await repository.getAllScripts();
      expect(scripts.length, 1);
      expect(scripts[0].id, '1');
      expect(scripts[0].name, 'Test Script');
    });

    test('should get script by id', () async {
      final now = DateTime.now();
      final script = ScriptEntity(
        id: '1',
        name: 'Test Script',
        content: 'content',
        createdAt: now,
        updatedAt: now,
      );

      await repository.saveScript(script);

      final retrieved = await repository.getScriptById('1');
      expect(retrieved, isNotNull);
      expect(retrieved!.id, '1');
      expect(retrieved.name, 'Test Script');

      final notFound = await repository.getScriptById('999');
      expect(notFound, isNull);
    });

    test('should update existing script', () async {
      final now = DateTime.now();
      final script = ScriptEntity(
        id: '1',
        name: 'Original',
        content: 'original',
        createdAt: now,
        updatedAt: now,
      );

      await repository.saveScript(script);

      final updated = script.copyWith(name: 'Updated', content: 'updated');

      await repository.saveScript(updated);

      final scripts = await repository.getAllScripts();
      expect(scripts.length, 1);
      expect(scripts[0].name, 'Updated');
      expect(scripts[0].content, 'updated');
    });

    test('should delete script', () async {
      final now = DateTime.now();
      final script1 = ScriptEntity(
        id: '1',
        name: 'Script 1',
        content: 'content1',
        createdAt: now,
        updatedAt: now,
      );

      final script2 = ScriptEntity(
        id: '2',
        name: 'Script 2',
        content: 'content2',
        createdAt: now,
        updatedAt: now,
      );

      await repository.saveScript(script1);
      await repository.saveScript(script2);

      var scripts = await repository.getAllScripts();
      expect(scripts.length, 2);

      await repository.deleteScript('1');

      scripts = await repository.getAllScripts();
      expect(scripts.length, 1);
      expect(scripts[0].id, '2');
    });

    test('should handle multiple scripts operations', () async {
      final now = DateTime.now();

      // 添加多个脚本
      for (int i = 1; i <= 5; i++) {
        await repository.saveScript(
          ScriptEntity(
            id: i.toString(),
            name: 'Script $i',
            content: 'content$i',
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      var scripts = await repository.getAllScripts();
      expect(scripts.length, 5);

      // 删除部分脚本
      await repository.deleteScript('2');
      await repository.deleteScript('4');

      scripts = await repository.getAllScripts();
      expect(scripts.length, 3);
      expect(scripts.map((s) => s.id).toList(), ['1', '3', '5']);

      // 更新一个脚本
      final updated = scripts[0].copyWith(name: 'Updated Script 1');
      await repository.saveScript(updated);

      final retrieved = await repository.getScriptById('1');
      expect(retrieved!.name, 'Updated Script 1');
    });
  });
}
