import 'package:flutter_test/flutter_test.dart';
import 'package:flex_com/features/auto_reply/domain/auto_reply_config.dart';
import 'package:flex_com/features/auto_reply/domain/auto_reply_mode.dart';
import 'package:flex_com/features/auto_reply/domain/match_reply_config.dart';
import 'package:flex_com/features/auto_reply/domain/sequential_reply_config.dart';

void main() {
  group('AutoReplyMode', () {
    test('should have all expected modes', () {
      expect(AutoReplyMode.values, contains(AutoReplyMode.matchReply));
      expect(AutoReplyMode.values, contains(AutoReplyMode.sequentialReply));
    });

    test('should have correct display names', () {
      expect(AutoReplyMode.matchReply.displayName, '匹配回复');
      expect(AutoReplyMode.sequentialReply.displayName, '顺序回复');
    });
  });

  group('AutoReplyConfig', () {
    test('should create with default values', () {
      const config = AutoReplyConfig();

      expect(config.enabled, false);
      expect(config.globalDelayMs, 0);
      expect(config.activeMode, AutoReplyMode.matchReply);
    });

    test('should support copyWith', () {
      const config = AutoReplyConfig();
      final updated = config.copyWith(
        enabled: true,
        globalDelayMs: 100,
        activeMode: AutoReplyMode.sequentialReply,
      );

      expect(updated.enabled, true);
      expect(updated.globalDelayMs, 100);
      expect(updated.activeMode, AutoReplyMode.sequentialReply);
    });

    test('should serialize to JSON', () {
      const config = AutoReplyConfig(
        enabled: true,
        globalDelayMs: 50,
        activeMode: AutoReplyMode.sequentialReply,
      );

      final json = config.toJson();

      expect(json['enabled'], true);
      expect(json['globalDelayMs'], 50);
      expect(json['activeMode'], 'sequentialReply');
    });

    test('should deserialize from JSON', () {
      final json = {
        'enabled': true,
        'globalDelayMs': 100,
        'activeMode': 'matchReply',
      };

      final config = AutoReplyConfig.fromJson(json);

      expect(config.enabled, true);
      expect(config.globalDelayMs, 100);
      expect(config.activeMode, AutoReplyMode.matchReply);
    });

    test('should handle missing JSON fields with defaults', () {
      final json = <String, dynamic>{};

      final config = AutoReplyConfig.fromJson(json);

      expect(config.enabled, false);
      expect(config.globalDelayMs, 0);
      expect(config.activeMode, AutoReplyMode.matchReply);
    });

    test('should be equatable', () {
      const config1 = AutoReplyConfig(enabled: true);
      const config2 = AutoReplyConfig(enabled: true);
      const config3 = AutoReplyConfig(enabled: false);

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });
  });

  group('MatchReplyRule', () {
    test('should create with required fields', () {
      final rule = MatchReplyRule(
        id: 'rule-1',
        name: 'Test Rule',
        triggerPattern: 'AA BB',
        responseData: 'CC DD',
      );

      expect(rule.id, 'rule-1');
      expect(rule.name, 'Test Rule');
      expect(rule.triggerPattern, 'AA BB');
      expect(rule.responseData, 'CC DD');
      expect(rule.triggerMode, DataMode.hex);
      expect(rule.responseMode, DataMode.hex);
      expect(rule.enabled, true);
    });

    test('should serialize to JSON', () {
      final rule = MatchReplyRule(
        id: 'rule-1',
        name: 'Test',
        triggerPattern: 'AA',
        responseData: 'BB',
        triggerMode: DataMode.ascii,
        responseMode: DataMode.ascii,
        enabled: false,
      );

      final json = rule.toJson();

      expect(json['id'], 'rule-1');
      expect(json['triggerMode'], 'ascii');
      expect(json['responseMode'], 'ascii');
      expect(json['enabled'], false);
    });

    test('should deserialize from JSON', () {
      final json = {
        'id': 'rule-2',
        'name': 'Test Rule 2',
        'triggerPattern': 'AABB',
        'responseData': 'CCDD',
        'triggerMode': 'hex',
        'responseMode': 'hex',
        'enabled': true,
      };

      final rule = MatchReplyRule.fromJson(json);

      expect(rule.id, 'rule-2');
      expect(rule.name, 'Test Rule 2');
      expect(rule.triggerPattern, 'AABB');
      expect(rule.responseData, 'CCDD');
      expect(rule.triggerMode, DataMode.hex);
      expect(rule.responseMode, DataMode.hex);
      expect(rule.enabled, true);
    });
  });

  group('MatchReplyConfig', () {
    test('should create with empty rules', () {
      const config = MatchReplyConfig();

      expect(config.rules, isEmpty);
    });

    test('should serialize and deserialize with rules', () {
      final rules = [
        MatchReplyRule(
          id: '1',
          name: 'Rule 1',
          triggerPattern: 'AA',
          responseData: 'BB',
        ),
        MatchReplyRule(
          id: '2',
          name: 'Rule 2',
          triggerPattern: 'CC',
          responseData: 'DD',
        ),
      ];

      final config = MatchReplyConfig(rules: rules);
      final json = config.toJson();
      final restored = MatchReplyConfig.fromJson(json);

      expect(restored.rules.length, 2);
      expect(restored.rules[0].id, '1');
      expect(restored.rules[1].id, '2');
    });
  });

  group('SequentialReplyFrame', () {
    test('should create with required fields', () {
      final frame = SequentialReplyFrame(
        id: 'frame-1',
        name: 'Frame 1',
        data: 'AA BB CC',
      );

      expect(frame.id, 'frame-1');
      expect(frame.name, 'Frame 1');
      expect(frame.data, 'AA BB CC');
      expect(frame.mode, DataMode.hex);
    });

    test('should serialize to JSON', () {
      final frame = SequentialReplyFrame(
        id: 'frame-1',
        name: 'Frame 1',
        data: 'Hello',
        mode: DataMode.ascii,
      );

      final json = frame.toJson();

      expect(json['id'], 'frame-1');
      expect(json['name'], 'Frame 1');
      expect(json['data'], 'Hello');
      expect(json['mode'], 'ascii');
    });

    test('should deserialize from JSON', () {
      final json = {
        'id': 'frame-2',
        'name': 'Frame 2',
        'data': 'AABBCC',
        'mode': 'hex',
      };

      final frame = SequentialReplyFrame.fromJson(json);

      expect(frame.id, 'frame-2');
      expect(frame.name, 'Frame 2');
      expect(frame.data, 'AABBCC');
      expect(frame.mode, DataMode.hex);
    });
  });

  group('SequentialReplyConfig', () {
    test('should create with empty frames', () {
      const config = SequentialReplyConfig();

      expect(config.frames, isEmpty);
      expect(config.currentIndex, 0);
      expect(config.loopEnabled, false);
    });

    test('should serialize and deserialize with frames', () {
      final frames = [
        SequentialReplyFrame(id: '1', name: 'F1', data: 'AA'),
        SequentialReplyFrame(id: '2', name: 'F2', data: 'BB'),
      ];

      final config = SequentialReplyConfig(
        frames: frames,
        currentIndex: 1,
        loopEnabled: true,
      );

      final json = config.toJson();
      final restored = SequentialReplyConfig.fromJson(json);

      expect(restored.frames.length, 2);
      expect(restored.currentIndex, 1);
      expect(restored.loopEnabled, true);
    });

    test('should support copyWith for currentIndex update', () {
      final frames = [
        SequentialReplyFrame(id: '1', name: 'F1', data: 'AA'),
        SequentialReplyFrame(id: '2', name: 'F2', data: 'BB'),
      ];

      final config = SequentialReplyConfig(frames: frames);
      final updated = config.copyWith(currentIndex: 1);

      expect(updated.currentIndex, 1);
      expect(updated.frames.length, 2);
    });
  });
}
