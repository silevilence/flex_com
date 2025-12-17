import 'dart:typed_data';

import 'connection_config.dart';

/// Abstract interface for all connection types.
///
/// This interface defines the contract for serial, TCP, and UDP connections,
/// allowing the application to work with any connection type transparently.
abstract class IConnection {
  /// Opens the connection with the given configuration.
  ///
  /// Throws [ConnectionException] if the connection cannot be established.
  Future<void> open(ConnectionConfig config);

  /// Closes the current connection.
  ///
  /// Does nothing if no connection is currently open.
  Future<void> close();

  /// Sends data through the connection.
  ///
  /// Throws [ConnectionException] if no connection is open or if the send fails.
  Future<void> send(Uint8List data);

  /// Stream of data received from the connection.
  ///
  /// This stream emits data chunks as they are received.
  /// The stream is active only when a connection is open.
  Stream<Uint8List> get dataStream;

  /// Returns true if a connection is currently open.
  bool get isOpen;

  /// Returns the current connection configuration, or null if not connected.
  ConnectionConfig? get currentConfig;

  /// Returns the connection type.
  ConnectionType get connectionType;

  /// Disposes the connection and releases all resources.
  Future<void> dispose();
}

/// Exception thrown when a connection operation fails.
class ConnectionException implements Exception {
  const ConnectionException(this.message, {this.code});

  /// Error message
  final String message;

  /// Optional error code
  final int? code;

  @override
  String toString() {
    if (code != null) {
      return 'ConnectionException($code): $message';
    }
    return 'ConnectionException: $message';
  }
}

/// State of a connection.
enum ConnectionState {
  /// Connection is closed
  disconnected,

  /// Connection is being established
  connecting,

  /// Connection is open and ready
  connected,

  /// Connection is being closed
  disconnecting,

  /// Connection error occurred
  error;

  /// Returns true if the connection is open
  bool get isConnected => this == ConnectionState.connected;

  /// Returns true if the connection is transitioning
  bool get isTransitioning =>
      this == ConnectionState.connecting ||
      this == ConnectionState.disconnecting;
}

/// Information about a connected client (for TCP Server).
class ClientInfo {
  const ClientInfo({
    required this.id,
    required this.remoteAddress,
    required this.remotePort,
    required this.connectedAt,
  });

  /// Unique identifier for this client
  final String id;

  /// Remote IP address
  final String remoteAddress;

  /// Remote port
  final int remotePort;

  /// Time when the client connected
  final DateTime connectedAt;

  @override
  String toString() => 'Client($remoteAddress:$remotePort)';
}

/// Extended interface for TCP Server connections.
///
/// Provides additional functionality for managing multiple clients.
abstract class ITcpServer extends IConnection {
  /// List of currently connected clients.
  List<ClientInfo> get connectedClients;

  /// Stream of client connection events.
  Stream<ClientInfo> get clientConnectedStream;

  /// Stream of client disconnection events.
  Stream<ClientInfo> get clientDisconnectedStream;

  /// Sends data to a specific client.
  Future<void> sendToClient(String clientId, Uint8List data);

  /// Sends data to all connected clients.
  Future<void> broadcast(Uint8List data);

  /// Disconnects a specific client.
  Future<void> disconnectClient(String clientId);
}

/// Extended interface for UDP connections.
///
/// Provides additional functionality for UDP-specific operations.
abstract class IUdpConnection extends IConnection {
  /// Sends data to a specific address and port.
  Future<void> sendTo(Uint8List data, String address, int port);

  /// Sends broadcast data.
  Future<void> sendBroadcast(Uint8List data, int port);
}
