import 'package:flutter/material.dart';

class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kigali City')),
      body: const Center(
        child: Text(
          'Directory - Coming Soon',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
