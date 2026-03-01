import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isEmailVerified = false;
  Timer? timer;
  bool canResendEmail = false;

  @override
  void initState() {
    super.initState();
    _checkInitialVerification();

    // Check periodically if email is verified
    timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkEmailVerified(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _checkInitialVerification() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    isEmailVerified = await authProvider.checkEmailVerified();
    if (mounted) setState(() {});
  }

  Future<void> _checkEmailVerified() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    isEmailVerified = await authProvider.checkEmailVerified();

    if (isEmailVerified) {
      timer?.cancel();
      // Auth wrapper in main.dart will automatically navigate
      // when isEmailVerified becomes true in the Provider
      if (mounted) setState(() {});
    }
  }

  Future<void> _sendVerificationEmail() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 30));
      if (mounted) setState(() => canResendEmail = true);
    } catch (e) {
      if (mounted && authProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEmailVerified) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.mark_email_unread_outlined,
                size: 100,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 32),
              Text(
                'Verify your email address',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "We've sent a verification email to:\\n${authProvider.currentUser?.email}",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.email),
                label: const Text('Resend Email'),
                onPressed: canResendEmail ? _sendVerificationEmail : null,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => authProvider.logOut(),
                child: const Text('Cancel & Log Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
