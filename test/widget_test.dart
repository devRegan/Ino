import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:arduino_project_hub/main.dart';
import 'package:arduino_project_hub/providers/project_provider.dart';
import 'package:arduino_project_hub/services/database_service.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    // Initialize the database for testing
    await DatabaseService.instance.initDatabase();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ProjectProvider(),
          ),
        ],
        child: const ArduinoProjectHub(),
      ),
    );

    // Verify that the app starts
    expect(find.text('Arduino Project Hub'), findsOneWidget);
  });

  testWidgets('Can navigate to add project screen',
      (WidgetTester tester) async {
    await DatabaseService.instance.initDatabase();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ProjectProvider()..loadProjects(),
          ),
        ],
        child: const ArduinoProjectHub(),
      ),
    );

    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // Find and tap the FAB
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    // Verify navigation
    expect(find.text('Add New Project'), findsOneWidget);
  });
}
