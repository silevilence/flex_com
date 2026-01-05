import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flex_com/features/scripting/domain/script_entity.dart';
import 'package:flex_com/features/scripting/domain/script_hook.dart';
import 'package:flex_com/features/scripting/application/hook_engine.dart';
import 'package:flex_com/features/scripting/application/script_api_bridge.dart';

void main() {
  late HookEngine engine;
  late List<Uint8List> sentData;
  late List<String> logMessages;

  setUp(() async {
    sentData = [];
    logMessages = [];

    final apiBridge = ScriptApiBridge(
      onSend: (data) => sentData.add(data),
      onLog: (message, level) => logMessages.add('[$level] $message'),
    );

    engine = HookEngine(apiBridge);
    await engine.initialize();
  });

  tearDown(() async {
    await engine.dispose();
  });

  group('Pipeline Hook (Rx)', () {
    test('应能执行接收预处理脚本', () async {
      final script = ScriptEntity(
        id: 'test-1',
        name: 'Rx Preprocessor',
        content: '''-- 接收数据预处理
local input = FCom.input
FCom.log("收到数据长度: " .. input.length)

-- 简单处理：在数据前添加前缀 (0xAA = 170)
local processed = {170}
for i = 1, input.length do
  table.insert(processed, input.raw[i])
end

FCom.setProcessedData(processed)
''',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final context = PipelineHookContext(
        rawData: Uint8List.fromList([0x01, 0x02, 0x03]),
        isRx: true,
        timestamp: DateTime.now(),
      );

      final result = await engine.executePipelineHook(script, context);

      expect(result.success, isTrue);
      expect(result.processedData, isNotNull);
      expect(result.processedData!.first, 0xAA);
      expect(result.processedData!.length, 4);
    });

    test('脚本不设置处理数据时应返回原始数据', () async {
      final script = ScriptEntity(
        id: 'test-2',
        name: 'Pass Through',
        content: '''-- 不做任何处理
FCom.log("Pass through")
''',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final rawData = Uint8List.fromList([0x01, 0x02]);
      final context = PipelineHookContext(
        rawData: rawData,
        isRx: true,
        timestamp: DateTime.now(),
      );

      final result = await engine.executePipelineHook(script, context);

      expect(result.success, isTrue);
      expect(result.processedData, equals(rawData));
    });

    test('脚本错误应返回失败结果', () async {
      final script = ScriptEntity(
        id: 'test-3',
        name: 'Error Script',
        content: 'undefined_function()',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final context = PipelineHookContext(
        rawData: Uint8List.fromList([0x01]),
        isRx: true,
        timestamp: DateTime.now(),
      );

      final result = await engine.executePipelineHook(script, context);

      expect(result.success, isFalse);
      expect(result.errorMessage, isNotNull);
    });
  });

  group('Pipeline Hook (Tx)', () {
    test('应能执行发送后处理脚本', () async {
      final script = ScriptEntity(
        id: 'test-tx-1',
        name: 'Tx Postprocessor',
        content: '''-- 发送数据后处理：添加校验和
local input = FCom.input
local sum = 0
for i = 1, input.length do
  sum = sum + input.raw[i]
end
sum = sum % 256

local processed = {}
for i = 1, input.length do
  table.insert(processed, input.raw[i])
end
table.insert(processed, sum)

FCom.setProcessedData(processed)
''',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final context = PipelineHookContext(
        rawData: Uint8List.fromList([0x01, 0x02, 0x03]),
        isRx: false,
        timestamp: DateTime.now(),
      );

      final result = await engine.executePipelineHook(script, context);

      expect(result.success, isTrue);
      expect(result.processedData, isNotNull);
      expect(result.processedData!.length, 4);
      // 校验和: (1+2+3) % 256 = 6
      expect(result.processedData!.last, 6);
    });

    test('isRx 标志应正确传递', () async {
      final script = ScriptEntity(
        id: 'test-tx-2',
        name: 'Check isRx',
        content: '''if FCom.input.isRx then
  FCom.log("Is RX")
else
  FCom.log("Is TX")
end
''',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final context = PipelineHookContext(
        rawData: Uint8List.fromList([0x01]),
        isRx: false,
        timestamp: DateTime.now(),
      );

      final result = await engine.executePipelineHook(script, context);

      expect(result.success, isTrue);
      expect(logMessages.any((m) => m.contains('Is TX')), isTrue);
    });
  });

  group('Reply Hook', () {
    test('应能执行回复脚本并返回响应', () async {
      final script = ScriptEntity(
        id: 'reply-1',
        name: 'Echo Reply',
        content: '''-- 简单回声：返回收到的数据
local input = FCom.input
FCom.setResponse(input.hex)
''',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final context = ReplyHookContext(
        receivedData: Uint8List.fromList([0xAA, 0xBB]),
        timestamp: DateTime.now(),
      );

      final result = await engine.executeReplyHook(script, context);

      expect(result.success, isTrue);
      expect(result.responseData, isNotNull);
      expect(result.responseData, equals(Uint8List.fromList([0xAA, 0xBB])));
      expect(result.shouldContinue, isTrue);
    });

    test('脚本跳过回复时应返回 shouldContinue=false', () async {
      final script = ScriptEntity(
        id: 'reply-2',
        name: 'Skip Reply',
        content: '''-- 检查数据，决定是否回复
local input = FCom.input
if input.raw[1] == 255 then
  FCom.skipReply()
else
  FCom.setResponse("0102")
end
''',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 发送 0xFF (255) 应该跳过
      final context1 = ReplyHookContext(
        receivedData: Uint8List.fromList([0xFF]),
        timestamp: DateTime.now(),
      );
      final result1 = await engine.executeReplyHook(script, context1);
      expect(result1.shouldContinue, isFalse);

      // 重新初始化引擎以重置状态
      await engine.dispose();
      final apiBridge = ScriptApiBridge(
        onSend: (data) => sentData.add(data),
        onLog: (message, level) => logMessages.add('[$level] $message'),
      );
      engine = HookEngine(apiBridge);
      await engine.initialize();

      // 发送其他数据应该回复
      final context2 = ReplyHookContext(
        receivedData: Uint8List.fromList([0x00]),
        timestamp: DateTime.now(),
      );
      final result2 = await engine.executeReplyHook(script, context2);
      expect(result2.shouldContinue, isTrue);
      expect(result2.responseData, isNotNull);
    });

    test('脚本不设置响应时应返回跳过结果', () async {
      final script = ScriptEntity(
        id: 'reply-3',
        name: 'No Response',
        content: 'FCom.log("Received data but no response")',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final context = ReplyHookContext(
        receivedData: Uint8List.fromList([0x01]),
        timestamp: DateTime.now(),
      );

      final result = await engine.executeReplyHook(script, context);

      expect(result.success, isTrue);
      expect(result.responseData, isNull);
    });
  });

  group('Task Hook', () {
    test('应能执行任务脚本', () async {
      final script = ScriptEntity(
        id: 'task-1',
        name: 'Send Sequence',
        content: '''-- 发送测试序列
FCom.send("0102")
FCom.log("Sent first packet")
FCom.send("0304")
FCom.log("Sent second packet")
''',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await engine.executeTaskHook(script);

      expect(result.success, isTrue);
      expect(sentData.length, 2);
      expect(sentData[0], equals(Uint8List.fromList([0x01, 0x02])));
      expect(sentData[1], equals(Uint8List.fromList([0x03, 0x04])));
    });

    test('任务脚本应能使用校验函数', () async {
      final script = ScriptEntity(
        id: 'task-2',
        name: 'CRC Task',
        content: '''local data = "0102"
local crc = FCom.crc16(data)
FCom.log("CRC16: " .. crc)
FCom.send(data .. crc)
''',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await engine.executeTaskHook(script);

      expect(result.success, isTrue);
      expect(sentData.length, 1);
      // 数据应该包含原始 2 字节 + CRC 2 字节 = 4 字节
      expect(sentData[0].length, 4);
    });

    test('任务脚本错误应返回失败结果', () async {
      final script = ScriptEntity(
        id: 'task-3',
        name: 'Error Task',
        content: 'error("Intentional error")',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await engine.executeTaskHook(script);

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('error'));
    });
  });

  group('FCom API', () {
    test('bytesToHex 应正确转换', () async {
      final script = ScriptEntity(
        id: 'api-1',
        name: 'BytesToHex',
        // 使用十进制避免 Lua 解析问题 (170=0xAA, 187=0xBB, 204=0xCC)
        content: '''local bytes = {170, 187, 204}
local hex = FCom.bytesToHex(bytes)
FCom.log("Hex: " .. hex)
''',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await engine.executeTaskHook(script);

      expect(logMessages.any((m) => m.contains('AABBCC')), isTrue);
    });

    test('hexToBytes 应正确转换', () async {
      final script = ScriptEntity(
        id: 'api-2',
        name: 'HexToBytes',
        content: '''local bytes = FCom.hexToBytes("0102")
FCom.log("Byte 1: " .. bytes[1])
FCom.log("Byte 2: " .. bytes[2])
''',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await engine.executeTaskHook(script);

      expect(logMessages.any((m) => m.contains('Byte 1: 1')), isTrue);
      expect(logMessages.any((m) => m.contains('Byte 2: 2')), isTrue);
    });

    test('getTimestamp 应返回当前时间戳', () async {
      final script = ScriptEntity(
        id: 'api-3',
        name: 'Timestamp',
        content: '''local ts = FCom.getTimestamp()
FCom.log("Timestamp: " .. ts)
''',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await engine.executeTaskHook(script);

      // 验证日志中包含有效的时间戳
      final tsLog = logMessages.firstWhere(
        (m) => m.contains('Timestamp:'),
        orElse: () => '',
      );
      expect(tsLog, isNotEmpty);
    });
  });
}
