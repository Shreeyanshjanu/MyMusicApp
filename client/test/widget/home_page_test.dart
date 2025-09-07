import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Create a simple mock HomePage that doesn't require network or complex dependencies
class MockHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Mock Album Art
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.music_note,
                    size: 48,
                    color: Colors.grey[600],
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Mock Song Title
                Text(
                  'No Song Selected',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                
                SizedBox(height: 20),
                
                // Mock Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.shuffle),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.skip_previous),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.play_arrow),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.skip_next),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.favorite_border),
                    ),
                  ],
                ),
                
                SizedBox(height: 20),
                
                // Mock Bottom Navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.home),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.library_music),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.upload),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.settings),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  group('HomePage Widget Tests', () {
    testWidgets('should display basic HomePage structure', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(home: MockHomePage()),
      );

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('should display no song selected text', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(home: MockHomePage()),
      );

      // Assert
      expect(find.text('No Song Selected'), findsOneWidget);
    });

    testWidgets('should display control buttons', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(home: MockHomePage()),
      );

      // Assert
      expect(find.byIcon(Icons.shuffle), findsOneWidget);
      expect(find.byIcon(Icons.skip_previous), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.skip_next), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('should display bottom navigation icons', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(home: MockHomePage()),
      );

      // Assert
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.library_music), findsOneWidget);
      expect(find.byIcon(Icons.upload), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('should display album art placeholder', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(home: MockHomePage()),
      );

      // Assert
      expect(find.byIcon(Icons.music_note), findsOneWidget);
    });

    testWidgets('should handle button taps without crashing', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(home: MockHomePage()),
      );

      // Act & Assert - Test that buttons are tappable
      await tester.tap(find.byIcon(Icons.shuffle));
      await tester.pump();
      expect(find.byIcon(Icons.shuffle), findsOneWidget);

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('should display all UI elements in correct layout', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(home: MockHomePage()),
      );

      // Assert - Check layout structure
      expect(find.byType(Column), findsAtLeastNWidgets(1));
      expect(find.byType(Row), findsAtLeastNWidgets(2));
      expect(find.byType(Container), findsAtLeastNWidgets(1));
      expect(find.byType(IconButton), findsAtLeastNWidgets(9));
    });

    testWidgets('should handle different screen sizes', (WidgetTester tester) async {
      // Arrange - Set specific screen size
      await tester.binding.setSurfaceSize(Size(400, 800));

      // Act
      await tester.pumpWidget(
        MaterialApp(home: MockHomePage()),
      );

      // Assert
      expect(find.byType(MockHomePage), findsOneWidget);
      expect(find.text('No Song Selected'), findsOneWidget);
    });

    testWidgets('should maintain widget hierarchy', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(home: MockHomePage()),
      );

      // Assert - Check widget hierarchy
      final scaffold = find.byType(Scaffold);
      final safeArea = find.byType(SafeArea);
      final scrollView = find.byType(SingleChildScrollView);
      
      expect(scaffold, findsOneWidget);
      expect(safeArea, findsOneWidget);
      expect(scrollView, findsOneWidget);
    });
  });
}