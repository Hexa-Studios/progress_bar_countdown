import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progress_bar_countdown/progress_bar_countdown.dart';

void main() {
  testWidgets('ProgressBarCountdown initializes correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProgressBarCountdown(
            initialDuration: Duration(seconds: 60),
            progressColor: Colors.blue,
            progressBackgroundColor: Colors.grey,
          ),
        ),
      ),
    );

    expect(find.byType(ProgressBarCountdown), findsOneWidget);
    expect(find.text('60'), findsOneWidget);
  });
}
