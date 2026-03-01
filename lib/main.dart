import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const GoKigaliApp());
}

class GoKigaliApp extends StatelessWidget {
  const GoKigaliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoKigali',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const Scaffold(body: Center(child: Text('GoKigali - Coming Soon'))),
    );
  }
}
