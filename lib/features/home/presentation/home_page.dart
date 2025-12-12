import 'package:flutter/material.dart';

import '../../serial/presentation/widgets/data_display_panel.dart';
import '../../serial/presentation/widgets/send_panel.dart';
import '../../serial/presentation/widgets/serial_config_panel.dart';

/// Home page of the FlexCom application
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FlexCom'), centerTitle: true),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left panel - Serial configuration
            SizedBox(width: 300, child: SerialConfigPanel()),
            SizedBox(width: 16),
            // Right panel - Data display and send
            Expanded(
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
    );
  }
}
