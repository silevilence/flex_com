import 'dart:typed_data';

import '../domain/serial_port_config.dart';

/// Abstract repository interface for serial port operations.
///
/// This defines the contract for serial port implementations.
/// The actual implementation will use flutter_libserialport.
abstract class SerialRepository {
  /// Returns a list of available serial port names.
  ///
  /// On Windows, this returns port names like "COM1", "COM3", etc.
  /// On Linux, this returns paths like "/dev/ttyUSB0", "/dev/ttyACM0", etc.
  Future<List<String>> getAvailablePorts();

  /// Opens a serial port with the specified configuration.
  ///
  /// Throws an exception if the port cannot be opened.
  Future<void> openPort(SerialPortConfig config);

  /// Closes the currently open serial port.
  ///
  /// Does nothing if no port is currently open.
  Future<void> closePort();

  /// Sends data to the serial port.
  ///
  /// Throws an exception if no port is open or if the write fails.
  Future<void> sendData(Uint8List data);

  /// Stream of data received from the serial port.
  ///
  /// This stream emits data chunks as they are received.
  /// The stream is active only when a port is open.
  Stream<Uint8List> get dataStream;

  /// Returns true if a port is currently open.
  bool get isOpen;

  /// Returns the current port configuration, or null if no port is open.
  SerialPortConfig? get currentConfig;
}
