import 'package:equatable/equatable.dart';

/// Types of connections supported by the application.
enum ConnectionType {
  /// Serial port connection
  serial,

  /// TCP Client connection
  tcpClient,

  /// TCP Server connection
  tcpServer,

  /// UDP connection
  udp;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case ConnectionType.serial:
        return 'Serial Port';
      case ConnectionType.tcpClient:
        return 'TCP Client';
      case ConnectionType.tcpServer:
        return 'TCP Server';
      case ConnectionType.udp:
        return 'UDP';
    }
  }

  /// Icon name for UI (Material Icons)
  String get iconName {
    switch (this) {
      case ConnectionType.serial:
        return 'usb';
      case ConnectionType.tcpClient:
        return 'computer';
      case ConnectionType.tcpServer:
        return 'dns';
      case ConnectionType.udp:
        return 'swap_horiz';
    }
  }
}

/// Base class for all connection configurations.
///
/// This abstract class defines the common interface for all connection types.
/// Each connection type (Serial, TCP, UDP) will have its own implementation.
abstract class ConnectionConfig extends Equatable {
  const ConnectionConfig({required this.type, required this.name});

  /// The type of connection
  final ConnectionType type;

  /// A user-friendly name for this connection
  final String name;

  /// Converts this configuration to a JSON map.
  Map<String, dynamic> toJson();

  /// Creates a configuration from a JSON map.
  static ConnectionConfig fromJson(Map<String, dynamic> json) {
    final typeValue = json['type'] as int? ?? 0;
    final type = ConnectionType.values[typeValue];

    switch (type) {
      case ConnectionType.serial:
        return SerialConnectionConfig.fromJson(json);
      case ConnectionType.tcpClient:
        return TcpClientConfig.fromJson(json);
      case ConnectionType.tcpServer:
        return TcpServerConfig.fromJson(json);
      case ConnectionType.udp:
        return UdpConfig.fromJson(json);
    }
  }
}

/// Configuration for serial port connections.
///
/// Wraps the existing SerialPortConfig with the unified interface.
class SerialConnectionConfig extends ConnectionConfig {
  const SerialConnectionConfig({
    required this.portName,
    this.baudRate = 9600,
    this.dataBits = 8,
    this.stopBits = 1,
    this.parity = SerialParity.none,
    this.flowControl = SerialFlowControl.none,
    this.interByteTimeout = 20,
    this.maxFrameLength = 4096,
  }) : super(type: ConnectionType.serial, name: portName);

  /// The name of the serial port
  final String portName;

  /// Baud rate for the connection
  final int baudRate;

  /// Number of data bits
  final int dataBits;

  /// Number of stop bits
  final int stopBits;

  /// Parity setting
  final SerialParity parity;

  /// Flow control setting
  final SerialFlowControl flowControl;

  /// Inter-byte timeout in milliseconds for frame assembly.
  /// Bytes received within this timeout are grouped into a single frame.
  /// Default: 20ms
  final int interByteTimeout;

  /// Maximum frame length in bytes.
  /// When received data exceeds this length, it will be forced to split.
  /// Default: 4096 bytes
  final int maxFrameLength;

  /// Common baud rates for UI selection
  static const List<int> commonBaudRates = [
    300,
    1200,
    2400,
    4800,
    9600,
    19200,
    38400,
    57600,
    115200,
    230400,
    460800,
    921600,
  ];

  /// Common data bits options
  static const List<int> commonDataBits = [5, 6, 7, 8];

  /// Common stop bits options
  static const List<int> commonStopBits = [1, 2];

