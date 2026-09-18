import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netliv/widgets/netliv_logo.dart';

void main() {
  testWidgets('NetLiv logo branding test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: NetLivLogo(fontSize: 32, showTagline: true),
          ),
        ),
      ),
    );

    // Verify that the NetLiv logo image is rendered
    expect(find.byType(Image), findsOneWidget);

    // Verify tagline is rendered
    expect(find.text('POCKET ME CINEMA'), findsOneWidget);
  });
}
