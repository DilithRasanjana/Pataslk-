import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'screens/auth/user_type_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait mode.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  try {
    // Firebase Core: Initialize Firebase with platform-specific options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Firebase App Check: Activate security features to prevent unauthorized API usage
    await FirebaseAppCheck.instance.activate(
      // Use platform-specific verification providers
      androidProvider: AndroidProvider.playIntegrity, // Android Play Integrity API
      appleProvider: AppleProvider.deviceCheck, // Apple DeviceCheck API
    );
    debugPrint('Firebase App Check activated with production providers');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patas.lk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// This simple loading screen prevents navigation conflicts during startup
class SafeStartupScreen extends StatefulWidget {
  const SafeStartupScreen({super.key});

  @override
  State<SafeStartupScreen> createState() => _SafeStartupScreenState();
}

class _SafeStartupScreenState extends State<SafeStartupScreen> {
  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to avoid navigation during build
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _safeNavigate();
    });
  }
  
  Future<void> _safeNavigate() async {
    if (!mounted) return;
    
    // Navigate to authentication check screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthCheckScreen()),
    );
  }
  
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the user type screen after 3 seconds.
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const UserTypeScreen()),
        );
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      body: Center(
        child: Image.asset(
          'assets/logo 1 (1).png', // Ensure this asset path is correct.
          width: 130,
          height: 130,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