  SerialConnectionConfig copyWith({
    String? portName,
    int? baudRate,
    int? dataBits,
    int? stopBits,
    SerialParity? parity,
    SerialFlowControl? flowControl,
    int? interByteTimeout,
    int? maxFrameLength,
  }) {
    return SerialConnectionConfig(
      portName: portName ?? this.portName,
      baudRate: baudRate ?? this.baudRate,
      dataBits: dataBits ?? this.dataBits,
      stopBits: stopBits ?? this.stopBits,
      parity: parity ?? this.parity,
      flowControl: flowControl ?? this.flowControl,
      interByteTimeout: interByteTimeout ?? this.interByteTimeout,
      maxFrameLength: maxFrameLength ?? this.maxFrameLength,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'portName': portName,
      'baudRate': baudRate,
      'dataBits': dataBits,
      'stopBits': stopBits,
      'parity': parity.value,
      'flowControl': flowControl.value,
      'interByteTimeout': interByteTimeout,
      'maxFrameLength': maxFrameLength,
    };
  }

  factory SerialConnectionConfig.fromJson(Map<String, dynamic> json) {
    return SerialConnectionConfig(
      portName: json['portName'] as String? ?? '',
      baudRate: json['baudRate'] as int? ?? 9600,
      dataBits: json['dataBits'] as int? ?? 8,
      stopBits: json['stopBits'] as int? ?? 1,
      parity: SerialParity.values.firstWhere(
        (p) => p.value == (json['parity'] as int? ?? 0),
        orElse: () => SerialParity.none,
      ),
      flowControl: SerialFlowControl.values.firstWhere(
        (fc) => fc.value == (json['flowControl'] as int? ?? 0),
        orElse: () => SerialFlowControl.none,
      ),
      interByteTimeout: json['interByteTimeout'] as int? ?? 20,
      maxFrameLength: json['maxFrameLength'] as int? ?? 4096,
    );
  }

  @override
  List<Object?> get props => [
    portName,
    baudRate,
    dataBits,
    stopBits,
    parity,
    flowControl,
    interByteTimeout,
    maxFrameLength,
  ];

  @override
  String toString() {
    return 'SerialConnectionConfig(port: $portName, baud: $baudRate)';
  }
}

/// Parity options for serial communication
enum SerialParity {
  none(0),
  odd(1),
  even(2),
  mark(3),
  space(4);

  const SerialParity(this.value);
  final int value;

  String get displayName {
    switch (this) {
      case SerialParity.none:
        return 'None';
      case SerialParity.odd:
        return 'Odd';
      case SerialParity.even:
        return 'Even';
      case SerialParity.mark:
        return 'Mark';
      case SerialParity.space:
        return 'Space';
    }
  }
}

/// Flow control options for serial communication
enum SerialFlowControl {
  none(0),
  hardware(1),
  software(2),
  dtrDsr(3);

  const SerialFlowControl(this.value);
  final int value;

  String get displayName {
    switch (this) {
      case SerialFlowControl.none:
        return 'None';
      case SerialFlowControl.hardware:
        return 'RTS/CTS';
      case SerialFlowControl.software:
        return 'XON/XOFF';
      case SerialFlowControl.dtrDsr:
        return 'DTR/DSR';
    }
  }
}

/// Configuration for TCP Client connections.
class TcpClientConfig extends ConnectionConfig {
  const TcpClientConfig({
    required this.host,
    required this.port,
    this.timeout = const Duration(seconds: 10),
  }) : super(type: ConnectionType.tcpClient, name: '$host:$port');

  /// The host address to connect to
  final String host;

  /// The port number to connect to
  final int port;

  /// Connection timeout
  final Duration timeout;

  TcpClientConfig copyWith({String? host, int? port, Duration? timeout}) {
    return TcpClientConfig(
      host: host ?? this.host,
      port: port ?? this.port,
      timeout: timeout ?? this.timeout,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'host': host,
      'port': port,
      'timeoutMs': timeout.inMilliseconds,
    };
  }

  factory TcpClientConfig.fromJson(Map<String, dynamic> json) {
    return TcpClientConfig(
      host: json['host'] as String? ?? 'localhost',
      port: json['port'] as int? ?? 8080,
      timeout: Duration(milliseconds: json['timeoutMs'] as int? ?? 10000),
    );
  }

  @override
  List<Object?> get props => [host, port, timeout];

