import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../domain/connection.dart';
import '../domain/connection_config.dart';

/// UDP implementation of [IUdpConnection].
///
/// Provides UDP functionality for unicast and broadcast communication.
class UdpConnection implements IUdpConnection {
  UdpConnection();

  RawDatagramSocket? _socket;
  UdpConfig? _config;
  final _dataController = StreamController<Uint8List>.broadcast();
  StreamSubscription<RawSocketEvent>? _socketSubscription;

  @override
  ConnectionType get connectionType => ConnectionType.udp;

  @override
  ConnectionConfig? get currentConfig => _config;

  @override
  Stream<Uint8List> get dataStream => _dataController.stream;

  @override
  bool get isOpen => _socket != null;

  @override
  Future<void> open(ConnectionConfig config) async {
    if (config is! UdpConfig) {
      throw const ConnectionException('Invalid configuration type for UDP');
    }

    if (_socket != null) {
      await close();
    }

    try {
      _socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        config.localPort,
      );

      // Enable broadcast if in broadcast mode
      if (config.mode == UdpMode.broadcast) {
        _socket!.broadcastEnabled = true;
      }

      _config = config;

      _socketSubscription = _socket!.listen(
        _handleSocketEvent,
        onError: (Object error) {
          _dataController.addError(ConnectionException(error.toString()));
        },
      );
    } on SocketException catch (e) {
      throw ConnectionException(
        'Failed to bind UDP socket on port ${config.localPort}: ${e.message}',
        code: e.osError?.errorCode,
      );
    } catch (e) {
      throw ConnectionException('UDP socket creation failed: $e');
    }
  }

  void _handleSocketEvent(RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      final datagram = _socket?.receive();
      if (datagram != null) {
        _dataController.add(Uint8List.fromList(datagram.data));
      }
    }
  }

  @override
  Future<void> close() async {
    await _socketSubscription?.cancel();
    _socketSubscription = null;

    _socket?.close();
    _socket = null;
    _config = null;
  }

  @override
  Future<void> send(Uint8List data) async {
    if (_socket == null || _config == null) {
      throw const ConnectionException('UDP socket is not open');
    }

    if (_config!.mode == UdpMode.broadcast) {
      await sendBroadcast(data, _config!.remotePort);
    } else {
      await sendTo(data, _config!.remoteHost, _config!.remotePort);
    }
  }

  @override
  Future<void> sendTo(Uint8List data, String address, int port) async {
    if (_socket == null) {
      throw const ConnectionException('UDP socket is not open');
    }

    try {
      final targetAddress = InternetAddress(address);
      final bytesSent = _socket!.send(data, targetAddress, port);
      if (bytesSent != data.length) {
        throw ConnectionException(
          'Only sent $bytesSent of ${data.length} bytes',
        );
      }
    } on SocketException catch (e) {
      throw ConnectionException(
        'Failed to send UDP data to $address:$port: ${e.message}',
        code: e.osError?.errorCode,
      );
    } catch (e) {
      throw ConnectionException('UDP send failed: $e');
    }
  }

  @override
  Future<void> sendBroadcast(Uint8List data, int port) async {
    if (_socket == null) {
      throw const ConnectionException('UDP socket is not open');
    }

    final broadcastAddress = _config?.broadcastAddress ?? '255.255.255.255';

    try {
      _socket!.broadcastEnabled = true;
      final targetAddress = InternetAddress(broadcastAddress);
      final bytesSent = _socket!.send(data, targetAddress, port);
      if (bytesSent != data.length) {
        throw ConnectionException(
          'Only sent $bytesSent of ${data.length} bytes',
        );
      }
    } on SocketException catch (e) {
      throw ConnectionException(
        'Failed to broadcast UDP data on port $port: ${e.message}',
        code: e.osError?.errorCode,
      );
    } catch (e) {
      throw ConnectionException('UDP broadcast failed: $e');
    }
  }

  @override
  Future<void> dispose() async {
    await close();
    await _dataController.close();
  }

  /// Returns the actual local port the socket is bound to.
  ///
  /// This is useful when `localPort` was set to 0 (auto-assign).
  int? get actualLocalPort => _socket?.port;
}
