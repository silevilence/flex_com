import 'package:flutter_test/flutter_test.dart';
import 'package:flex_com/features/scripting/domain/script_entity.dart';

void main() {
  group('ScriptEntity', () {
    test('should create entity with required fields', () {
      final now = DateTime.now();
      final entity = ScriptEntity(
        id: '1',
        name: 'Test Script',
        content: 'print("hello")',
        createdAt: now,
        updatedAt: now,
      );

      expect(entity.id, '1');
      expect(entity.name, 'Test Script');
      expect(entity.content, 'print("hello")');
      expect(entity.description, isNull);
      expect(entity.isEnabled, true);
      expect(entity.createdAt, now);
      expect(entity.updatedAt, now);
    });

    test('should create empty script', () {
      final entity = ScriptEntity.empty();

      expect(entity.id, isEmpty);
      expect(entity.name, 'New Script');
      expect(entity.content, isEmpty);
      expect(entity.isEnabled, true);
      expect(entity.createdAt, isNotNull);
      expect(entity.updatedAt, isNotNull);
    });

    test('should copy with modifications', () {
      final now = DateTime.now();
      final original = ScriptEntity(
        id: '1',
        name: 'Original',
        content: 'original content',
        createdAt: now,
        updatedAt: now,
      );

      final modified = original.copyWith(
        name: 'Modified',
        content: 'modified content',
        isEnabled: false,
      );

      expect(modified.id, '1');
      expect(modified.name, 'Modified');
      expect(modified.content, 'modified content');
      expect(modified.isEnabled, false);
      expect(modified.createdAt, now);
      expect(modified.updatedAt, now);
    });

    test('should compare entities correctly with Equatable', () {
      final now = DateTime.now();
      final entity1 = ScriptEntity(
        id: '1',
        name: 'Test',
        content: 'content',
        createdAt: now,
        updatedAt: now,
      );

      final entity2 = ScriptEntity(
        id: '1',
        name: 'Test',
        content: 'content',
        createdAt: now,
        updatedAt: now,
      );

      final entity3 = ScriptEntity(
        id: '2',
        name: 'Test',
        content: 'content',
        createdAt: now,
        updatedAt: now,
      );

      expect(entity1, equals(entity2));
      expect(entity1, isNot(equals(entity3)));
    });

    test('should handle optional description', () {
      final now = DateTime.now();
      final withDescription = ScriptEntity(
        id: '1',
        name: 'Test',
        content: 'content',
        description: 'A test script',
        createdAt: now,
        updatedAt: now,
      );

      expect(withDescription.description, 'A test script');

      // copyWith无法将非null值设置为null，所以创建一个新的实体测试
      final withoutDescription = ScriptEntity(
        id: '1',
        name: 'Test',
        content: 'content',
        createdAt: now,
        updatedAt: now,
      );
      expect(withoutDescription.description, isNull);
    });
  });
}