  @override
  String toString() => 'TcpClientConfig($host:$port)';
}

/// Configuration for TCP Server connections.
class TcpServerConfig extends ConnectionConfig {
  const TcpServerConfig({
    this.bindAddress = '0.0.0.0',
    required this.port,
    this.maxClients = 10,
  }) : super(type: ConnectionType.tcpServer, name: '$bindAddress:$port');

  /// The address to bind to (default: 0.0.0.0 = all interfaces)
  final String bindAddress;

  /// The port number to listen on
  final int port;

  /// Maximum number of simultaneous clients
  final int maxClients;

  TcpServerConfig copyWith({String? bindAddress, int? port, int? maxClients}) {
    return TcpServerConfig(
      bindAddress: bindAddress ?? this.bindAddress,
      port: port ?? this.port,
      maxClients: maxClients ?? this.maxClients,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'bindAddress': bindAddress,
      'port': port,
      'maxClients': maxClients,
    };
  }

  factory TcpServerConfig.fromJson(Map<String, dynamic> json) {
    return TcpServerConfig(
      bindAddress: json['bindAddress'] as String? ?? '0.0.0.0',
      port: json['port'] as int? ?? 8080,
      maxClients: json['maxClients'] as int? ?? 10,
    );
  }

  @override
  List<Object?> get props => [bindAddress, port, maxClients];

  @override
  String toString() => 'TcpServerConfig($bindAddress:$port)';
}

/// UDP communication mode
enum UdpMode {
  /// Unicast to a specific address
  unicast,

  /// Broadcast to all devices on the network
  broadcast;

  String get displayName {
    switch (this) {
      case UdpMode.unicast:
        return 'Unicast';
      case UdpMode.broadcast:
        return 'Broadcast';
    }
  }
}

/// Configuration for UDP connections.
class UdpConfig extends ConnectionConfig {
  const UdpConfig({
    this.localPort = 0,
    this.remoteHost = '',
    this.remotePort = 0,
    this.mode = UdpMode.unicast,
    this.broadcastAddress = '255.255.255.255',
  }) : super(
         type: ConnectionType.udp,
         name: mode == UdpMode.broadcast
             ? 'UDP Broadcast :$localPort'
             : 'UDP $remoteHost:$remotePort',
       );

  /// Local port to bind to (0 = auto-assign)
  final int localPort;

  /// Remote host for unicast mode
  final String remoteHost;

  /// Remote port for unicast mode
  final int remotePort;

  /// UDP mode (unicast or broadcast)
  final UdpMode mode;

  /// Broadcast address (default: 255.255.255.255)
  final String broadcastAddress;

  UdpConfig copyWith({
    int? localPort,
    String? remoteHost,
    int? remotePort,
    UdpMode? mode,
    String? broadcastAddress,
  }) {
    return UdpConfig(
      localPort: localPort ?? this.localPort,
      remoteHost: remoteHost ?? this.remoteHost,
      remotePort: remotePort ?? this.remotePort,
      mode: mode ?? this.mode,
      broadcastAddress: broadcastAddress ?? this.broadcastAddress,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'localPort': localPort,
      'remoteHost': remoteHost,
      'remotePort': remotePort,
      'mode': mode.index,
      'broadcastAddress': broadcastAddress,
    };
  }

  factory UdpConfig.fromJson(Map<String, dynamic> json) {
    return UdpConfig(
      localPort: json['localPort'] as int? ?? 0,
      remoteHost: json['remoteHost'] as String? ?? '',
      remotePort: json['remotePort'] as int? ?? 0,
      mode: UdpMode.values[json['mode'] as int? ?? 0],
      broadcastAddress:
          json['broadcastAddress'] as String? ?? '255.255.255.255',
    );
  }

  @override
  List<Object?> get props => [
    localPort,
    remoteHost,
    remotePort,
    mode,
    broadcastAddress,
  ];

  @override
  String toString() => 'UdpConfig(mode: $mode, local: $localPort)';
}
