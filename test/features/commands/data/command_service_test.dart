import 'dart:convert';
import 'dart:io';

import 'package:flex_com/features/commands/data/command_service.dart';
import 'package:flex_com/features/commands/domain/command.dart';
import 'package:flex_com/features/serial/domain/serial_data_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommandService', () {
    late Directory tempDir;
    late String testFilePath;
    late CommandService service;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('command_service_test_');
      testFilePath = '${tempDir.path}${Platform.pathSeparator}commands.json';
      service = CommandService(commandsPath: testFilePath);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('loadCommands', () {
      test('should return empty list when file does not exist', () async {
        final commands = await service.loadCommands();

        expect(commands, isEmpty);
      });

      test('should return empty list for invalid JSON', () async {
        final file = File(testFilePath);
        await file.writeAsString('invalid json');

        final commands = await service.loadCommands();

        expect(commands, isEmpty);
      });

      test('should return empty list when commands key is missing', () async {
        final file = File(testFilePath);
        await file.writeAsString('{"version": 1}');

        final commands = await service.loadCommands();

        expect(commands, isEmpty);
      });

      test('should load commands from file', () async {
        final file = File(testFilePath);
        final data = {
          'version': 1,
          'commands': [
            {
              'id': 'cmd1',
              'name': 'Command 1',
              'data': '01 02 03',
              'mode': 'hex',
              'description': 'First command',
              'createdAt': '2024-01-15T10:00:00.000',
              'updatedAt': '2024-01-15T10:00:00.000',
            },
            {
              'id': 'cmd2',
              'name': 'Command 2',
              'data': 'Hello',
              'mode': 'ascii',
              'description': '',
              'createdAt': '2024-01-15T11:00:00.000',
              'updatedAt': '2024-01-15T11:00:00.000',
            },
          ],
        };
        await file.writeAsString(jsonEncode(data));

        final commands = await service.loadCommands();

        expect(commands.length, 2);
        expect(commands[0].id, 'cmd1');
        expect(commands[0].name, 'Command 1');
        expect(commands[0].data, '01 02 03');
        expect(commands[0].mode, DataDisplayMode.hex);
        expect(commands[1].id, 'cmd2');
        expect(commands[1].name, 'Command 2');
        expect(commands[1].mode, DataDisplayMode.ascii);
      });
    });

    group('saveCommands', () {
      test('should save commands to file', () async {
        final commands = [
          Command.create(
            name: 'Test Command',
            data: '48 65',
            mode: DataDisplayMode.hex,
            description: 'A test',
          ),
        ];

        final success = await service.saveCommands(commands);

        expect(success, isTrue);

        final file = File(testFilePath);
        expect(await file.exists(), isTrue);

        final contents = await file.readAsString();
        final json = jsonDecode(contents) as Map<String, dynamic>;

        expect(json['version'], 1);
        expect(json['commands'], isA<List>());
        expect((json['commands'] as List).length, 1);
      });

      test('should save multiple commands', () async {
        final commands = [
          Command.create(name: 'Cmd 1', data: '01'),
          Command.create(name: 'Cmd 2', data: '02'),
          Command.create(name: 'Cmd 3', data: '03'),
        ];

        final success = await service.saveCommands(commands);

        expect(success, isTrue);

        final loaded = await service.loadCommands();
        expect(loaded.length, 3);
        expect(loaded[0].name, 'Cmd 1');
        expect(loaded[1].name, 'Cmd 2');
        expect(loaded[2].name, 'Cmd 3');
      });

      test('should save empty list', () async {
        final success = await service.saveCommands([]);

        expect(success, isTrue);

        final loaded = await service.loadCommands();
        expect(loaded, isEmpty);
      });
    });

    group('addCommand', () {
      test('should add command to empty list', () async {
        final command = Command.create(name: 'New Command', data: 'FF');

        final success = await service.addCommand(command);

        expect(success, isTrue);

        final commands = await service.loadCommands();
        expect(commands.length, 1);
        expect(commands[0].name, 'New Command');
      });

      test('should append command to existing list', () async {
        // First add a command
        await service.addCommand(Command.create(name: 'First', data: '01'));

        // Then add another
        final success = await service.addCommand(
          Command.create(name: 'Second', data: '02'),
        );

        expect(success, isTrue);

        final commands = await service.loadCommands();
        expect(commands.length, 2);
        expect(commands[0].name, 'First');
        expect(commands[1].name, 'Second');
      });
    });

    group('updateCommand', () {
      test('should update existing command', () async {
        final original = Command.create(name: 'Original', data: '01');
        await service.addCommand(original);

        final updated = original.copyWith(name: 'Updated', data: '02 03');
        final success = await service.updateCommand(updated);

        expect(success, isTrue);

        final commands = await service.loadCommands();
        expect(commands.length, 1);
        expect(commands[0].name, 'Updated');
        expect(commands[0].data, '02 03');
      });

      test('should return false for non-existent command', () async {
        final command = Command.create(name: 'Non-existent', data: '00');

        final success = await service.updateCommand(command);

        expect(success, isFalse);
      });

      test('should update correct command among multiple', () async {
        final cmd1 = Command.create(name: 'Cmd 1', data: '01');
        final cmd2 = Command.create(name: 'Cmd 2', data: '02');
        final cmd3 = Command.create(name: 'Cmd 3', data: '03');

        await service.addCommand(cmd1);
        await service.addCommand(cmd2);
        await service.addCommand(cmd3);

        final updated = cmd2.copyWith(name: 'Updated Cmd 2');
        await service.updateCommand(updated);

        final commands = await service.loadCommands();
        expect(commands[0].name, 'Cmd 1');
        expect(commands[1].name, 'Updated Cmd 2');
        expect(commands[2].name, 'Cmd 3');
      });
    });

    group('deleteCommand', () {
      test('should delete existing command', () async {
        final command = Command.create(name: 'To Delete', data: '00');
        await service.addCommand(command);

        final success = await service.deleteCommand(command.id);

        expect(success, isTrue);

        final commands = await service.loadCommands();
        expect(commands, isEmpty);
      });

      test('should return false for non-existent command', () async {
        final success = await service.deleteCommand('non-existent-id');

        expect(success, isFalse);
      });

      test('should delete correct command among multiple', () async {
        final cmd1 = Command.create(name: 'Cmd 1', data: '01');
        final cmd2 = Command.create(name: 'Cmd 2', data: '02');
        final cmd3 = Command.create(name: 'Cmd 3', data: '03');

        await service.addCommand(cmd1);
        await service.addCommand(cmd2);
        await service.addCommand(cmd3);

        await service.deleteCommand(cmd2.id);

        final commands = await service.loadCommands();
        expect(commands.length, 2);
        expect(commands[0].name, 'Cmd 1');
        expect(commands[1].name, 'Cmd 3');
      });
    });

    group('getCommand', () {
      test('should return command by id', () async {
        final original = Command.create(name: 'Test', data: '00');
        await service.addCommand(original);

        final command = await service.getCommand(original.id);

        expect(command, isNotNull);
        expect(command!.id, original.id);
        expect(command.name, 'Test');
      });

      test('should return null for non-existent id', () async {
        final command = await service.getCommand('non-existent');

        expect(command, isNull);
      });
    });

    group('reorderCommands', () {
      test('should reorder commands', () async {
        final cmd1 = Command.create(name: 'Cmd 1', data: '01');
        final cmd2 = Command.create(name: 'Cmd 2', data: '02');
        final cmd3 = Command.create(name: 'Cmd 3', data: '03');

        await service.addCommand(cmd1);
        await service.addCommand(cmd2);
        await service.addCommand(cmd3);

        // Move cmd1 (index 0) to index 2
        // Initial: [Cmd 1, Cmd 2, Cmd 3]
        // After removeAt(0): [Cmd 2, Cmd 3]
        // After insert(2): [Cmd 2, Cmd 3, Cmd 1]
        final success = await service.reorderCommands(0, 2);

        expect(success, isTrue);

        final commands = await service.loadCommands();
        expect(commands[0].name, 'Cmd 2');
        expect(commands[1].name, 'Cmd 3');
        expect(commands[2].name, 'Cmd 1');
      });

      test('should move command to beginning', () async {
        final cmd1 = Command.create(name: 'Cmd 1', data: '01');
        final cmd2 = Command.create(name: 'Cmd 2', data: '02');
        final cmd3 = Command.create(name: 'Cmd 3', data: '03');

        await service.addCommand(cmd1);
        await service.addCommand(cmd2);
        await service.addCommand(cmd3);

        // Move cmd3 (index 2) to index 0
        // Initial: [Cmd 1, Cmd 2, Cmd 3]
        // After removeAt(2): [Cmd 1, Cmd 2]
        // After insert(0): [Cmd 3, Cmd 1, Cmd 2]
        final success = await service.reorderCommands(2, 0);

        expect(success, isTrue);

        final commands = await service.loadCommands();
        expect(commands[0].name, 'Cmd 3');
        expect(commands[1].name, 'Cmd 1');
        expect(commands[2].name, 'Cmd 2');
      });

      test('should return false for invalid indices', () async {
        await service.addCommand(Command.create(name: 'Test', data: '00'));

        expect(await service.reorderCommands(-1, 0), isFalse);
        expect(await service.reorderCommands(0, 5), isFalse);
        expect(await service.reorderCommands(5, 0), isFalse);
      });
    });

    group('commandsFileExists', () {
      test('should return false when file does not exist', () async {
        final exists = await service.commandsFileExists();

        expect(exists, isFalse);
      });

      test('should return true when file exists', () async {
        await service.saveCommands([]);

        final exists = await service.commandsFileExists();

        expect(exists, isTrue);
      });
    });
  });
}
