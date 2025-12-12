import 'dart:typed_data';

import '../domain/serial_port_config.dart';

/// Types of commands that can be sent to the serial isolate.
enum IsolateCommandType {
  /// Initialize the isolate and return a SendPort for communication
  init,

  /// Get list of available serial ports
  getPorts,

  /// Open a serial port with configuration
  openPort,

  /// Close the currently open port
  closePort,

  /// Send data through the serial port
  sendData,

  /// Dispose the isolate resources
  dispose,
}

/// Types of responses from the serial isolate.
enum IsolateResponseType {
  /// Initialization complete with SendPort
  initialized,

  /// List of available ports
  portList,

  /// Port opened successfully
  portOpened,

  /// Port closed successfully
  portClosed,

  /// Data sent successfully
  dataSent,

  /// Data received from serial port
  dataReceived,

  /// An error occurred
  error,

  /// Isolate is disposed
  disposed,
}

/// Command message sent to the serial isolate.
class IsolateCommand {
  const IsolateCommand({required this.type, this.config, this.data});

  /// The type of command to execute
  final IsolateCommandType type;

  /// Serial port configuration (for openPort command)
  final SerialPortConfig? config;

  /// Data to send (for sendData command)
  final Uint8List? data;
}

/// Response message from the serial isolate.
class IsolateResponse {
  const IsolateResponse({
    required this.type,
    this.ports,
    this.data,
    this.error,
  });

  /// Factory for success responses
  factory IsolateResponse.success(IsolateResponseType type) {
    return IsolateResponse(type: type);
  }

  /// Factory for port list response
  factory IsolateResponse.portList(List<String> ports) {
    return IsolateResponse(type: IsolateResponseType.portList, ports: ports);
  }

  /// Factory for data received response
  factory IsolateResponse.dataReceived(Uint8List data) {
    return IsolateResponse(type: IsolateResponseType.dataReceived, data: data);
  }

  /// Factory for error response
  factory IsolateResponse.error(String message) {
    return IsolateResponse(type: IsolateResponseType.error, error: message);
  }

  /// The type of response
  final IsolateResponseType type;

  /// List of available ports (for portList response)
  final List<String>? ports;

  /// Received data (for dataReceived response)
  final Uint8List? data;

  /// Error message (for error response)
  final String? error;

  /// Whether this response indicates an error
  bool get isError => type == IsolateResponseType.error;
}
