import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../commands/presentation/widgets/command_list_panel.dart';
import '../../serial/application/send_helper_providers.dart';
import '../../serial/presentation/widgets/data_display_panel.dart';
import '../../serial/presentation/widgets/send_panel.dart';
import '../../serial/presentation/widgets/serial_config_panel.dart';
import '../../serial/presentation/widgets/status_bar.dart';

/// Home page of the FlexCom application
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('FlexCom'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left panel - Serial configuration and command list
                  SizedBox(
                    width: 300,
                    child: Column(
                      children: [
                        // Serial configuration (shrink wrapped with scroll)
                        Flexible(
                          flex: 2,
                          child: SingleChildScrollView(
                            child: const SerialConfigPanel(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Command list (expandable, with minimum height)
                        Flexible(
                          flex: 3,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 150),
                            child: CommandListPanel(
                              onSendCommand: (command) {
                                // 调用 SendPanel 的发送逻辑
                                ref
                                    .read(sendPanelControllerProvider.notifier)
                                    .sendCommand(command);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right panel - Data display and send
                  const Expanded(
                    child: Column(
                      children: [
                        // Data display area (takes most space)
                        Expanded(child: DataDisplayPanel()),
                        SizedBox(height: 8),
                        // Send panel at the bottom
                        SendPanel(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Status bar at the bottom
          const StatusBar(),
        ],
      ),
    );
  }
}
