import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart'
    hide SerialPortConfig;
import 'package:flutter_libserialport/flutter_libserialport.dart'
    as libserial
    show SerialPortConfig;

import '../domain/serial_port_config.dart';
import 'isolate_messages.dart';

/// Service that manages serial port operations in a separate isolate.
///
/// This prevents blocking the UI thread during serial I/O operations.
class SerialIsolateService {
  SerialIsolateService();

  Isolate? _isolate;
  SendPort? _sendPort;
  ReceivePort? _receivePort;
  StreamSubscription<dynamic>? _receiveSubscription;

  final _dataController = StreamController<Uint8List>.broadcast();
  final _responseController = StreamController<IsolateResponse>.broadcast();

  Completer<void>? _initCompleter;
  Completer<IsolateResponse>? _pendingCommand;

  /// Stream of data received from the serial port.
  Stream<Uint8List> get dataStream => _dataController.stream;

  /// Whether the isolate is running.
  bool get isRunning => _isolate != null;

  /// Starts the serial isolate.
  Future<void> start() async {
    if (_isolate != null) {
      return;
    }

    _initCompleter = Completer<void>();
    _receivePort = ReceivePort();

    _receiveSubscription = _receivePort!.listen(_handleMessage);

    _isolate = await Isolate.spawn(_isolateEntryPoint, _receivePort!.sendPort);

    await _initCompleter!.future;
    _initCompleter = null;
  }

  /// Stops the serial isolate and releases resources.
  Future<void> stop() async {
    if (_isolate == null) {
      return;
    }

    // Send dispose command
    _sendPort?.send(const IsolateCommand(type: IsolateCommandType.dispose));

    // Wait a bit for graceful shutdown
    await Future<void>.delayed(const Duration(milliseconds: 100));

    await _receiveSubscription?.cancel();
    _receivePort?.close();
    _isolate?.kill(priority: Isolate.immediate);

    _isolate = null;
    _sendPort = null;
    _receivePort = null;
    _receiveSubscription = null;
  }

  /// Gets the list of available serial ports.
  Future<List<String>> getAvailablePorts() async {
    final response = await _sendCommand(
      const IsolateCommand(type: IsolateCommandType.getPorts),
    );

    if (response.isError) {
      throw SerialPortException(response.error ?? 'Unknown error');
    }

    return response.ports ?? [];
  }

  /// Opens a serial port with the given configuration.
  Future<void> openPort(SerialPortConfig config) async {
    final response = await _sendCommand(
      IsolateCommand(type: IsolateCommandType.openPort, config: config),
    );

    if (response.isError) {
      throw SerialPortException(response.error ?? 'Failed to open port');
    }
  }

  /// Closes the currently open serial port.
  Future<void> closePort() async {
    final response = await _sendCommand(
      const IsolateCommand(type: IsolateCommandType.closePort),
    );

    if (response.isError) {
      throw SerialPortException(response.error ?? 'Failed to close port');
    }
  }

  /// Sends data through the serial port.
  Future<void> sendData(Uint8List data) async {
    final response = await _sendCommand(
      IsolateCommand(type: IsolateCommandType.sendData, data: data),
    );

    if (response.isError) {
      throw SerialPortException(response.error ?? 'Failed to send data');
    }
  }

  /// Disposes the service and releases all resources.
  Future<void> dispose() async {
    await stop();
    await _dataController.close();
    await _responseController.close();
  }

  Future<IsolateResponse> _sendCommand(IsolateCommand command) async {
    if (_sendPort == null) {
      throw StateError('Isolate not started. Call start() first.');
    }

    _pendingCommand = Completer<IsolateResponse>();
    _sendPort!.send(command);

    return _pendingCommand!.future;
  }

  void _handleMessage(dynamic message) {
    if (message is SendPort) {
      // Received the SendPort from isolate during initialization
      _sendPort = message;
      _initCompleter?.complete();
      return;
    }

    if (message is IsolateResponse) {
      if (message.type == IsolateResponseType.dataReceived) {
        // Data received - forward to data stream
        if (message.data != null) {
          _dataController.add(message.data!);
        }
      } else {
        // Command response - complete pending command
        _pendingCommand?.complete(message);
        _pendingCommand = null;
      }
    }
  }

  /// Entry point for the isolate.
  static void _isolateEntryPoint(SendPort mainSendPort) {
    // Use runZonedGuarded to catch all unhandled exceptions in isolate
    runZonedGuarded(() => _isolateMain(mainSendPort), (error, stackTrace) {
      // Check for known libserialport FFI errors that are non-fatal
      final errorStr = error.toString();
      if (errorStr.contains('length must be in the range')) {
        // libserialport FFI buffer error - ignore silently
        // This happens on Windows when the port buffer state becomes invalid
        return;
      }
      // Send other errors to main thread
      mainSendPort.send(IsolateResponse.error('Isolate error: $error'));
    });
  }

