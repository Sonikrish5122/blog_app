import 'package:firebase_auth/firebase_auth.dart';

abstract class Authentication {
  Future<String?> signIn(String email, String password);
  Future<String?> signUp(String email, String password);
  Future<String?> getCurrentUser();
  Future<void> signOut();
}

class Auth implements Authentication {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<String?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.uid;
    } catch (e) {
      print("Sign-in error: $e");
      return null;
    }
  }

  @override
  Future<String?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.uid;
    } catch (e) {
      print("Sign-up error: $e");
      return null;
    }
  }

  @override
  Future<String?> getCurrentUser() async {
    try {
      User? user = _firebaseAuth.currentUser;
      return user?.uid;
    } catch (e) {
      print("Error getting current user: $e");
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print("Sign-out error: $e");
    }
  }
}
