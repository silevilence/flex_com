import 'package:equatable/equatable.dart';

/// Parity options for serial communication
enum Parity {
  /// No parity
  none(0),

  /// Odd parity
  odd(1),

  /// Even parity
  even(2),

  /// Mark parity
  mark(3),

  /// Space parity
  space(4);

  const Parity(this.value);

  /// The integer value used by the serial port library
  final int value;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case Parity.none:
        return 'None';
      case Parity.odd:
        return 'Odd';
      case Parity.even:
        return 'Even';
      case Parity.mark:
        return 'Mark';
      case Parity.space:
        return 'Space';
    }
  }
}

/// Flow control options for serial communication
enum FlowControl {
  /// No flow control
  none(0),

  /// Hardware flow control (RTS/CTS)
  hardware(1),

  /// Software flow control (XON/XOFF)
  software(2),

  /// DTR/DSR flow control (not yet implemented)
  dtrDsr(3);

  const FlowControl(this.value);

  /// The integer value used by the serial port library
  final int value;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case FlowControl.none:
        return 'None';
      case FlowControl.hardware:
        return 'RTS/CTS';
      case FlowControl.software:
        return 'XON/XOFF';
      case FlowControl.dtrDsr:
        return 'DTR/DSR';
    }
  }
}

/// Configuration for a serial port connection.
///
/// This is an immutable class that holds all the parameters needed
/// to configure a serial port connection.
class SerialPortConfig extends Equatable {
  /// Creates a new serial port configuration.
  const SerialPortConfig({
    required this.portName,
    this.baudRate = 9600,
    this.dataBits = 8,
    this.stopBits = 1,
    this.parity = Parity.none,
    this.flowControl = FlowControl.none,
    this.interByteTimeout = 20,
    this.maxFrameLength = 4096,
  });

  /// Creates a default configuration for the specified port.
  factory SerialPortConfig.withDefaults(String portName) {
    return SerialPortConfig(portName: portName);
  }

  /// The name of the serial port (e.g., "COM1" on Windows, "/dev/ttyUSB0" on Linux)
  final String portName;

  /// Baud rate for the connection (default: 9600)
  final int baudRate;

  /// Number of data bits (default: 8)
  final int dataBits;

  /// Number of stop bits (default: 1)
  final int stopBits;

  /// Parity setting (default: none)
  final Parity parity;

  /// Flow control setting (default: none)
  final FlowControl flowControl;

  /// Inter-byte timeout in milliseconds for frame assembly.
  /// Bytes received within this timeout are grouped into a single frame.
  /// Default: 20ms
  final int interByteTimeout;

  /// Maximum frame length in bytes.
  /// When received data exceeds this length, it will be forced to split into a new frame.
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

  /// Common data bits options for UI selection
  static const List<int> commonDataBits = [5, 6, 7, 8];

  /// Common stop bits options for UI selection
  static const List<int> commonStopBits = [1, 2];

  /// Creates a copy of this configuration with the given fields replaced.
  SerialPortConfig copyWith({
    String? portName,
    int? baudRate,
    int? dataBits,
    int? stopBits,
    Parity? parity,
    FlowControl? flowControl,
    int? interByteTimeout,
    int? maxFrameLength,
  }) {
    return SerialPortConfig(
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
    return 'SerialPortConfig(portName: $portName, baudRate: $baudRate, '
        'dataBits: $dataBits, stopBits: $stopBits, parity: $parity, '
        'flowControl: $flowControl, interByteTimeout: $interByteTimeout, '
        'maxFrameLength: $maxFrameLength)';
  }

  /// Converts this configuration to a JSON map.
  Map<String, dynamic> toJson() {
    return {
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

  /// Creates a configuration from a JSON map.
  factory SerialPortConfig.fromJson(Map<String, dynamic> json) {
    return SerialPortConfig(
      portName: json['portName'] as String? ?? '',
      baudRate: json['baudRate'] as int? ?? 9600,
      dataBits: json['dataBits'] as int? ?? 8,
      stopBits: json['stopBits'] as int? ?? 1,
      parity: Parity.values.firstWhere(
        (p) => p.value == (json['parity'] as int? ?? 0),
        orElse: () => Parity.none,
      ),
      flowControl: FlowControl.values.firstWhere(
        (fc) => fc.value == (json['flowControl'] as int? ?? 0),
        orElse: () => FlowControl.none,
      ),
      interByteTimeout: json['interByteTimeout'] as int? ?? 20,
      maxFrameLength: json['maxFrameLength'] as int? ?? 4096,
    );
  }
}
