import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flex_com/features/scripting/application/hook_engine.dart';
import 'package:flex_com/features/scripting/application/script_api_bridge.dart';
import 'package:flex_com/features/scripting/domain/script_entity.dart';
import 'package:flex_com/features/scripting/domain/script_hook.dart';

void main() {
  group('Hook Data Processing Flow Tests', () {
    late HookEngine engine;
    late List<Uint8List> sentData;
    late List<String> logMessages;

    final rxPreprocessScript = ScriptEntity(
      id: 'script-rx',
      name: 'Rx Preprocessor',
      content: '''local input = FCom.input
local processed = {170}
for i = 1, input.length do
  table.insert(processed, input.raw[i])
end
FCom.setProcessedData(processed)
FCom.log("Rx done")
''',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isEnabled: true,
    );

    final txPostprocessScript = ScriptEntity(
      id: 'script-tx',
      name: 'Tx Postprocessor',
      content: '''local input = FCom.input
local processed = {}
for i = 1, input.length do
  table.insert(processed, input.raw[i])
end
table.insert(processed, 85)
FCom.setProcessedData(processed)
FCom.log("Tx done")
''',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isEnabled: true,
    );

    final replyScript = ScriptEntity(
      id: 'script-reply',
      name: 'Auto Reply',
      content: '''local input = FCom.input
FCom.log("Got: " .. input.hex)
FCom.setResponse(input.hex)
''',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isEnabled: true,
    );

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

    group('Rx Preprocess Hook', () {
      test('should process received data and add prefix', () async {
        final context = PipelineHookContext(
          rawData: Uint8List.fromList([0x01, 0x02, 0x03]),
          isRx: true,
          timestamp: DateTime.now(),
        );

        final result = await engine.executePipelineHook(
          rxPreprocessScript,
          context,
        );

        expect(result.success, isTrue, reason: 'Script should succeed');
        expect(result.processedData, isNotNull, reason: 'Should return data');
        expect(result.processedData!.length, equals(4), reason: 'Length +1');
        expect(result.processedData!.first, equals(0xAA), reason: 'First=0xAA');
        expect(
          result.processedData!.sublist(1),
          equals([0x01, 0x02, 0x03]),
          reason: 'Original data preserved',
        );
      });

      test('isRx flag should be true for Rx hook', () async {
        final checkIsRxScript = ScriptEntity(
          id: 'check-isRx',
          name: 'Check isRx',
          content: '''if FCom.input.isRx then
  FCom.log("IS_RX_TRUE")
else
  FCom.log("IS_RX_FALSE")
end
''',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final context = PipelineHookContext(
          rawData: Uint8List.fromList([0x01]),
          isRx: true,
          timestamp: DateTime.now(),
        );

        await engine.executePipelineHook(checkIsRxScript, context);

        expect(
          logMessages.any((m) => m.contains('IS_RX_TRUE')),
          isTrue,
          reason: 'isRx should be true',
        );
      });
    });

    group('Tx Postprocess Hook', () {
      test('should process send data and add suffix', () async {
        final context = PipelineHookContext(
          rawData: Uint8List.fromList([0x01, 0x02, 0x03]),
          isRx: false,
          timestamp: DateTime.now(),
        );

        final result = await engine.executePipelineHook(
          txPostprocessScript,
          context,
        );

        expect(result.success, isTrue, reason: 'Script should succeed');
        expect(result.processedData, isNotNull, reason: 'Should return data');
        expect(result.processedData!.length, equals(4), reason: 'Length +1');
        expect(result.processedData!.last, equals(0x55), reason: 'Last=0x55');
        expect(
          result.processedData!.sublist(0, 3),
          equals([0x01, 0x02, 0x03]),
          reason: 'Original data preserved',
        );
      });

      test('isRx flag should be false for Tx hook', () async {
        final checkIsRxScript = ScriptEntity(
          id: 'check-isRx-tx',
          name: 'Check isRx TX',
          content: '''if FCom.input.isRx then
  FCom.log("IS_RX_TRUE")
else
  FCom.log("IS_RX_FALSE")
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

        await engine.executePipelineHook(checkIsRxScript, context);

        expect(
          logMessages.any((m) => m.contains('IS_RX_FALSE')),
          isTrue,
          reason: 'isRx should be false',
        );
      });
    });

    group('Reply Hook', () {
      test('should process data and return response', () async {
        final context = ReplyHookContext(
          receivedData: Uint8List.fromList([0xAA, 0xBB]),
          timestamp: DateTime.now(),
        );

        final result = await engine.executeReplyHook(replyScript, context);

        expect(result.success, isTrue, reason: 'Script should succeed');
        expect(result.responseData, isNotNull, reason: 'Should return data');
        expect(
          result.responseData,
          equals([0xAA, 0xBB]),
          reason: 'Echo should return original',
        );
      });

      test('skipReply should prevent response', () async {
        final skipScript = ScriptEntity(
          id: 'skip-reply',
          name: 'Skip Reply',
          content: '''FCom.log("Skipping reply")
FCom.skipReply()
''',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final context = ReplyHookContext(
          receivedData: Uint8List.fromList([0x01]),
          timestamp: DateTime.now(),
        );

        final result = await engine.executeReplyHook(skipScript, context);

        expect(result.success, isTrue);
        expect(result.shouldContinue, isFalse, reason: 'Should not continue');
        expect(result.responseData, isNull, reason: 'No response data');
      });
    });

    group('Error Handling', () {
      test('syntax error should return failure', () async {
        final errorScript = ScriptEntity(
          id: 'error-script',
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

        final result = await engine.executePipelineHook(errorScript, context);

        expect(result.success, isFalse, reason: 'Script error should fail');
        expect(result.errorMessage, isNotNull, reason: 'Should have error msg');
      });

      test('no output should return original data', () async {
        final noOutputScript = ScriptEntity(
          id: 'no-output',
          name: 'No Output',
          content: '''FCom.log("Processing but not setting output")
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

        final result = await engine.executePipelineHook(
          noOutputScript,
          context,
        );

        expect(result.success, isTrue);
        expect(
          result.processedData,
          equals(rawData),
          reason: 'Return original',
        );
      });
    });

    group('FCom API Functions', () {
      test('FCom.send should send data', () async {
        final sendScript = ScriptEntity(
          id: 'send-script',
          name: 'Send Data',
          content: '''FCom.send("AABB")
''',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await engine.executeTaskHook(sendScript);

        expect(sentData.length, equals(1), reason: 'Should send one packet');
        expect(sentData.first, equals([0xAA, 0xBB]), reason: 'Data correct');
      });

      test(
        'FCom.bytesToHex and hexToBytes should convert correctly',
        () async {
          final convertScript = ScriptEntity(
            id: 'convert-script',
            name: 'Convert Data',
            content: '''local bytes = {0xAA, 0xBB, 0xCC}
local hex = FCom.bytesToHex(bytes)
FCom.log("HEX: " .. hex)
local back = FCom.hexToBytes(hex)
FCom.log("LEN: " .. #back)
''',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await engine.executeTaskHook(convertScript);

          expect(
            logMessages.any(
              (m) => m.toUpperCase().contains('HEX:') && m.contains('AABBCC'),
            ),
            isTrue,
            reason: 'bytesToHex should return correct hex, logs: $logMessages',
          );
          expect(
            logMessages.any((m) => m.contains('LEN: 3')),
            isTrue,
            reason: 'hexToBytes should return correct length',
          );
        },
        skip: 'Task hook log stream not connected in test',
      );

      test('FCom.log should output logs', () async {
        final logScript = ScriptEntity(
          id: 'log-script',
          name: 'Log Test',
          content: '''FCom.log("Test message")
FCom.log("Warning", "warning")
FCom.log("Error", "error")
''',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await engine.executeTaskHook(logScript);

        expect(logMessages.any((m) => m.contains('Test message')), isTrue);
        expect(logMessages.any((m) => m.contains('Warning')), isTrue);
        expect(logMessages.any((m) => m.contains('Error')), isTrue);
      });
    });
  });
}
