import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _authService.currentUser != null;
  User? get currentUser => _authService.currentUser;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _userModel = await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapAuthError(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    try {
      _userModel = await _authService.signInWithGoogle();
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapAuthError(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to sign in with Google. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> logIn({required String email, required String password}) async {
    _setLoading(true);
    _clearError();
    try {
      _userModel = await _authService.logIn(email: email, password: password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapAuthError(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logOut() async {
    _setLoading(true);
    try {
      await _authService.logOut();
      _userModel = null;
      _setLoading(false);
    } catch (e) {
      _setError('Failed to log out. Please try again.');
      _setLoading(false);
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      _setError('Failed to send verification email.');
    }
  }

  Future<bool> checkEmailVerified() async {
    try {
      return await _authService.isEmailVerified();
    } catch (e) {
      return false;
    }
  }

  Future<void> loadUserProfile() async {
    final user = _authService.currentUser;
    if (user != null) {
      _userModel = await _authService.getUserProfile(user.uid);
      notifyListeners();
    }
  }

  void clearError() {
    _clearError();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please log in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
