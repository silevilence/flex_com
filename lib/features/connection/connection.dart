/// Connection module - unified interface for Serial, TCP, and UDP connections.
///
/// This module provides:
/// - [IConnection] - Abstract interface for all connection types
/// - [ConnectionConfig] - Base configuration class with type-specific implementations
/// - [ConnectionFactory] - Factory for creating connection instances
/// - [UnifiedConnectionProvider] - Riverpod provider for connection management
library;

// Domain
export 'domain/connection.dart';
export 'domain/connection_config.dart';

// Data
export 'data/connection_factory.dart';
export 'data/serial_connection_adapter.dart';
export 'data/tcp_connection.dart';
export 'data/udp_connection.dart';

// Application
export 'application/connection_providers.dart';
