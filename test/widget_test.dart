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

    // Verify that NetLiv logo RichText is rendered
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('NETLIV'),
      ),
      findsOneWidget,
    );

    // Verify tagline is rendered
    expect(find.text('STUDIO CINEMA STREAMING'), findsOneWidget);
  });
}
