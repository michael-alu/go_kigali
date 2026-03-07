import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(
      credential,
    );
    final User user = userCredential.user!;

    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .get();

    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, user.uid);
    } else {
      final UserModel userModel = UserModel(
        uid: user.uid,
        email: user.email ?? googleUser.email,
        displayName:
            user.displayName ??
            googleUser.displayName ??
            googleUser.email.split('@').first,
        createdAt: DateTime.now(),
      );
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toMap());
      return userModel;
    }
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final UserCredential credential = await _auth
        .createUserWithEmailAndPassword(email: email, password: password);

    final User user = credential.user!;

    await user.sendEmailVerification();

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

  Future<UserModel> logIn({
    required String email,
    required String password,
  }) async {
    final UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final User user = credential.user!;

    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .get();

    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, user.uid);
    } else {
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

  Future<void> logOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> sendEmailVerification() async {
    final User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<bool> isEmailVerified() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      return _auth.currentUser!.emailVerified;
    }
    return false;
  }

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
