import 'dart:typed_data';

import 'package:flex_com/features/connection/connection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConnectionConfig', () {
    group('SerialConnectionConfig', () {
      test('should create with default values', () {
        const config = SerialConnectionConfig(portName: 'COM1');

        expect(config.portName, 'COM1');
        expect(config.baudRate, 9600);
        expect(config.dataBits, 8);
        expect(config.stopBits, 1);
        expect(config.parity, SerialParity.none);
        expect(config.flowControl, SerialFlowControl.none);
        expect(config.type, ConnectionType.serial);
      });

      test('should serialize to JSON and back', () {
        const config = SerialConnectionConfig(
          portName: 'COM3',
          baudRate: 115200,
          dataBits: 8,
          stopBits: 2,
          parity: SerialParity.even,
          flowControl: SerialFlowControl.hardware,
        );

        final json = config.toJson();
        final restored = SerialConnectionConfig.fromJson(json);

        expect(restored.portName, config.portName);
        expect(restored.baudRate, config.baudRate);
        expect(restored.dataBits, config.dataBits);
        expect(restored.stopBits, config.stopBits);
        expect(restored.parity, config.parity);
        expect(restored.flowControl, config.flowControl);
      });

      test('copyWith should create new instance with modified values', () {
        const config = SerialConnectionConfig(portName: 'COM1');
        final modified = config.copyWith(baudRate: 115200);

        expect(modified.portName, 'COM1');
        expect(modified.baudRate, 115200);
        expect(config.baudRate, 9600); // Original unchanged
      });
    });

    group('TcpClientConfig', () {
      test('should create with required values', () {
        const config = TcpClientConfig(host: '192.168.1.100', port: 8080);

        expect(config.host, '192.168.1.100');
        expect(config.port, 8080);
        expect(config.timeout, const Duration(seconds: 10));
        expect(config.type, ConnectionType.tcpClient);
        expect(config.name, '192.168.1.100:8080');
      });

      test('should serialize to JSON and back', () {
        const config = TcpClientConfig(
          host: 'localhost',
          port: 9000,
          timeout: Duration(seconds: 30),
        );

        final json = config.toJson();
        final restored = TcpClientConfig.fromJson(json);

        expect(restored.host, config.host);
        expect(restored.port, config.port);
        expect(restored.timeout, config.timeout);
      });

      test('copyWith should create new instance with modified values', () {
        const config = TcpClientConfig(host: 'localhost', port: 8080);
        final modified = config.copyWith(port: 9000);

        expect(modified.host, 'localhost');
        expect(modified.port, 9000);
        expect(config.port, 8080); // Original unchanged
      });
    });

    group('TcpServerConfig', () {
      test('should create with default bind address', () {
        const config = TcpServerConfig(port: 8080);

        expect(config.bindAddress, '0.0.0.0');
        expect(config.port, 8080);
        expect(config.maxClients, 10);
        expect(config.type, ConnectionType.tcpServer);
      });

      test('should serialize to JSON and back', () {
        const config = TcpServerConfig(
          bindAddress: '127.0.0.1',
          port: 9000,
          maxClients: 5,
        );

        final json = config.toJson();
        final restored = TcpServerConfig.fromJson(json);

        expect(restored.bindAddress, config.bindAddress);
        expect(restored.port, config.port);
        expect(restored.maxClients, config.maxClients);
      });
    });

    group('UdpConfig', () {
      test('should create unicast config', () {
        const config = UdpConfig(
          localPort: 5000,
          remoteHost: '192.168.1.100',
          remotePort: 5001,
          mode: UdpMode.unicast,
        );

        expect(config.localPort, 5000);
        expect(config.remoteHost, '192.168.1.100');
        expect(config.remotePort, 5001);
        expect(config.mode, UdpMode.unicast);
        expect(config.type, ConnectionType.udp);
      });

      test('should create broadcast config', () {
        const config = UdpConfig(
          localPort: 5000,
          remotePort: 5001,
          mode: UdpMode.broadcast,
        );

        expect(config.mode, UdpMode.broadcast);
        expect(config.broadcastAddress, '255.255.255.255');
      });

      test('should serialize to JSON and back', () {
        const config = UdpConfig(
          localPort: 5000,
          remoteHost: '192.168.1.100',
          remotePort: 5001,
          mode: UdpMode.unicast,
        );

        final json = config.toJson();
        final restored = UdpConfig.fromJson(json);

        expect(restored.localPort, config.localPort);
        expect(restored.remoteHost, config.remoteHost);
        expect(restored.remotePort, config.remotePort);
        expect(restored.mode, config.mode);
      });
    });

    group('ConnectionConfig.fromJson', () {
      test('should create correct type from JSON', () {
        final serialJson = {'type': 0, 'portName': 'COM1'};
        final tcpClientJson = {'type': 1, 'host': 'localhost', 'port': 8080};
        final tcpServerJson = {'type': 2, 'port': 8080};
        final udpJson = {'type': 3, 'localPort': 5000};

        expect(
          ConnectionConfig.fromJson(serialJson),
          isA<SerialConnectionConfig>(),
        );
        expect(
          ConnectionConfig.fromJson(tcpClientJson),
          isA<TcpClientConfig>(),
        );
        expect(
          ConnectionConfig.fromJson(tcpServerJson),
          isA<TcpServerConfig>(),
        );
        expect(ConnectionConfig.fromJson(udpJson), isA<UdpConfig>());
      });
    });
  });

  group('ConnectionType', () {
    test('should have correct display names', () {
      expect(ConnectionType.serial.displayName, 'Serial Port');
      expect(ConnectionType.tcpClient.displayName, 'TCP Client');
      expect(ConnectionType.tcpServer.displayName, 'TCP Server');
      expect(ConnectionType.udp.displayName, 'UDP');
    });
  });

  group('ConnectionState', () {
    test('isConnected should return correct values', () {
      expect(ConnectionState.connected.isConnected, true);
      expect(ConnectionState.disconnected.isConnected, false);
      expect(ConnectionState.connecting.isConnected, false);
      expect(ConnectionState.error.isConnected, false);
    });

    test('isTransitioning should return correct values', () {
      expect(ConnectionState.connecting.isTransitioning, true);
      expect(ConnectionState.disconnecting.isTransitioning, true);
      expect(ConnectionState.connected.isTransitioning, false);
      expect(ConnectionState.disconnected.isTransitioning, false);
    });
  });

  group('ConnectionException', () {
    test('should format message correctly', () {
      const exceptionWithCode = ConnectionException('Test error', code: 10);
      const exceptionWithoutCode = ConnectionException('Test error');

      expect(
        exceptionWithCode.toString(),
        'ConnectionException(10): Test error',
      );
      expect(
        exceptionWithoutCode.toString(),
        'ConnectionException: Test error',
      );
    });
  });

  group('ClientInfo', () {
    test('should create with correct values', () {
      final now = DateTime.now();
      final info = ClientInfo(
        id: 'client_1',
        remoteAddress: '192.168.1.100',
        remotePort: 12345,
        connectedAt: now,
      );

      expect(info.id, 'client_1');
      expect(info.remoteAddress, '192.168.1.100');
      expect(info.remotePort, 12345);
      expect(info.connectedAt, now);
      expect(info.toString(), 'Client(192.168.1.100:12345)');
    });
  });

  group('ConnectionFactory', () {
    test('should create correct connection types', () {
      expect(
        ConnectionFactory.create(ConnectionType.serial),
        isA<SerialConnectionAdapter>(),
      );
      expect(
        ConnectionFactory.create(ConnectionType.tcpClient),
        isA<TcpClientConnection>(),
      );
      expect(
        ConnectionFactory.create(ConnectionType.tcpServer),
        isA<TcpServerConnection>(),
      );
      expect(
        ConnectionFactory.create(ConnectionType.udp),
        isA<UdpConnection>(),
      );
    });

    test('fromConfig should create correct connection types', () {
      const serialConfig = SerialConnectionConfig(portName: 'COM1');
      const tcpClientConfig = TcpClientConfig(host: 'localhost', port: 8080);
      const tcpServerConfig = TcpServerConfig(port: 8080);
      const udpConfig = UdpConfig(localPort: 5000);

      expect(
        ConnectionFactory.fromConfig(serialConfig),
        isA<SerialConnectionAdapter>(),
      );
      expect(
        ConnectionFactory.fromConfig(tcpClientConfig),
        isA<TcpClientConnection>(),
      );
      expect(
        ConnectionFactory.fromConfig(tcpServerConfig),
        isA<TcpServerConnection>(),
      );
      expect(ConnectionFactory.fromConfig(udpConfig), isA<UdpConnection>());
    });
  });

  group('TcpClientConnection', () {
    test('should be initially not open', () {
      final connection = TcpClientConnection();

      expect(connection.isOpen, false);
      expect(connection.currentConfig, null);
      expect(connection.connectionType, ConnectionType.tcpClient);
    });

    test('should throw on invalid config type', () async {
      final connection = TcpClientConnection();
      const invalidConfig = SerialConnectionConfig(portName: 'COM1');

      expect(
        () => connection.open(invalidConfig),
        throwsA(isA<ConnectionException>()),
      );
    });

    test('should throw when sending on closed connection', () async {
      final connection = TcpClientConnection();

      expect(
        () => connection.send(Uint8List.fromList([1, 2, 3])),
        throwsA(isA<ConnectionException>()),
      );
    });
  });

  group('TcpServerConnection', () {
    test('should be initially not open', () {
      final connection = TcpServerConnection();

      expect(connection.isOpen, false);
      expect(connection.currentConfig, null);
      expect(connection.connectionType, ConnectionType.tcpServer);
      expect(connection.connectedClients, isEmpty);
    });

    test('should throw on invalid config type', () async {
      final connection = TcpServerConnection();
      const invalidConfig = TcpClientConfig(host: 'localhost', port: 8080);

      expect(
        () => connection.open(invalidConfig),
        throwsA(isA<ConnectionException>()),
      );
    });
  });

  group('UdpConnection', () {
    test('should be initially not open', () {
      final connection = UdpConnection();

      expect(connection.isOpen, false);
      expect(connection.currentConfig, null);
      expect(connection.connectionType, ConnectionType.udp);
    });

    test('should throw on invalid config type', () async {
      final connection = UdpConnection();
      const invalidConfig = SerialConnectionConfig(portName: 'COM1');

      expect(
        () => connection.open(invalidConfig),
        throwsA(isA<ConnectionException>()),
      );
    });

    test('should throw when sending on closed connection', () async {
      final connection = UdpConnection();

      expect(
        () => connection.send(Uint8List.fromList([1, 2, 3])),
        throwsA(isA<ConnectionException>()),
      );
    });
  });

  group('UnifiedConnectionState', () {
    test('should create with default values', () {
      const state = UnifiedConnectionState();

      expect(state.status, ConnectionState.disconnected);
      expect(state.config, null);
      expect(state.error, null);
      expect(state.connectedClients, isEmpty);
      expect(state.isConnected, false);
      expect(state.connectionType, null);
    });

    test('copyWith should preserve unchanged values', () {
      const original = UnifiedConnectionState(
        status: ConnectionState.connected,
        config: TcpClientConfig(host: 'localhost', port: 8080),
      );

      final modified = original.copyWith(error: 'Test error');

      expect(modified.status, ConnectionState.connected);
      expect(modified.config, isA<TcpClientConfig>());
      expect(modified.error, 'Test error');
    });
  });
}
