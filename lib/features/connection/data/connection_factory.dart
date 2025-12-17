import '../domain/connection.dart';
import '../domain/connection_config.dart';
import 'serial_connection_adapter.dart';
import 'tcp_connection.dart';
import 'udp_connection.dart';

/// Factory for creating connection instances.
///
/// Uses the Factory pattern to create the appropriate connection type
/// based on the configuration.
class ConnectionFactory {
  const ConnectionFactory._();

  /// Creates a connection instance for the given connection type.
  static IConnection create(ConnectionType type) {
    switch (type) {
      case ConnectionType.serial:
        return SerialConnectionAdapter();
      case ConnectionType.tcpClient:
        return TcpClientConnection();
      case ConnectionType.tcpServer:
        return TcpServerConnection();
      case ConnectionType.udp:
        return UdpConnection();
    }
  }

  /// Creates a connection instance based on the configuration.
  static IConnection fromConfig(ConnectionConfig config) {
    return create(config.type);
  }
}
