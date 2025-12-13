import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flex_com/features/auto_reply/data/auto_reply_config_service.dart';
import 'package:flex_com/features/auto_reply/domain/auto_reply_config.dart';
import 'package:flex_com/features/auto_reply/domain/auto_reply_mode.dart';
import 'package:flex_com/features/auto_reply/domain/match_reply_config.dart';
import 'package:flex_com/features/auto_reply/domain/sequential_reply_config.dart';

void main() {
  late Directory tempDir;
  late String configPath;
  late AutoReplyConfigService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('auto_reply_test_');
    configPath = '${tempDir.path}${Platform.pathSeparator}config.json';
    service = AutoReplyConfigService(configPath: configPath);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('AutoReplyConfigService', () {
    test('should return default config when file does not exist', () async {
      final config = await service.loadGlobalConfig();

      expect(config, isNotNull);
      expect(config.enabled, false);
      expect(config.globalDelayMs, 0);
      expect(config.activeMode, AutoReplyMode.matchReply);
    });

    test('should save and load global config', () async {
      const config = AutoReplyConfig(
        enabled: true,
        globalDelayMs: 100,
        activeMode: AutoReplyMode.sequentialReply,
      );

      await service.saveGlobalConfig(config);
      final loaded = await service.loadGlobalConfig();

      expect(loaded.enabled, true);
      expect(loaded.globalDelayMs, 100);
      expect(loaded.activeMode, AutoReplyMode.sequentialReply);
    });

    test('should preserve other config sections when saving', () async {
      // Create initial config with other sections
      final initialData = {
        'serialPort': {'portName': 'COM1', 'baudRate': 9600},
        'otherSection': {'someKey': 'someValue'},
      };
      await File(configPath).writeAsString(jsonEncode(initialData));

      // Save auto reply config
      const config = AutoReplyConfig(enabled: true);
      await service.saveGlobalConfig(config);

      // Verify other sections are preserved
      final contents = await File(configPath).readAsString();
      final json = jsonDecode(contents) as Map<String, dynamic>;

      expect(json['serialPort'], isNotNull);
      expect(json['serialPort']['portName'], 'COM1');
      expect(json['otherSection'], isNotNull);
      expect(json['autoReply'], isNotNull);
    });

    test('should return empty match config when not exists', () async {
      final config = await service.loadMatchReplyConfig();

      expect(config.rules, isEmpty);
    });

    test('should save and load match reply config', () async {
      final config = MatchReplyConfig(
        rules: [
          MatchReplyRule(
            id: 'rule-1',
            name: 'Test Rule',
            triggerPattern: 'AA BB',
            responseData: 'CC DD',
          ),
        ],
      );

      await service.saveMatchReplyConfig(config);
      final loaded = await service.loadMatchReplyConfig();

      expect(loaded.rules.length, 1);
      expect(loaded.rules[0].id, 'rule-1');
      expect(loaded.rules[0].name, 'Test Rule');
      expect(loaded.rules[0].triggerPattern, 'AA BB');
    });

    test('should return empty sequential config when not exists', () async {
      final config = await service.loadSequentialReplyConfig();

      expect(config.frames, isEmpty);
      expect(config.currentIndex, 0);
    });

    test('should save and load sequential reply config', () async {
      final config = SequentialReplyConfig(
        frames: [
          SequentialReplyFrame(id: 'f1', name: 'Frame 1', data: 'AA'),
          SequentialReplyFrame(id: 'f2', name: 'Frame 2', data: 'BB'),
        ],
        currentIndex: 1,
        loopEnabled: true,
      );

      await service.saveSequentialReplyConfig(config);
      final loaded = await service.loadSequentialReplyConfig();

      expect(loaded.frames.length, 2);
      expect(loaded.currentIndex, 1);
      expect(loaded.loopEnabled, true);
    });

    test('should load all configs at once', () async {
      // Save all configs
      const globalConfig = AutoReplyConfig(enabled: true, globalDelayMs: 50);
      final matchConfig = MatchReplyConfig(
        rules: [
          MatchReplyRule(
            id: '1',
            name: 'R1',
            triggerPattern: 'AA',
            responseData: 'BB',
          ),
        ],
      );
      final sequentialConfig = SequentialReplyConfig(
        frames: [SequentialReplyFrame(id: '1', name: 'F1', data: 'CC')],
      );

      await service.saveGlobalConfig(globalConfig);
      await service.saveMatchReplyConfig(matchConfig);
      await service.saveSequentialReplyConfig(sequentialConfig);

      // Load all at once
      final allConfigs = await service.loadAllConfigs();

      expect(allConfigs.globalConfig.enabled, true);
      expect(allConfigs.globalConfig.globalDelayMs, 50);
      expect(allConfigs.matchReplyConfig.rules.length, 1);
      expect(allConfigs.sequentialReplyConfig.frames.length, 1);
    });

    test('should handle corrupted JSON gracefully', () async {
      // Write invalid JSON
      await File(configPath).writeAsString('{ invalid json }');

      final config = await service.loadGlobalConfig();

      // Should return default config instead of crashing
      expect(config, isNotNull);
      expect(config.enabled, false);
    });
  });
}
