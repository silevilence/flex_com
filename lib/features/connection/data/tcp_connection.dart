import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../domain/connection.dart';
import '../domain/connection_config.dart';

/// TCP Client implementation of [IConnection].
///
/// Provides TCP client functionality for connecting to remote servers.
class TcpClientConnection implements IConnection {
  TcpClientConnection();

  Socket? _socket;
  TcpClientConfig? _config;
  final _dataController = StreamController<Uint8List>.broadcast();
  StreamSubscription<Uint8List>? _socketSubscription;

  @override
  ConnectionType get connectionType => ConnectionType.tcpClient;

  @override
  ConnectionConfig? get currentConfig => _config;

  @override
  Stream<Uint8List> get dataStream => _dataController.stream;

  @override
  bool get isOpen => _socket != null;

  @override
  Future<void> open(ConnectionConfig config) async {
    if (config is! TcpClientConfig) {
      throw const ConnectionException(
        'Invalid configuration type for TCP Client',
      );
    }

    if (_socket != null) {
      await close();
    }

    try {
      _socket = await Socket.connect(
        config.host,
        config.port,
        timeout: config.timeout,
      );

      _config = config;

      _socketSubscription = _socket!.listen(
        (data) {
          _dataController.add(Uint8List.fromList(data));
        },
        onError: (Object error) {
          _dataController.addError(ConnectionException(error.toString()));
        },
        onDone: () {
          _handleDisconnect();
        },
      );
    } on SocketException catch (e) {
      throw ConnectionException(
        'Failed to connect to ${config.host}:${config.port}: ${e.message}',
        code: e.osError?.errorCode,
      );
    } catch (e) {
      throw ConnectionException('Connection failed: $e');
    }
  }

  @override
  Future<void> close() async {
    await _socketSubscription?.cancel();
    _socketSubscription = null;

    await _socket?.close();
    _socket = null;
    _config = null;
  }

  @override
  Future<void> send(Uint8List data) async {
    if (_socket == null) {
      throw const ConnectionException('TCP Client is not connected');
    }

    try {
      _socket!.add(data);
      await _socket!.flush();
    } on SocketException catch (e) {
      throw ConnectionException(
        'Failed to send data: ${e.message}',
        code: e.osError?.errorCode,
      );
    }
  }

  @override
  Future<void> dispose() async {
    await close();
    await _dataController.close();
  }

  void _handleDisconnect() {
    _socket = null;
    _config = null;
  }
}

/// TCP Server implementation of [ITcpServer].
///
/// Provides TCP server functionality for accepting client connections.
class TcpServerConnection implements ITcpServer {
  TcpServerConnection();

  ServerSocket? _serverSocket;
  TcpServerConfig? _config;
  final Map<String, _ClientConnection> _clients = {};
  int _clientIdCounter = 0;

  final _dataController = StreamController<Uint8List>.broadcast();
  final _clientConnectedController = StreamController<ClientInfo>.broadcast();
  final _clientDisconnectedController =
      StreamController<ClientInfo>.broadcast();

  @override
  ConnectionType get connectionType => ConnectionType.tcpServer;

  @override
  ConnectionConfig? get currentConfig => _config;

  @override
  Stream<Uint8List> get dataStream => _dataController.stream;

  @override
  bool get isOpen => _serverSocket != null;

  @override
  List<ClientInfo> get connectedClients =>
      _clients.values.map((c) => c.info).toList();

  @override
  Stream<ClientInfo> get clientConnectedStream =>
      _clientConnectedController.stream;

  @override
  Stream<ClientInfo> get clientDisconnectedStream =>
      _clientDisconnectedController.stream;

  @override
  Future<void> open(ConnectionConfig config) async {
    if (config is! TcpServerConfig) {
      throw const ConnectionException(
        'Invalid configuration type for TCP Server',
      );
    }

    if (_serverSocket != null) {
      await close();
    }

    try {
      _serverSocket = await ServerSocket.bind(
        config.bindAddress,
        config.port,
        shared: true,
      );

      _config = config;

      _serverSocket!.listen(
        _handleClientConnection,
        onError: (Object error) {
          _dataController.addError(ConnectionException(error.toString()));
        },
      );
    } on SocketException catch (e) {
      throw ConnectionException(
        'Failed to start server on ${config.bindAddress}:${config.port}: '
        '${e.message}',
        code: e.osError?.errorCode,
      );
    } catch (e) {
      throw ConnectionException('Server start failed: $e');
    }
  }

  void _handleClientConnection(Socket clientSocket) {
    if (_config != null && _clients.length >= _config!.maxClients) {
      clientSocket.close();
      return;
    }

    final clientId = 'client_${++_clientIdCounter}';
    final clientInfo = ClientInfo(
      id: clientId,
      remoteAddress: clientSocket.remoteAddress.address,
      remotePort: clientSocket.remotePort,
      connectedAt: DateTime.now(),
    );

    final subscription = clientSocket.listen(
      (data) {
        _dataController.add(Uint8List.fromList(data));
      },
      onError: (Object error) {
        _removeClient(clientId);
      },
      onDone: () {
        _removeClient(clientId);
      },
    );

    _clients[clientId] = _ClientConnection(
      socket: clientSocket,
      info: clientInfo,
      subscription: subscription,
    );

    _clientConnectedController.add(clientInfo);
  }

  void _removeClient(String clientId) {
    final client = _clients.remove(clientId);
    if (client != null) {
      client.subscription.cancel();
      client.socket.close();
      _clientDisconnectedController.add(client.info);
    }
  }

  @override
  Future<void> close() async {
    // Close all client connections
    for (final clientId in _clients.keys.toList()) {
      await disconnectClient(clientId);
    }

    await _serverSocket?.close();
    _serverSocket = null;
    _config = null;
  }

  @override
  Future<void> send(Uint8List data) async {
    await broadcast(data);
  }

  @override
  Future<void> sendToClient(String clientId, Uint8List data) async {
    final client = _clients[clientId];
    if (client == null) {
      throw ConnectionException('Client $clientId not found');
    }

    try {
      client.socket.add(data);
      await client.socket.flush();
    } on SocketException catch (e) {
      throw ConnectionException(
        'Failed to send data to client $clientId: ${e.message}',
        code: e.osError?.errorCode,
      );
    }
  }

  @override
  Future<void> broadcast(Uint8List data) async {
    final errors = <String>[];

    for (final entry in _clients.entries) {
      try {
        entry.value.socket.add(data);
        await entry.value.socket.flush();
      } catch (e) {
        errors.add('${entry.key}: $e');
      }
    }

    if (errors.isNotEmpty) {
      throw ConnectionException(
        'Failed to send to some clients: ${errors.join(", ")}',
      );
    }
  }

  @override
  Future<void> disconnectClient(String clientId) async {
    _removeClient(clientId);
  }

  @override
  Future<void> dispose() async {
    await close();
    await _dataController.close();
    await _clientConnectedController.close();
    await _clientDisconnectedController.close();
  }
}

/// Internal class to hold client connection data.
class _ClientConnection {
  const _ClientConnection({
    required this.socket,
    required this.info,
    required this.subscription,
  });

  final Socket socket;
  final ClientInfo info;
  final StreamSubscription<Uint8List> subscription;
}
