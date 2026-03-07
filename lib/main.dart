import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'firebase_options.dart';
import 'utils/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/listing_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  String? clientId;
  if (!kIsWeb && Platform.isIOS) {
    clientId = DefaultFirebaseOptions.ios.iosClientId;
  }

  await GoogleSignIn.instance.initialize(
    clientId: clientId,
    serverClientId: DefaultFirebaseOptions.ios.androidClientId,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ListingProvider()),
      ],
      child: const GoKigaliApp(),
    ),
  );
}

class GoKigaliApp extends StatelessWidget {
  const GoKigaliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoKigali',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthWrapper(),
    );
  }
}

/// The AuthWrapper listens to the Firebase Auth Stream
/// and decides which screen to show:
/// 1. Logged out -> LoginScreen
/// 2. Logged in, not verified -> EmailVerificationScreen
/// 3. Logged in, verified -> HomeScreen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return StreamBuilder<User?>(
      stream: authProvider.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }

        final user = snapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        if (!user.emailVerified) {
          return const EmailVerificationScreen();
        }

        authProvider.loadUserProfile();
        return const HomeScreen();
      },
    );
  }
}

/// A branded splash screen shown while Firebase initializes
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_city, size: 80, color: AppTheme.accentGold),
            const SizedBox(height: 24),
            const Text(
              'GoKigali',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Discover Kigali',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}
