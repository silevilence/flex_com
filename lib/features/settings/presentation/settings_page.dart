import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_widget.dart';

/// Settings page of the FlexCom application
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: const PlaceholderWidget(featureName: 'Settings'),
    );
  }
}
