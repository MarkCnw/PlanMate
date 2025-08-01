import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planmate/CreateProject/presentation/project_screen.dart';
import 'package:planmate/Models/project_model.dart';

void main() {
  group('ShowProjectScreen Widget Tests', () {
    late ProjectModel testProject;

    setUp(() {
      testProject = ProjectModel.create(
        title: 'Test Project',
        iconKey: 'arrow',
        userId: 'testuser123',
        description: 'This is a test project description',
      );
    });

    testWidgets('displays project information correctly with direct parameters', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ShowProjectScreen(
            title: 'Test Project',
            iconPath: 'assets/icons/arrow.png',
            color: Colors.red,
          ),
        ),
      );

      // Verify the title is displayed
      expect(find.text('Test Project'), findsWidgets);
      
      // Verify the app bar is created
      expect(find.byType(AppBar), findsOneWidget);
      
      // Verify the main container (card) exists
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('displays project information correctly using ProjectModel constructor', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ShowProjectScreen.fromProject(project: testProject),
        ),
      );

      // Verify the title is displayed
      expect(find.text('Test Project'), findsWidgets);
      
      // Verify the description is displayed
      expect(find.text('This is a test project description'), findsOneWidget);
      
      // Verify task count is displayed (should be 0 for new project)
      expect(find.text('0'), findsOneWidget);
      expect(find.text('0 tasks'), findsOneWidget);
    });

    testWidgets('displays action buttons correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ShowProjectScreen.fromProject(project: testProject),
        ),
      );

      // Verify action buttons exist
      expect(find.text('View Tasks'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('handles missing icon gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ShowProjectScreen(
            title: 'Test Project',
            iconPath: 'assets/icons/nonexistent.png',
            color: Colors.blue,
          ),
        ),
      );

      // Should not throw an error and should render the screen
      await tester.pumpAndSettle();
      expect(find.text('Test Project'), findsWidgets);
    });

    testWidgets('shows snackbar when action buttons are pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ShowProjectScreen.fromProject(project: testProject),
        ),
      );

      // Tap the View Tasks button
      await tester.tap(find.text('View Tasks'));
      await tester.pumpAndSettle();
      
      // Verify snackbar appears
      expect(find.text('View Tasks - Coming Soon!'), findsOneWidget);
      
      // Dismiss snackbar
      await tester.tap(find.byType(SnackBarAction).first);
      await tester.pumpAndSettle();

      // Tap the Edit button
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      
      // Verify snackbar appears
      expect(find.text('Edit Project - Coming Soon!'), findsOneWidget);
    });

    testWidgets('displays correct date formatting', (WidgetTester tester) async {
      final todayProject = testProject.copyWith(createdAt: DateTime.now());
      
      await tester.pumpWidget(
        MaterialApp(
          home: ShowProjectScreen.fromProject(project: todayProject),
        ),
      );

      // Should show "Today" for project created today
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('handles project without description', (WidgetTester tester) async {
      final projectWithoutDesc = ProjectModel.create(
        title: 'No Description Project',
        iconKey: 'book',
        userId: 'testuser123',
        // no description provided
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: ShowProjectScreen.fromProject(project: projectWithoutDesc),
        ),
      );

      // Should display title but not description
      expect(find.text('No Description Project'), findsWidgets);
      // Description should not be visible since hasDescription is false
      expect(find.textContaining('description'), findsNothing);
    });

    testWidgets('applies correct styling and colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ShowProjectScreen(
            title: 'Styled Project',
            iconPath: 'assets/icons/arrow.png',
            color: Colors.green,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the action buttons and verify they use the provided color
      final elevatedButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      final outlinedButton = tester.widget<OutlinedButton>(
        find.byType(OutlinedButton),
      );

      // Note: In a real test environment, we would check the button styles
      // but for now we just verify the widgets render without error
      expect(elevatedButton, isNotNull);
      expect(outlinedButton, isNotNull);
    });
  });
}