import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flex_com/features/auto_reply/domain/reply_handler.dart';
import 'package:flex_com/features/auto_reply/domain/match_reply_config.dart';
import 'package:flex_com/features/auto_reply/domain/sequential_reply_config.dart';

void main() {
  group('ReplyHandler interface', () {
    test('MatchReplyHandler should implement ReplyHandler', () {
      final config = MatchReplyConfig(
        rules: [
          MatchReplyRule(
            id: '1',
            name: 'Test',
            triggerPattern: 'AA BB',
            responseData: 'CC DD',
          ),
        ],
      );

      final handler = MatchReplyHandler(config: config);

      expect(handler, isA<ReplyHandler>());
    });

    test('SequentialReplyHandler should implement ReplyHandler', () {
      final config = SequentialReplyConfig(
        frames: [SequentialReplyFrame(id: '1', name: 'F1', data: 'AA')],
      );

      final handler = SequentialReplyHandler(config: config);

      expect(handler, isA<ReplyHandler>());
    });
  });

  group('MatchReplyHandler', () {
    test('should return response when hex pattern matches', () {
      final config = MatchReplyConfig(
        rules: [
          MatchReplyRule(
            id: '1',
            name: 'Test',
            triggerPattern: 'AA BB',
            responseData: 'CC DD',
            triggerMode: DataMode.hex,
            responseMode: DataMode.hex,
          ),
        ],
      );

      final handler = MatchReplyHandler(config: config);
      final receivedData = Uint8List.fromList([0xAA, 0xBB, 0x11, 0x22]);

      final result = handler.processReceivedData(receivedData);

      expect(result, isNotNull);
      expect(result!.responseData, equals(Uint8List.fromList([0xCC, 0xDD])));
    });

    test('should return null when no pattern matches', () {
      final config = MatchReplyConfig(
        rules: [
          MatchReplyRule(
            id: '1',
            name: 'Test',
            triggerPattern: 'AA BB',
            responseData: 'CC DD',
          ),
        ],
      );

      final handler = MatchReplyHandler(config: config);
      final receivedData = Uint8List.fromList([0x11, 0x22, 0x33]);

      final result = handler.processReceivedData(receivedData);

      expect(result, isNull);
    });

    test('should skip disabled rules', () {
      final config = MatchReplyConfig(
        rules: [
          MatchReplyRule(
            id: '1',
            name: 'Disabled Rule',
            triggerPattern: 'AA BB',
            responseData: 'CC DD',
            enabled: false,
          ),
        ],
      );

      final handler = MatchReplyHandler(config: config);
      final receivedData = Uint8List.fromList([0xAA, 0xBB]);

      final result = handler.processReceivedData(receivedData);

      expect(result, isNull);
    });

    test('should match ASCII pattern', () {
      final config = MatchReplyConfig(
        rules: [
          MatchReplyRule(
            id: '1',
            name: 'ASCII Test',
            triggerPattern: 'HELLO',
            responseData: 'WORLD',
            triggerMode: DataMode.ascii,
            responseMode: DataMode.ascii,
          ),
        ],
      );

      final handler = MatchReplyHandler(config: config);
      // "HELLO" in ASCII
      final receivedData = Uint8List.fromList([0x48, 0x45, 0x4C, 0x4C, 0x4F]);

      final result = handler.processReceivedData(receivedData);

      expect(result, isNotNull);
      // "WORLD" in ASCII
      expect(
        result!.responseData,
        equals(Uint8List.fromList([0x57, 0x4F, 0x52, 0x4C, 0x44])),
      );
    });

    test('should match first matching rule when multiple rules match', () {
      final config = MatchReplyConfig(
        rules: [
          MatchReplyRule(
            id: '1',
            name: 'First',
            triggerPattern: 'AA',
            responseData: '11',
          ),
          MatchReplyRule(
            id: '2',
            name: 'Second',
            triggerPattern: 'AA',
            responseData: '22',
          ),
        ],
      );

      final handler = MatchReplyHandler(config: config);
      final receivedData = Uint8List.fromList([0xAA]);

      final result = handler.processReceivedData(receivedData);

      expect(result, isNotNull);
      expect(result!.responseData, equals(Uint8List.fromList([0x11])));
    });
  });

  group('SequentialReplyHandler', () {
    test('should return first frame on first call', () {
      final config = SequentialReplyConfig(
        frames: [
          SequentialReplyFrame(id: '1', name: 'F1', data: 'AA'),
          SequentialReplyFrame(id: '2', name: 'F2', data: 'BB'),
        ],
      );

      final handler = SequentialReplyHandler(config: config);
      final receivedData = Uint8List.fromList([0x11]);

      final result = handler.processReceivedData(receivedData);

      expect(result, isNotNull);
      expect(result!.responseData, equals(Uint8List.fromList([0xAA])));
    });

    test('should advance to next frame on subsequent calls', () {
      final config = SequentialReplyConfig(
        frames: [
          SequentialReplyFrame(id: '1', name: 'F1', data: 'AA'),
          SequentialReplyFrame(id: '2', name: 'F2', data: 'BB'),
        ],
      );

      final handler = SequentialReplyHandler(config: config);
      final receivedData = Uint8List.fromList([0x11]);

      handler.processReceivedData(receivedData);
      final result = handler.processReceivedData(receivedData);

      expect(result, isNotNull);
      expect(result!.responseData, equals(Uint8List.fromList([0xBB])));
    });

    test('should return null when all frames exhausted without loop', () {
      final config = SequentialReplyConfig(
        frames: [SequentialReplyFrame(id: '1', name: 'F1', data: 'AA')],
        loopEnabled: false,
      );

      final handler = SequentialReplyHandler(config: config);
      final receivedData = Uint8List.fromList([0x11]);

      handler.processReceivedData(receivedData);
      final result = handler.processReceivedData(receivedData);

      expect(result, isNull);
    });

    test('should loop back to first frame when loopEnabled', () {
      final config = SequentialReplyConfig(
        frames: [
          SequentialReplyFrame(id: '1', name: 'F1', data: 'AA'),
          SequentialReplyFrame(id: '2', name: 'F2', data: 'BB'),
        ],
        loopEnabled: true,
      );

      final handler = SequentialReplyHandler(config: config);
      final receivedData = Uint8List.fromList([0x11]);

      handler.processReceivedData(receivedData); // AA
      handler.processReceivedData(receivedData); // BB
      final result = handler.processReceivedData(receivedData); // Loop to AA

      expect(result, isNotNull);
      expect(result!.responseData, equals(Uint8List.fromList([0xAA])));
    });

    test('should support reset to beginning', () {
      final config = SequentialReplyConfig(
        frames: [
          SequentialReplyFrame(id: '1', name: 'F1', data: 'AA'),
          SequentialReplyFrame(id: '2', name: 'F2', data: 'BB'),
        ],
      );

      final handler = SequentialReplyHandler(config: config);
      final receivedData = Uint8List.fromList([0x11]);

      handler.processReceivedData(receivedData); // AA
      handler.reset();
      final result = handler.processReceivedData(receivedData);

      expect(result, isNotNull);
      expect(result!.responseData, equals(Uint8List.fromList([0xAA])));
    });

    test('should support jump to specific index', () {
      final config = SequentialReplyConfig(
        frames: [
          SequentialReplyFrame(id: '1', name: 'F1', data: 'AA'),
          SequentialReplyFrame(id: '2', name: 'F2', data: 'BB'),
          SequentialReplyFrame(id: '3', name: 'F3', data: 'CC'),
        ],
      );

      final handler = SequentialReplyHandler(config: config);
      final receivedData = Uint8List.fromList([0x11]);

      handler.jumpTo(2);
      final result = handler.processReceivedData(receivedData);

      expect(result, isNotNull);
      expect(result!.responseData, equals(Uint8List.fromList([0xCC])));
    });

    test('should return null for empty frames list', () {
      const config = SequentialReplyConfig(frames: []);

      final handler = SequentialReplyHandler(config: config);
      final receivedData = Uint8List.fromList([0x11]);

      final result = handler.processReceivedData(receivedData);

      expect(result, isNull);
    });

    test('currentIndex getter should return current position', () {
      final config = SequentialReplyConfig(
        frames: [
          SequentialReplyFrame(id: '1', name: 'F1', data: 'AA'),
          SequentialReplyFrame(id: '2', name: 'F2', data: 'BB'),
        ],
      );

      final handler = SequentialReplyHandler(config: config);

      expect(handler.currentIndex, 0);

      handler.processReceivedData(Uint8List.fromList([0x11]));
      expect(handler.currentIndex, 1);
    });
  });
}
