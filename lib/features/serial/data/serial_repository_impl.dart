import 'dart:typed_data';

import '../domain/serial_port_config.dart';
import 'serial_isolate_service.dart';
import 'serial_repository.dart';

/// Implementation of [SerialRepository] that delegates to [SerialIsolateService].
///
/// This acts as a bridge between the application layer and the isolate,
/// managing the lifecycle and providing a clean API.
class SerialRepositoryImpl implements SerialRepository {
  SerialRepositoryImpl({SerialIsolateService? isolateService})
    : _isolateService = isolateService ?? SerialIsolateService();

  final SerialIsolateService _isolateService;

  SerialPortConfig? _currentConfig;
  bool _isOpen = false;
  bool _isInitialized = false;

  /// Ensures the isolate service is started.
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _isolateService.start();
      _isInitialized = true;
    }
  }

  @override
  Future<List<String>> getAvailablePorts() async {
    await _ensureInitialized();
    return _isolateService.getAvailablePorts();
  }

  @override
  Future<void> openPort(SerialPortConfig config) async {
    await _ensureInitialized();

    if (_isOpen) {
      await closePort();
    }

    await _isolateService.openPort(config);
    _currentConfig = config;
    _isOpen = true;
  }

  @override
  Future<void> closePort() async {
    if (!_isOpen) return;

    await _isolateService.closePort();
    _currentConfig = null;
    _isOpen = false;
  }

  @override
  Future<void> sendData(Uint8List data) async {
    if (!_isOpen) {
      throw SerialPortException('No port is currently open');
    }

    await _isolateService.sendData(data);
  }

  @override
  Stream<Uint8List> get dataStream => _isolateService.dataStream;

  @override
  bool get isOpen => _isOpen;

  @override
  SerialPortConfig? get currentConfig => _currentConfig;

  /// Disposes the repository and releases all resources.
  ///
  /// After calling this method, the repository should not be used anymore.
  Future<void> dispose() async {
    if (_isOpen) {
      await closePort();
    }
    await _isolateService.dispose();
    _isInitialized = false;
  }
}
