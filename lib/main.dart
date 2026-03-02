import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';

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
/// 3. Logged in, verified -> DirectoryScreen (or Home Shell)
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return StreamBuilder<User?>(
      stream: authProvider.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        // If user is logged in but email isn't verified
        if (!user.emailVerified) {
          return const EmailVerificationScreen();
        }

        // User is logged in AND verified.
        // Also ensure user profile state is loaded from Firestore.
        authProvider.loadUserProfile();

        // Temporarily go to placeholder DirectoryScreen
        return const HomeScreen();
      },
    );
  }
}
