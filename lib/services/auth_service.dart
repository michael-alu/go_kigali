import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get the current Firebase user
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up with email and password, then create user profile in Firestore
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Create user in Firebase Auth
    final UserCredential credential = await _auth
        .createUserWithEmailAndPassword(email: email, password: password);

    final User user = credential.user!;

    // Send email verification
    await user.sendEmailVerification();

    // Create user profile in Firestore
    final UserModel userModel = UserModel(
      uid: user.uid,
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(userModel.toMap());

    return userModel;
  }

  /// Log in with email and password
  Future<UserModel> logIn({
    required String email,
    required String password,
  }) async {
    final UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final User user = credential.user!;

    // Fetch user profile from Firestore
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .get();

    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, user.uid);
    } else {
      // If profile doesn't exist yet, create one
      final UserModel userModel = UserModel(
        uid: user.uid,
        email: user.email ?? email,
        displayName: user.displayName ?? email.split('@').first,
        createdAt: DateTime.now(),
      );
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toMap());
      return userModel;
    }
  }

  /// Log out the current user
  Future<void> logOut() async {
    await _auth.signOut();
  }

  /// Send email verification to the current user
  Future<void> sendEmailVerification() async {
    final User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Check if the current user's email is verified
  Future<bool> isEmailVerified() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      return _auth.currentUser!.emailVerified;
    }
    return false;
  }

  /// Fetch user profile from Firestore by UID
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();

    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, uid);
    }
    return null;
  }
}
