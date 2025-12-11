import 'package:flutter/material.dart';

/// Home page of the FlexCom application
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FlexCom'), centerTitle: true),
      body: const Center(
        child: Text(
          'FlexCom Initialized',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
