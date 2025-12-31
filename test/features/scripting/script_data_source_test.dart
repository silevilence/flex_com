import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flex_com/features/scripting/data/script_data_source.dart';
import 'package:flex_com/features/scripting/domain/script_entity.dart';

void main() {
  group('ScriptJsonDataSource', () {
    late ScriptJsonDataSource dataSource;
    late Directory testDir;

    setUp(() async {
      // 创建临时测试目录
      testDir = await Directory.systemTemp.createTemp('script_test_');
      dataSource = ScriptJsonDataSource(customDir: testDir.path);
    });

    tearDown(() async {
      // 清理测试目录
      if (await testDir.exists()) {
        await testDir.delete(recursive: true);
      }
    });

    test('should return empty list when file does not exist', () async {
      final scripts = await dataSource.readScripts();
      expect(scripts, isEmpty);
    });

    test('should write and read scripts correctly', () async {
      final now = DateTime.now();
      final entity = ScriptEntity(
        id: '1',
        name: 'Test Script',
        content: 'print("hello")',
        description: 'Test description',
        createdAt: now,
        updatedAt: now,
        isEnabled: true,
      );

      final dto = ScriptDto.fromEntity(entity);
      await dataSource.writeScripts([dto]);

      final readScripts = await dataSource.readScripts();
      expect(readScripts.length, 1);
      expect(readScripts[0].id, '1');
      expect(readScripts[0].name, 'Test Script');
      expect(readScripts[0].content, 'print("hello")');
      expect(readScripts[0].description, 'Test description');
      expect(readScripts[0].isEnabled, true);
    });

    test('should handle multiple scripts', () async {
      final now = DateTime.now();
      final entities = [
        ScriptEntity(
          id: '1',
          name: 'Script 1',
          content: 'content1',
          createdAt: now,
          updatedAt: now,
        ),
        ScriptEntity(
          id: '2',
          name: 'Script 2',
          content: 'content2',
          createdAt: now,
          updatedAt: now,
        ),
        ScriptEntity(
          id: '3',
          name: 'Script 3',
          content: 'content3',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final dtos = entities.map((e) => ScriptDto.fromEntity(e)).toList();
      await dataSource.writeScripts(dtos);

      final readScripts = await dataSource.readScripts();
      expect(readScripts.length, 3);
      expect(readScripts[0].name, 'Script 1');
      expect(readScripts[1].name, 'Script 2');
      expect(readScripts[2].name, 'Script 3');
    });

    test('should handle empty scripts list', () async {
      await dataSource.writeScripts([]);

      final readScripts = await dataSource.readScripts();
      expect(readScripts, isEmpty);
    });
  });

  group('ScriptDto', () {
    test('should convert to and from Entity correctly', () {
      final now = DateTime.now();
      final entity = ScriptEntity(
        id: '1',
        name: 'Test',
        content: 'content',
        description: 'desc',
        createdAt: now,
        updatedAt: now,
        isEnabled: false,
      );

      final dto = ScriptDto.fromEntity(entity);
      expect(dto.id, '1');
      expect(dto.name, 'Test');
      expect(dto.content, 'content');
      expect(dto.description, 'desc');
      expect(dto.isEnabled, false);

      final convertedEntity = dto.toEntity();
      expect(convertedEntity.id, entity.id);
      expect(convertedEntity.name, entity.name);
      expect(convertedEntity.content, entity.content);
      expect(convertedEntity.description, entity.description);
      expect(convertedEntity.isEnabled, entity.isEnabled);
      // 时间转换后应该相等（忽略微秒）
      expect(
        convertedEntity.createdAt.millisecondsSinceEpoch ~/ 1000,
        entity.createdAt.millisecondsSinceEpoch ~/ 1000,
      );
    });

    test('should handle JSON serialization', () {
      final dto = ScriptDto(
        id: '1',
        name: 'Test',
        content: 'content',
        description: 'desc',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        isEnabled: true,
      );

      final json = dto.toJson();
      expect(json['id'], '1');
      expect(json['name'], 'Test');
      expect(json['content'], 'content');
      expect(json['description'], 'desc');
      expect(json['isEnabled'], true);

      final fromJson = ScriptDto.fromJson(json);
      expect(fromJson.id, dto.id);
      expect(fromJson.name, dto.name);
      expect(fromJson.content, dto.content);
      expect(fromJson.description, dto.description);
      expect(fromJson.isEnabled, dto.isEnabled);
    });

    test('should handle null description', () {
      final dto = ScriptDto(
        id: '1',
        name: 'Test',
        content: 'content',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        isEnabled: true,
      );

      final json = dto.toJson();
      expect(json['description'], isNull);

      final fromJson = ScriptDto.fromJson(json);
      expect(fromJson.description, isNull);
    });
  });
}
