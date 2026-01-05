import 'dart:async';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/checksum_utils.dart';
import '../../../core/utils/hex_utils.dart';
import '../../commands/domain/command.dart';
import '../../connection/application/connection_providers.dart';
import '../../scripting/application/hook_service.dart';
import '../domain/send_settings.dart';
import '../domain/serial_data_entry.dart';
import 'serial_data_providers.dart';

part 'send_helper_providers.g.dart';

/// 发送设置状态管理
@Riverpod(keepAlive: true)
class SendSettingsNotifier extends _$SendSettingsNotifier {
  @override
  SendSettings build() {
    return const SendSettings();
  }

  /// 设置是否追加换行符
  void setAppendNewline(bool value) {
    state = state.copyWith(appendNewline: value);
  }

  /// 设置校验类型
  void setChecksumType(ChecksumType type) {
    state = state.copyWith(checksumType: type);
  }

  /// 设置循环发送开关
  void setCyclicSendEnabled(bool enabled) {
    state = state.copyWith(cyclicSendEnabled: enabled);
  }

  /// 设置循环发送间隔
  void setCyclicIntervalMs(int intervalMs) {
    // 限制在合法范围内
    final clampedInterval = intervalMs.clamp(
      SendSettings.minIntervalMs,
      SendSettings.maxIntervalMs,
    );
    state = state.copyWith(cyclicIntervalMs: clampedInterval);
  }
}

/// 循环发送状态
class CyclicSendState {
  const CyclicSendState({
    this.isRunning = false,
    this.sendCount = 0,
    this.lastError,
  });

  /// 是否正在循环发送
  final bool isRunning;

  /// 已发送次数
  final int sendCount;

  /// 最后一次错误
  final String? lastError;

  CyclicSendState copyWith({
    bool? isRunning,
    int? sendCount,
    String? lastError,
  }) {
    return CyclicSendState(
      isRunning: isRunning ?? this.isRunning,
      sendCount: sendCount ?? this.sendCount,
      lastError: lastError,
    );
  }
}

/// 循环发送控制器
@Riverpod(keepAlive: true)
class CyclicSendController extends _$CyclicSendController {
  Timer? _timer;
  Uint8List? _currentData;

  @override
  CyclicSendState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
    });

    return const CyclicSendState();
  }

  /// 开始循环发送
  ///
  /// [rawData] 原始数据（未处理）
  /// [sendMode] 发送模式 (ASCII/HEX)
  void start(String rawText, DataDisplayMode sendMode) {
    if (state.isRunning) return;

    // 解析数据
    Uint8List? data;
    try {
      if (sendMode == DataDisplayMode.hex) {
        data = HexUtils.hexStringToBytes(rawText);
      } else {
        data = HexUtils.asciiStringToBytes(rawText);
      }
    } on FormatException catch (e) {
      state = state.copyWith(lastError: '格式错误: ${e.message}');
      return;
    }

    if (data.isEmpty) {
      state = state.copyWith(lastError: '发送数据为空');
      return;
    }

    _currentData = data;
    state = const CyclicSendState(isRunning: true);

    // 立即发送一次
    _sendOnce();

    // 启动定时器
    final settings = ref.read(sendSettingsProvider);
    _timer = Timer.periodic(
      Duration(milliseconds: settings.cyclicIntervalMs),
      (_) => _sendOnce(),
    );
  }

  /// 停止循环发送
  void stop() {
    _timer?.cancel();
    _timer = null;
    _currentData = null;
    state = state.copyWith(isRunning: false);
  }

  /// 发送一次数据
  Future<void> _sendOnce() async {
    if (_currentData == null) return;

    final connectionState = ref.read(unifiedConnectionProvider);
    if (!connectionState.isConnected) {
      stop();
      state = state.copyWith(lastError: '连接已断开');
      return;
    }

    try {
      // 获取设置并处理数据
      final settings = ref.read(sendSettingsProvider);
      var processedData = _processData(_currentData!, settings);

      // Process through TX Hook if active
      final hookService = ref.read(hookServiceProvider.notifier);
      processedData = await hookService.processTxData(processedData);

      // 发送数据
      await ref.read(unifiedConnectionProvider.notifier).send(processedData);

      // 添加到日志
      ref.read(serialDataLogProvider.notifier).addSentData(processedData);

      // 更新计数
      state = state.copyWith(sendCount: state.sendCount + 1, lastError: null);
    } catch (e) {
      state = state.copyWith(lastError: '发送失败: $e');
    }
  }

  /// 处理数据（追加换行符、校验等）
  Uint8List _processData(Uint8List data, SendSettings settings) {
    var result = data;

    // 追加换行符
    if (settings.appendNewline) {
      final newData = Uint8List(result.length + 2);
      newData.setRange(0, result.length, result);
      newData[result.length] = 0x0D; // \r
      newData[result.length + 1] = 0x0A; // \n
      result = newData;
    }

    // 追加校验
    switch (settings.checksumType) {
      case ChecksumType.none:
        break;
      case ChecksumType.checksum8:
        result = ChecksumUtils.appendChecksum8(result);
      case ChecksumType.crc16Modbus:
        result = ChecksumUtils.appendCrc16Modbus(result);
    }

    return result;
  }
}