  /// Main isolate logic
  static void _isolateMain(SendPort mainSendPort) {
    final isolateReceivePort = ReceivePort();
    mainSendPort.send(isolateReceivePort.sendPort);

    SerialPort? port;
    SerialPortReader? reader;
    StreamSubscription<Uint8List>? readerSubscription;

    isolateReceivePort.listen((dynamic message) {
      if (message is! IsolateCommand) return;

      switch (message.type) {
        case IsolateCommandType.init:
          // Already initialized
          break;

        case IsolateCommandType.getPorts:
          try {
            final ports = SerialPort.availablePorts;
            mainSendPort.send(IsolateResponse.portList(ports));
          } catch (e) {
            mainSendPort.send(IsolateResponse.error(e.toString()));
          }

        case IsolateCommandType.openPort:
          try {
            final config = message.config;
            if (config == null) {
              mainSendPort.send(
                IsolateResponse.error('No configuration provided'),
              );
              return;
            }

            // Close existing port if open
            readerSubscription?.cancel();
            reader?.close();
            port?.close();

            // Open new port
            port = SerialPort(config.portName);

            if (!port!.openReadWrite()) {
              // Get error code and provide user-friendly message
              final lastError = SerialPort.lastError;
              final errorCode = lastError?.errorCode ?? -1;
              String errorMessage;

              // Common error codes on Windows
              switch (errorCode) {
                case 0:
                  errorMessage = '串口打开失败，请检查串口是否存在或被占用';
                case 2:
                  errorMessage = '串口不存在或已被移除';
                case 5:
                  errorMessage = '串口访问被拒绝，可能已被其他程序占用';
                case 21:
                  errorMessage = '设备未就绪';
                case 31:
                  errorMessage = '连接到系统的设备没有发挥作用';
                case 1117:
                  errorMessage = '设备 I/O 错误';
                default:
                  errorMessage = '无法打开串口 (错误码: $errorCode)';
              }

              mainSendPort.send(IsolateResponse.error(errorMessage));
              port = null;
              return;
            }

            // Configure port
            final portConfig = libserial.SerialPortConfig()
              ..baudRate = config.baudRate
              ..bits = config.dataBits
              ..stopBits = config.stopBits
              ..parity = config.parity.value;

            // Handle flow control
            // DTR/DSR flow control requires manual configuration
            // since setFlowControl only supports none, hardware (RTS/CTS),
            // and software (XON/XOFF)
            if (config.flowControl == FlowControl.dtrDsr) {
              // Set DTR for flow control and DSR for flow control
              portConfig.dtr = SerialPortDtr.flowControl;
              portConfig.dsr = SerialPortDsr.flowControl;
            } else {
              // Use standard flow control settings
              portConfig.setFlowControl(config.flowControl.value);
            }

            port!.config = portConfig;

            // Function to start or restart reader
            void startReader() {
              readerSubscription?.cancel();
              reader?.close();

              try {
                reader = SerialPortReader(port!);
                readerSubscription = reader!.stream.listen(
                  (data) {
                    try {
                      // IMPORTANT: Copy data immediately within isolate
                      // libserialport may reuse the buffer after callback returns
                      if (data.isNotEmpty) {
                        final dataCopy = Uint8List.fromList(data);
                        mainSendPort.send(
                          IsolateResponse.dataReceived(dataCopy),
                        );
                      }
                    } catch (e) {
                      // Ignore data processing errors, continue reading
                    }
                  },
                  onError: (Object error) {
                    // libserialport may throw Invalid argument errors on Windows
                    // when port state becomes invalid. Try to restart reader.
                    final errorStr = error.toString();

                    // Check for known non-fatal FFI errors
                    if (errorStr.contains('length must be in the range')) {
                      // Buffer state error - try to restart reader after delay
                      Future.delayed(const Duration(milliseconds: 200), () {
                        if (port != null && port!.isOpen) {
                          startReader();
                        }
                      });
                      return;
                    }

                    // For other errors, also try to restart
                    try {
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (port != null && port!.isOpen) {
                          startReader();
                        }
                      });
                    } catch (_) {
                      // If restart fails, just log error
                    }
                  },
                  cancelOnError: false,
                );
              } catch (e) {
                // SerialPortReader creation may fail if port is in bad state
                // Check for known FFI errors
                final errorStr = e.toString();
                if (errorStr.contains('length must be in the range')) {
                  // Try to restart after delay
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (port != null && port!.isOpen) {
                      startReader();
                    }
                  });
                  return;
                }
                // Silently ignore other errors - user can manually reconnect
              }
            }

            // Start reading
            startReader();

            mainSendPort.send(
              IsolateResponse.success(IsolateResponseType.portOpened),
            );
          } catch (e) {
            mainSendPort.send(IsolateResponse.error(e.toString()));
          }

        case IsolateCommandType.closePort:
          try {
            readerSubscription?.cancel();
            readerSubscription = null;
            reader?.close();
            reader = null;
            port?.close();
            port = null;

            mainSendPort.send(
              IsolateResponse.success(IsolateResponseType.portClosed),
            );
          } catch (e) {
            mainSendPort.send(IsolateResponse.error(e.toString()));
          }

        case IsolateCommandType.sendData:
          try {
            if (port == null || !port!.isOpen) {
              mainSendPort.send(IsolateResponse.error('Port not open'));
              return;
            }

            final data = message.data;
            if (data == null) {
              mainSendPort.send(IsolateResponse.error('No data to send'));
              return;
            }

            final bytesWritten = port!.write(data);
            if (bytesWritten < 0) {
              final error = SerialPort.lastError?.message ?? 'Write failed';
              mainSendPort.send(IsolateResponse.error(error));
              return;
            }

            mainSendPort.send(
              IsolateResponse.success(IsolateResponseType.dataSent),
            );
          } catch (e) {
            mainSendPort.send(IsolateResponse.error(e.toString()));
          }

        case IsolateCommandType.dispose:
          readerSubscription?.cancel();
          reader?.close();
          port?.close();
          isolateReceivePort.close();
      }
    });
  }
}

/// Exception thrown when a serial port operation fails.
class SerialPortException implements Exception {
  const SerialPortException(this.message);

  final String message;

  @override
  String toString() => 'SerialPortException: $message';
}
