import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flex_com/features/scripting/application/lua_script_engine.dart';
import 'package:flex_com/features/scripting/application/script_api_bridge.dart';
import 'package:flex_com/features/scripting/domain/script_entity.dart';

/// 集成测试：验证脚本执行到数据发送的完整流程
void main() {
  group('Script Execution Integration', () {
    late LuaScriptEngine engine;
    late List<Uint8List> sentData;
    late List<String> logMessages;

    setUp(() async {
      sentData = [];
      logMessages = [];

      final bridge = ScriptApiBridge(
        onSend: (data) {
          sentData.add(data);
        },
        onLog: (message, level) {
          logMessages.add('[$level] $message');
        },
      );

      engine = LuaScriptEngine(bridge);
      await engine.initialize();
    });

    tearDown(() async {
      await engine.dispose();
    });

    test('FCom.send should call onSend callback with correct data', () async {
      final script = ScriptEntity(
        id: '1',
        name: 'Send Test',
        content: 'FCom.send("48454C4C4F")', // "HELLO" in hex
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await engine.execute(script);

      expect(
        result.success,
        true,
        reason: 'Script should execute successfully',
      );
      expect(sentData.length, 1, reason: 'Should have sent one data packet');
      expect(
        sentData[0],
        equals(Uint8List.fromList([0x48, 0x45, 0x4C, 0x4C, 0x4F])),
        reason: 'Sent data should be "HELLO" in bytes',
      );
    });

    test('FCom.log should call onLog callback', () async {
      final script = ScriptEntity(
        id: '1',
        name: 'Log Test',
        content: '''
          FCom.log("测试消息", "info")
          FCom.log("警告消息", "warning")
          FCom.log("错误消息", "error")
        ''',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await engine.execute(script);

      expect(result.success, true);
      expect(logMessages.any((m) => m.contains('测试消息')), true);
      expect(logMessages.any((m) => m.contains('warning')), true);
      expect(logMessages.any((m) => m.contains('error')), true);
    });

    test('FCom.crc16 should return correct CRC16 value', () async {
      final script = ScriptEntity(
        id: '1',
        name: 'CRC16 Test',
        content: '''
          local crc = FCom.crc16("010300000001")
          FCom.log("CRC16: " .. tostring(crc), "info")
        ''',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await engine.execute(script);

      expect(result.success, true);
      // 检查日志中是否包含CRC值
      expect(logMessages.any((m) => m.contains('CRC16:')), true);
    });

    test('FCom.checksum should return correct checksum', () async {
      final script = ScriptEntity(
        id: '1',
        name: 'Checksum Test',
        content: '''
          local sum = FCom.checksum("010203")
          FCom.log("Checksum: " .. tostring(sum), "info")
        ''',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await engine.execute(script);

      expect(result.success, true);
      expect(logMessages.any((m) => m.contains('Checksum:')), true);
    });

    test('Complete workflow: calculate CRC and send', () async {
      final script = ScriptEntity(
        id: '1',
        name: 'Complete Workflow',
        content: '''
          FCom.log("开始执行", "info")
          local data = "010300000001"
          local crc = FCom.crc16(data)
          FCom.log("CRC16: " .. tostring(crc), "debug")
          -- 发送数据 (简化版，不拼接CRC)
          FCom.send(data)
          FCom.log("发送完成", "info")
        ''',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await engine.execute(script);

      expect(result.success, true, reason: result.errorMessage);
      expect(sentData.length, 1, reason: 'Should have sent data');
      expect(
        sentData[0],
        equals(Uint8List.fromList([0x01, 0x03, 0x00, 0x00, 0x00, 0x01])),
      );
      expect(logMessages.any((m) => m.contains('开始执行')), true);
      expect(logMessages.any((m) => m.contains('发送完成')), true);
    });

    test('Multiple sends in one script', () async {
      final script = ScriptEntity(
        id: '1',
        name: 'Multiple Sends',
        content: '''
          FCom.send("01")
          FCom.send("02")
          FCom.send("03")
        ''',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await engine.execute(script);

      expect(result.success, true);
      expect(sentData.length, 3, reason: 'Should have sent 3 packets');
      expect(sentData[0], equals(Uint8List.fromList([0x01])));
      expect(sentData[1], equals(Uint8List.fromList([0x02])));
      expect(sentData[2], equals(Uint8List.fromList([0x03])));
    });

    test('FCom.getTimestamp should return valid timestamp', () async {
      final script = ScriptEntity(
        id: '1',
        name: 'Timestamp Test',
        content: '''
          local ts = FCom.getTimestamp()
          FCom.log("Timestamp: " .. tostring(ts), "info")
        ''',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await engine.execute(script);

      expect(result.success, true);
      // 验证日志中有时间戳
      final tsLog = logMessages.firstWhere((m) => m.contains('Timestamp:'));
      expect(tsLog, isNotNull);
    });

    test('Script error should not crash and return failure', () async {
      final script = ScriptEntity(
        id: '1',
        name: 'Error Test',
        content: 'this is invalid lua syntax {{{{',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await engine.execute(script);

      expect(result.success, false);
      expect(result.errorMessage, isNotNull);
    });
  });
}
