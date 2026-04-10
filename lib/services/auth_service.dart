import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  User? get currentUser => _auth.currentUser;
  
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  Future<void> saveRememberedEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('remembered_email', email);
  }
  
  Future<String?> getRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('remembered_email');
  }
  
  Future<void> clearRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('remembered_email');
  }
  
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      default:
        return 'An error occurred: ${e.message ?? "Please try again."}';
    }
  }
}
