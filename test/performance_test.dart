import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/main.dart' as app;

void main() {
  
  // IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App startup performance test', (WidgetTester tester) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    
    // Launch the app
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));
    
    stopwatch.stop();
    debugPrint('App startup took: ${stopwatch.elapsedMilliseconds}ms'); // Use debugPrint instead of print
    
    // Verify the app started successfully
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Set a performance budget
    expect(stopwatch.elapsedMilliseconds, lessThan(3000)); // Should load in under 3s
  });
}
