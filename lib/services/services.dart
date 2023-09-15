import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> cadastrarUsuario({
    required String nome,
    required String senha,
    required String email,
    XFile? imagem,
    required String idade,
    required String sexo,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Atualize o perfil do usuário com nome e foto
        await user.updateDisplayName(nome);

        // Adicione informações adicionais do usuário ao Firestore
        await _firestore.collection('usuarios').doc(user.uid).set({
          'nome': nome,
          'email': email,
          'idade': idade,
          'sexo': sexo,
        });

        // Enviar a imagem para o armazenamento (Firebase Storage) e armazenar o URL no Firestore.
        if (imagem != null) {
          final storage = FirebaseStorage.instance;

          final imageRef = storage
              .ref()
              .child('usuarios')
              .child('imagens/${user.uid}/avatar.jpg');

          final UploadTask uploadTask = imageRef.putFile(File(imagem.path));
          await uploadTask.whenComplete(() => null);

          final imageUrl = await imageRef.getDownloadURL();

          // Atualizar o perfil do usuário com a URL da imagem
          await user.updatePhotoURL(imageUrl);

          // Atualizar o documento do usuário com o URL da imagem no Firestore
          await _firestore.collection('usuarios').doc(user.uid).update({
            'imagemUrl': imageUrl,
          });
        }
      }

      return user;
    } catch (e) {
      print('Erro ao registrar usuário: $e');
      return null;
    }
  }
}
