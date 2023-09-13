import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserDocument(String userId, String email) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'email': email,
        // Outros campos que você pode adicionar
      });
    } catch (error) {
      print('Error creating user document: $error');
    }
  }
}
