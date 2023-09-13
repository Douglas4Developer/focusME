import 'package:firebase_auth/firebase_auth.dart';

class AuthManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (error) {
      print('Error: $error');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
