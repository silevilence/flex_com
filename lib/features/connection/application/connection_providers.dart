import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/connection_factory.dart';
import '../data/serial_connection_adapter.dart';
import '../domain/connection.dart';
import '../domain/connection_config.dart';

part 'connection_providers.g.dart';

/// State class for connection management.
class UnifiedConnectionState {
  const UnifiedConnectionState({
    this.status = ConnectionState.disconnected,
    this.config,
    this.error,
    this.connectedClients = const [],
  });

  /// Current connection status
  final ConnectionState status;

  /// Current connection configuration
  final ConnectionConfig? config;

  /// Last error message
  final String? error;

  /// Connected clients (for TCP Server only)
  final List<ClientInfo> connectedClients;

  UnifiedConnectionState copyWith({
    ConnectionState? status,
    ConnectionConfig? config,
    String? error,
    List<ClientInfo>? connectedClients,
  }) {
    return UnifiedConnectionState(
      status: status ?? this.status,
      config: config ?? this.config,
      error: error,
      connectedClients: connectedClients ?? this.connectedClients,
    );
  }

  /// Returns true if connected
  bool get isConnected => status == ConnectionState.connected;

  /// Returns the connection type, or null if not configured
  ConnectionType? get connectionType => config?.type;
}

/// Notifier for managing unified connections.
///
/// This provider manages connections of any type (Serial, TCP, UDP)
/// using the unified [IConnection] interface.
@Riverpod(keepAlive: true)
class UnifiedConnection extends _$UnifiedConnection {
  IConnection? _connection;

  @override
  UnifiedConnectionState build() {
    ref.onDispose(() async {
      await _connection?.dispose();
    });
    return const UnifiedConnectionState();
  }

  /// Opens a connection with the given configuration.
  Future<void> connect(ConnectionConfig config) async {
    if (state.status == ConnectionState.connecting) {
      return;
    }

    state = state.copyWith(status: ConnectionState.connecting, config: config);

    try {
      // Dispose existing connection if any
      await _connection?.dispose();

      // Create new connection
      _connection = ConnectionFactory.fromConfig(config);

      // Open the connection
      await _connection!.open(config);

      // Listen for data and client events if TCP Server
      _setupListeners();

      state = state.copyWith(status: ConnectionState.connected, config: config);
    } on ConnectionException catch (e) {
      state = state.copyWith(status: ConnectionState.error, error: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(
        status: ConnectionState.error,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Disconnects the current connection.
  Future<void> disconnect() async {
    if (state.status == ConnectionState.disconnecting ||
        state.status == ConnectionState.disconnected) {
      return;
    }

    state = state.copyWith(status: ConnectionState.disconnecting);

    try {
      await _connection?.close();
      state = const UnifiedConnectionState();
    } catch (e) {
      state = state.copyWith(
        status: ConnectionState.error,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Sends data through the current connection.
  Future<void> send(Uint8List data) async {
    if (_connection == null || !state.isConnected) {
      throw const ConnectionException('Not connected');
    }

    await _connection!.send(data);
  }

  /// Sends data to a specific TCP client (server mode only).
  Future<void> sendToClient(String clientId, Uint8List data) async {
    if (_connection is! ITcpServer) {
      throw const ConnectionException('Not in TCP Server mode');
    }

    await (_connection as ITcpServer).sendToClient(clientId, data);
  }

  /// Broadcasts data to all TCP clients (server mode only).
  Future<void> broadcast(Uint8List data) async {
    if (_connection is! ITcpServer) {
      throw const ConnectionException('Not in TCP Server mode');
    }

    await (_connection as ITcpServer).broadcast(data);
  }

  /// Disconnects a specific TCP client (server mode only).
  Future<void> disconnectClient(String clientId) async {
    if (_connection is! ITcpServer) {
      throw const ConnectionException('Not in TCP Server mode');
    }

    await (_connection as ITcpServer).disconnectClient(clientId);
  }

  /// Sends UDP data to a specific address.
  Future<void> sendUdpTo(Uint8List data, String address, int port) async {
    if (_connection is! IUdpConnection) {
      throw const ConnectionException('Not in UDP mode');
    }

    await (_connection as IUdpConnection).sendTo(data, address, port);
  }

  /// Returns the data stream from the current connection.
  Stream<Uint8List>? get dataStream => _connection?.dataStream;

  /// Returns the current connection instance (for advanced usage).
  IConnection? get connection => _connection;

  void _setupListeners() {
    if (_connection is ITcpServer) {
      final server = _connection as ITcpServer;

      server.clientConnectedStream.listen((client) {
        state = state.copyWith(
          connectedClients: [...state.connectedClients, client],
        );
      });

      server.clientDisconnectedStream.listen((client) {
        state = state.copyWith(
          connectedClients: state.connectedClients
              .where((c) => c.id != client.id)
              .toList(),
        );
      });
    }
  }
}

/// Provider for available serial ports.
@riverpod
Future<List<String>> availableSerialPorts(Ref ref) async {
  final adapter = SerialConnectionAdapter();
  try {
    return await adapter.getAvailablePorts();
  } finally {
    await adapter.dispose();
  }
}

/// Provider for the data stream from the current connection.
///
/// Returns an empty stream if not connected.
@riverpod
Stream<Uint8List> connectionDataStream(Ref ref) {
  final connection = ref.watch(unifiedConnectionProvider);
  if (!connection.isConnected) {
    return const Stream.empty();
  }

  final notifier = ref.read(unifiedConnectionProvider.notifier);
  return notifier.dataStream ?? const Stream.empty();
}
