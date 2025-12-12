import 'package:flutter/material.dart';

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
            // Right panel - Placeholder for future data display
            Expanded(
              child: Card(
                child: Center(
                  child: Text(
                    '数据收发区\n(待实现)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
