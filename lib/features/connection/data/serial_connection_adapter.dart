import 'dart:async';
import 'dart:typed_data';

import '../../serial/data/serial_isolate_service.dart';
import '../../serial/domain/serial_port_config.dart' as serial;
import '../domain/connection.dart';
import '../domain/connection_config.dart';

/// Serial port adapter implementing [IConnection].
///
/// This adapts the existing [SerialIsolateService] to the unified
/// connection interface, allowing serial ports to be used interchangeably
/// with network connections.
class SerialConnectionAdapter implements IConnection {
  SerialConnectionAdapter({SerialIsolateService? isolateService})
    : _isolateService = isolateService ?? SerialIsolateService();

  final SerialIsolateService _isolateService;
  SerialConnectionConfig? _config;
  bool _isOpen = false;
  bool _isInitialized = false;

  @override
  ConnectionType get connectionType => ConnectionType.serial;

  @override
  ConnectionConfig? get currentConfig => _config;

  @override
  Stream<Uint8List> get dataStream => _isolateService.dataStream;

  @override
  bool get isOpen => _isOpen;

  /// Ensures the isolate service is started.
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _isolateService.start();
      _isInitialized = true;
    }
  }

  @override
  Future<void> open(ConnectionConfig config) async {
    if (config is! SerialConnectionConfig) {
      throw const ConnectionException(
        'Invalid configuration type for Serial connection',
      );
    }

    await _ensureInitialized();

    if (_isOpen) {
      await close();
    }

    // Convert to legacy SerialPortConfig
    final legacyConfig = _toLegacyConfig(config);

    try {
      await _isolateService.openPort(legacyConfig);
      _config = config;
      _isOpen = true;
    } on SerialPortException catch (e) {
      throw ConnectionException(e.message);
    }
  }

  @override
  Future<void> close() async {
    if (!_isOpen) return;

    try {
      await _isolateService.closePort();
    } finally {
      _config = null;
      _isOpen = false;
    }
  }

  @override
  Future<void> send(Uint8List data) async {
    if (!_isOpen) {
      throw const ConnectionException('Serial port is not open');
    }

    try {
      await _isolateService.sendData(data);
    } on SerialPortException catch (e) {
      throw ConnectionException(e.message);
    }
  }

  @override
  Future<void> dispose() async {
    if (_isOpen) {
      await close();
    }
    await _isolateService.dispose();
    _isInitialized = false;
  }

  /// Gets the list of available serial ports.
  Future<List<String>> getAvailablePorts() async {
    await _ensureInitialized();
    return _isolateService.getAvailablePorts();
  }

  /// Converts new config format to legacy SerialPortConfig.
  serial.SerialPortConfig _toLegacyConfig(SerialConnectionConfig config) {
    return serial.SerialPortConfig(
      portName: config.portName,
      baudRate: config.baudRate,
      dataBits: config.dataBits,
      stopBits: config.stopBits,
      parity: _toLegacyParity(config.parity),
      flowControl: _toLegacyFlowControl(config.flowControl),
    );
  }

  serial.Parity _toLegacyParity(SerialParity parity) {
    switch (parity) {
      case SerialParity.none:
        return serial.Parity.none;
      case SerialParity.odd:
        return serial.Parity.odd;
      case SerialParity.even:
        return serial.Parity.even;
      case SerialParity.mark:
        return serial.Parity.mark;
      case SerialParity.space:
        return serial.Parity.space;
    }
  }

  serial.FlowControl _toLegacyFlowControl(SerialFlowControl flowControl) {
    switch (flowControl) {
      case SerialFlowControl.none:
        return serial.FlowControl.none;
      case SerialFlowControl.hardware:
        return serial.FlowControl.hardware;
      case SerialFlowControl.software:
        return serial.FlowControl.software;
      case SerialFlowControl.dtrDsr:
        return serial.FlowControl.dtrDsr;
    }
  }
}
