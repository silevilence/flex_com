import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/serial_repository.dart';
import '../data/serial_repository_impl.dart';
import '../domain/serial_port_config.dart';

part 'serial_providers.g.dart';

/// Provider for the serial repository.
///
/// This is a singleton that manages the serial port isolate.
/// It is disposed when the provider is no longer used.
@Riverpod(keepAlive: true)
SerialRepository serialRepository(Ref ref) {
  final repository = SerialRepositoryImpl();

  ref.onDispose(() {
    repository.dispose();
  });

  return repository;
}

/// Provider for the list of available serial ports.
///
/// This refreshes each time it is read and can be manually refreshed
/// by invalidating the provider.
@riverpod
Future<List<String>> availablePorts(Ref ref) async {
  final repository = ref.watch(serialRepositoryProvider);
  return repository.getAvailablePorts();
}

/// State class for serial connection.
class SerialConnectionState {
  const SerialConnectionState({
    this.isConnected = false,
    this.config,
    this.error,
  });

  final bool isConnected;
  final SerialPortConfig? config;
  final String? error;

  SerialConnectionState copyWith({
    bool? isConnected,
    SerialPortConfig? config,
    String? error,
  }) {
    return SerialConnectionState(
      isConnected: isConnected ?? this.isConnected,
      config: config ?? this.config,
      error: error,
    );
  }
}

/// Notifier for managing serial connection state.
@Riverpod(keepAlive: true)
class SerialConnection extends _$SerialConnection {
  @override
  SerialConnectionState build() {
    return const SerialConnectionState();
  }

  /// Opens a serial port with the given configuration.
  Future<void> connect(SerialPortConfig config) async {
    final repository = ref.read(serialRepositoryProvider);

    try {
      await repository.openPort(config);
      state = SerialConnectionState(isConnected: true, config: config);
    } catch (e) {
      state = SerialConnectionState(error: e.toString());
      rethrow;
    }
  }

  /// Closes the current serial port connection.
  Future<void> disconnect() async {
    final repository = ref.read(serialRepositoryProvider);

    try {
      await repository.closePort();
      state = const SerialConnectionState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Sends data through the serial port.
  Future<void> sendData(Uint8List data) async {
    final repository = ref.read(serialRepositoryProvider);
    await repository.sendData(data);
  }

  /// Sends a string as ASCII bytes through the serial port.
  Future<void> sendString(String text) async {
    final data = Uint8List.fromList(text.codeUnits);
    await sendData(data);
  }
}

/// Provider for the serial data stream.
///
/// This exposes the stream of data received from the serial port.
/// Uses keepAlive to ensure the stream is not disposed when there are no listeners.
@Riverpod(keepAlive: true)
Stream<Uint8List> serialDataStream(Ref ref) {
  final repository = ref.watch(serialRepositoryProvider);
  return repository.dataStream;
}
