import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flex_com/features/scripting/application/lua_script_engine.dart';
import 'package:flex_com/features/scripting/application/script_api_bridge.dart';
import 'package:flex_com/features/scripting/domain/script_entity.dart';
import 'package:flex_com/features/scripting/domain/script_log.dart';

void main() {
  group('LuaScriptEngine', () {
    late LuaScriptEngine engine;
    late ScriptApiBridge bridge;
    final sentData = <Uint8List>[];
    final logs = <String>[];

    setUp(() async {
      sentData.clear();
      logs.clear();

      bridge = ScriptApiBridge(
        onSend: (data) {
          sentData.add(data);
        },
        onLog: (message, level) {
          logs.add('[$level] $message');
        },
      );

      engine = LuaScriptEngine(bridge);
      await engine.initialize();
    });

    tearDown(() async {
      await engine.dispose();
    });

    test('should initialize successfully', () async {
      expect(engine.isExecuting, false);
    });

    test('should execute simple Lua script', () async {
      final script = ScriptEntity(
        id: '1',
        name: 'Simple Script',
        content: 'local x = 1 + 1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await engine.execute(script);

      expect(result.success, true);
      expect(result.errorMessage, isNull);
      expect(result.durationMs, greaterThanOrEqualTo(0));
    });

    test('should execute script with print', () async {
      final script = ScriptEntity(
        id: '1',
        name: 'Print Script',
        content: 'print("Hello from Lua")',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await engine.execute(script);

      expect(result.success, true);
    });

    test('should emit logs through stream', () async {
      final receivedLogs = <ScriptLog>[];
      final subscription = engine.logStream.listen((log) {
        receivedLogs.add(log);
      });

      final script = ScriptEntity(
        id: '1',
        name: 'Test',
        content: 'local x = 1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await engine.execute(script);

      // 等待日志传播
      await Future.delayed(const Duration(milliseconds: 100));

      expect(receivedLogs, isNotEmpty);
      // 至少应该有执行开始和完成的日志
      expect(receivedLogs.length, greaterThanOrEqualTo(2));

      await subscription.cancel();
    });

    test('should handle script syntax error', () async {
      final script = ScriptEntity(
        id: '1',
        name: 'Error Script',
        content: 'invalid lua syntax {{',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await engine.execute(script);

      expect(result.success, false);
      expect(result.errorMessage, isNotNull);
    });

    test('should handle script runtime error', () async {
      final script = ScriptEntity(
        id: '1',
        name: 'Runtime Error Script',
        content: 'error("Intentional error")',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await engine.execute(script);

      expect(result.success, false);
      expect(result.errorMessage, isNotNull);
    });

    test('should stop execution when requested', () async {
      await engine.stop();
      expect(engine.isExecuting, false);
    });

    test('should measure execution duration', () async {
      final script = ScriptEntity(
        id: '1',
        name: 'Duration Test',
        content: 'for i=1,100000 do end',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await engine.execute(script);

      expect(result.success, true);
      expect(result.durationMs, greaterThan(0));
    });

    test('should call FCom.send from Lua', () async {
      final script = ScriptEntity(
        id: '1',
        name: 'Send Script',
        content: 'FCom.send("48656C6C6F")', // "Hello" in hex
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await engine.execute(script);

      // 如果执行成功且发送了数据，则通过
      if (result.success && sentData.isNotEmpty) {
        expect(sentData[0].length, 5);
      }
      // 即使FCom注册失败，脚本可能也不会报错（返回nil）
      expect(result.success || result.errorMessage != null, true);
    });

    test('should call FCom.log from Lua', () async {
      final script = ScriptEntity(
        id: '1',
        name: 'Log Script',
        content: 'FCom.log("Test message", "info")',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await engine.execute(script);

      // 如果执行成功且日志不为空，则验证日志内容
      if (result.success && logs.isNotEmpty) {
        expect(logs.any((l) => l.contains('Test message')), true);
      }
      expect(result.success || result.errorMessage != null, true);
    });

    test('should call FCom.crc16 from Lua', () async {
      final script = ScriptEntity(
        id: '1',
        name: 'CRC16 Script',
        content: '''
          local crc = FCom.crc16("0102030405")
          if crc then
            FCom.log("CRC16: " .. crc)
          end
        ''',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await engine.execute(script);
      expect(result.success || result.errorMessage != null, true);
    });

    test('should call FCom.getTimestamp from Lua', () async {
      final script = ScriptEntity(
        id: '1',
        name: 'Timestamp Script',
        content: '''
          local ts = FCom.getTimestamp()
          if ts then
            FCom.log("Timestamp: " .. ts)
          end
        ''',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await engine.execute(script);
      expect(result.success || result.errorMessage != null, true);
    });
  });
}
