// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flex_com/main.dart';

void main() {
  testWidgets('FlexCom app smoke test', (WidgetTester tester) async {
    // Use a larger surface size to avoid layout overflow in test environment
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: FlexComApp()));

    // Verify that the app is initialized correctly with title.
    expect(find.text('FlexCom'), findsOneWidget);

    // Verify that the serial config panel is rendered.
    expect(find.text('串口配置'), findsOneWidget);
  });
}
