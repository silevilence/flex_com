import 'package:flutter_test/flutter_test.dart';
import 'package:flex_com/features/scripting/domain/script_log.dart';

void main() {
  group('ScriptLog', () {
    test('should create info log', () {
      final log = ScriptLog.info('Test message');

      expect(log.type, ScriptLogType.info);
      expect(log.message, 'Test message');
      expect(log.timestamp, isNotNull);
      expect(log.scriptId, isNull);
    });

    test('should create warning log', () {
      final log = ScriptLog.warning('Warning message');

      expect(log.type, ScriptLogType.warning);
      expect(log.message, 'Warning message');
    });

    test('should create error log', () {
      final log = ScriptLog.error('Error message');

      expect(log.type, ScriptLogType.error);
      expect(log.message, 'Error message');
    });

    test('should create debug log', () {
      final log = ScriptLog.debug('Debug message');

      expect(log.type, ScriptLogType.debug);
      expect(log.message, 'Debug message');
    });

    test('should create log with scriptId', () {
      final log = ScriptLog.info('Test', scriptId: 'script-123');

      expect(log.scriptId, 'script-123');
    });

    test('should compare logs correctly with Equatable', () {
      final timestamp = DateTime.now();
      final log1 = ScriptLog(
        type: ScriptLogType.info,
        message: 'Test',
        timestamp: timestamp,
      );

      final log2 = ScriptLog(
        type: ScriptLogType.info,
        message: 'Test',
        timestamp: timestamp,
      );

      final log3 = ScriptLog(
        type: ScriptLogType.error,
        message: 'Test',
        timestamp: timestamp,
      );

      expect(log1, equals(log2));
      expect(log1, isNot(equals(log3)));
    });

    test('should have all log types in enum', () {
      expect(ScriptLogType.values.length, 4);
      expect(ScriptLogType.values, contains(ScriptLogType.info));
      expect(ScriptLogType.values, contains(ScriptLogType.warning));
      expect(ScriptLogType.values, contains(ScriptLogType.error));
      expect(ScriptLogType.values, contains(ScriptLogType.debug));
    });
  });
}
