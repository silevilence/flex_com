import 'package:flex_com/features/commands/domain/command.dart';
import 'package:flex_com/features/serial/domain/serial_data_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Command', () {
    test('should create a command with all properties', () {
      final now = DateTime.now();
      final command = Command(
        id: 'test-id',
        name: 'Test Command',
        data: '48 65 6C 6C 6F',
        mode: DataDisplayMode.hex,
        description: 'A test command',
        createdAt: now,
        updatedAt: now,
      );

      expect(command.id, 'test-id');
      expect(command.name, 'Test Command');
      expect(command.data, '48 65 6C 6C 6F');
      expect(command.mode, DataDisplayMode.hex);
      expect(command.description, 'A test command');
      expect(command.createdAt, now);
      expect(command.updatedAt, now);
    });

    test('should create a command with default mode and description', () {
      final command = Command(
        id: 'test-id',
        name: 'Test Command',
        data: 'Hello',
      );

      expect(command.mode, DataDisplayMode.hex);
      expect(command.description, '');
    });

    group('Command.create', () {
      test('should generate unique ID', () {
        final command1 = Command.create(name: 'Command 1', data: '01 02 03');
        final command2 = Command.create(name: 'Command 2', data: '04 05 06');

        expect(command1.id, isNotEmpty);
        expect(command2.id, isNotEmpty);
        expect(command1.id, isNot(command2.id));
      });

      test('should set createdAt and updatedAt to current time', () {
        final before = DateTime.now();
        final command = Command.create(name: 'Test', data: '00');
        final after = DateTime.now();

        expect(
          command.createdAt.isAfter(before) ||
              command.createdAt.isAtSameMomentAs(before),
          isTrue,
        );
        expect(
          command.createdAt.isBefore(after) ||
              command.createdAt.isAtSameMomentAs(after),
          isTrue,
        );
        expect(command.createdAt, command.updatedAt);
      });

      test('should set mode correctly', () {
        final hexCommand = Command.create(
          name: 'Hex',
          data: '48 65',
          mode: DataDisplayMode.hex,
        );
        final asciiCommand = Command.create(
          name: 'ASCII',
          data: 'Hello',
          mode: DataDisplayMode.ascii,
        );

        expect(hexCommand.mode, DataDisplayMode.hex);
        expect(asciiCommand.mode, DataDisplayMode.ascii);
      });
    });

    group('JSON serialization', () {
      test('should convert to JSON correctly', () {
        final now = DateTime(2024, 1, 15, 10, 30, 45);
        final command = Command(
          id: 'test-id',
          name: 'Test Command',
          data: '48 65',
          mode: DataDisplayMode.hex,
          description: 'Description',
          createdAt: now,
          updatedAt: now,
        );

        final json = command.toJson();

        expect(json['id'], 'test-id');
        expect(json['name'], 'Test Command');
        expect(json['data'], '48 65');
        expect(json['mode'], 'hex');
        expect(json['description'], 'Description');
        expect(json['createdAt'], now.toIso8601String());
        expect(json['updatedAt'], now.toIso8601String());
      });

      test('should create from JSON correctly', () {
        final json = {
          'id': 'test-id',
          'name': 'Test Command',
          'data': 'Hello',
          'mode': 'ascii',
          'description': 'A command',
          'createdAt': '2024-01-15T10:30:45.000',
          'updatedAt': '2024-01-15T11:00:00.000',
        };

        final command = Command.fromJson(json);

        expect(command.id, 'test-id');
        expect(command.name, 'Test Command');
        expect(command.data, 'Hello');
        expect(command.mode, DataDisplayMode.ascii);
        expect(command.description, 'A command');
        expect(command.createdAt.year, 2024);
        expect(command.createdAt.month, 1);
        expect(command.createdAt.day, 15);
      });

      test('should handle missing optional fields in JSON', () {
        final json = {
          'id': 'test-id',
          'name': 'Test',
          'data': '00',
          'mode': 'hex',
        };

        final command = Command.fromJson(json);

        expect(command.description, '');
        expect(command.createdAt, isNotNull);
        expect(command.updatedAt, isNotNull);
      });

      test('should handle invalid mode in JSON', () {
        final json = {
          'id': 'test-id',
          'name': 'Test',
          'data': '00',
          'mode': 'invalid_mode',
        };

        final command = Command.fromJson(json);

        expect(command.mode, DataDisplayMode.hex); // default
      });

      test('should roundtrip through JSON', () {
        final original = Command.create(
          name: 'Original',
          data: '01 02 03',
          mode: DataDisplayMode.hex,
          description: 'Test description',
        );

        final json = original.toJson();
        final restored = Command.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.data, original.data);
        expect(restored.mode, original.mode);
        expect(restored.description, original.description);
      });
    });

    group('copyWith', () {
      test('should copy with new name', () {
        final original = Command.create(name: 'Original', data: '00');

        final copied = original.copyWith(name: 'Updated');

        expect(copied.id, original.id);
        expect(copied.name, 'Updated');
        expect(copied.data, original.data);
      });

      test('should update updatedAt when copying', () {
        final now = DateTime(2024, 1, 1);
        final original = Command(
          id: 'id',
          name: 'Test',
          data: '00',
          createdAt: now,
          updatedAt: now,
        );

        final copied = original.copyWith(name: 'Updated');

        expect(copied.createdAt, now);
        expect(copied.updatedAt.isAfter(now), isTrue);
      });

      test('should allow preserving updatedAt', () {
        final now = DateTime(2024, 1, 1);
        final original = Command(
          id: 'id',
          name: 'Test',
          data: '00',
          createdAt: now,
          updatedAt: now,
        );

        final copied = original.copyWith(name: 'Updated', updatedAt: now);

        expect(copied.updatedAt, now);
      });
    });

    group('equality', () {
      test('should be equal with same properties', () {
        final command1 = Command(
          id: 'id',
          name: 'Test',
          data: '00',
          mode: DataDisplayMode.hex,
          description: 'Desc',
        );
        final command2 = Command(
          id: 'id',
          name: 'Test',
          data: '00',
          mode: DataDisplayMode.hex,
          description: 'Desc',
        );

        expect(command1, command2);
      });

      test('should not be equal with different id', () {
        final command1 = Command(id: 'id1', name: 'Test', data: '00');
        final command2 = Command(id: 'id2', name: 'Test', data: '00');

        expect(command1, isNot(command2));
      });
    });
  });
}
