import 'package:flutter_test/flutter_test.dart';

import 'package:flex_com/features/auto_reply/application/auto_reply_engine.dart';

void main() {
  group('AutoReplyStats', () {
    test('默认值正确初始化', () {
      const stats = AutoReplyStats();

      expect(stats.totalReceived, equals(0));
      expect(stats.totalReplied, equals(0));
      expect(stats.lastMatchedRule, isNull);
      expect(stats.lastReplyTime, isNull);
    });

    test('copyWith 正确复制属性', () {
      final now = DateTime.now();
      const stats = AutoReplyStats();

      final updated = stats.copyWith(
        totalReceived: 10,
        totalReplied: 5,
        lastMatchedRule: '测试规则',
        lastReplyTime: now,
      );

      expect(updated.totalReceived, equals(10));
      expect(updated.totalReplied, equals(5));
      expect(updated.lastMatchedRule, equals('测试规则'));
      expect(updated.lastReplyTime, equals(now));
    });

    test('copyWith 保留未修改的属性', () {
      final now = DateTime.now();
      final stats = AutoReplyStats(
        totalReceived: 10,
        totalReplied: 5,
        lastMatchedRule: '规则1',
        lastReplyTime: now,
      );

      final updated = stats.copyWith(totalReceived: 20);

      expect(updated.totalReceived, equals(20));
      expect(updated.totalReplied, equals(5));
      expect(updated.lastMatchedRule, equals('规则1'));
      expect(updated.lastReplyTime, equals(now));
    });
  });

  group('AutoReplyEngineState', () {
    test('默认值正确初始化', () {
      const state = AutoReplyEngineState();

      expect(state.isProcessing, isFalse);
      expect(state.stats.totalReceived, equals(0));
      expect(state.lastError, isNull);
    });

    test('copyWith 正确复制属性', () {
      const state = AutoReplyEngineState();

      final updated = state.copyWith(
        isProcessing: true,
        stats: const AutoReplyStats(totalReceived: 5),
        lastError: '连接失败',
      );

      expect(updated.isProcessing, isTrue);
      expect(updated.stats.totalReceived, equals(5));
      expect(updated.lastError, equals('连接失败'));
    });

    test('copyWith 保留原有错误值', () {
      const state = AutoReplyEngineState(lastError: '某个错误');

      // copyWith 默认保留原值
      final updated = state.copyWith(isProcessing: true);

      // lastError 保持不变
      expect(updated.lastError, equals('某个错误'));
      expect(updated.isProcessing, isTrue);
    });
  });
}