/// 处理发送数据的辅助函数
///
/// 根据当前设置处理原始数据（追加换行符、校验等）
Uint8List processSendData(Uint8List data, SendSettings settings) {
  var result = data;

  // 追加换行符
  if (settings.appendNewline) {
    final newData = Uint8List(result.length + 2);
    newData.setRange(0, result.length, result);
    newData[result.length] = 0x0D; // \r
    newData[result.length + 1] = 0x0A; // \n
    result = newData;
  }

  // 追加校验
  switch (settings.checksumType) {
    case ChecksumType.none:
      break;
    case ChecksumType.checksum8:
      result = ChecksumUtils.appendChecksum8(result);
    case ChecksumType.crc16Modbus:
      result = ChecksumUtils.appendCrc16Modbus(result);
  }

  return result;
}

/// 发送面板控制器状态
class SendPanelControllerState {
  const SendPanelControllerState({this.lastError, this.isSending = false});

  final String? lastError;
  final bool isSending;

  SendPanelControllerState copyWith({
    String? lastError,
    bool? isSending,
    bool clearError = false,
  }) {
    return SendPanelControllerState(
      lastError: clearError ? null : (lastError ?? this.lastError),
      isSending: isSending ?? this.isSending,
    );
  }
}

/// 发送面板控制器
///
/// 用于从外部（如指令列表）触发发送操作
@Riverpod(keepAlive: true)
class SendPanelController extends _$SendPanelController {
  @override
  SendPanelControllerState build() {
    return const SendPanelControllerState();
  }

  /// 发送指令
  Future<bool> sendCommand(Command command) async {
    final connectionState = ref.read(unifiedConnectionProvider);
    if (!connectionState.isConnected) {
      state = state.copyWith(lastError: '连接未建立');
      return false;
    }

    Uint8List? data;
    try {
      if (command.mode == DataDisplayMode.hex) {
        data = HexUtils.hexStringToBytes(command.data);
      } else {
        data = HexUtils.asciiStringToBytes(command.data);
      }
    } on FormatException catch (e) {
      state = state.copyWith(lastError: '格式错误: ${e.message}');
      return false;
    }

    if (data.isEmpty) {
      state = state.copyWith(lastError: '发送数据为空');
      return false;
    }

    // 处理数据（追加换行符、校验等）
    final settings = ref.read(sendSettingsProvider);
    data = processSendData(data, settings);

    state = state.copyWith(isSending: true, clearError: true);

    try {
      await ref.read(unifiedConnectionProvider.notifier).send(data);
      // Add to log
      ref.read(serialDataLogProvider.notifier).addSentData(data);
      state = state.copyWith(isSending: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSending: false, lastError: '发送失败: $e');
      return false;
    }
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
