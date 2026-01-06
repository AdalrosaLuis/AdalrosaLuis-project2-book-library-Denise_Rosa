import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Carrega a imagem e devolve o link (URL)
  Future<String?> uploadBookCover(String userId, String bookId, File file) async {
    try {
      // Organização exigida: users/{userId}/items/{itemId}/image.jpg
      final ref = _storage.ref().child('users/$userId/books/$bookId/cover.jpg');

      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Erro no Storage: $e");
      return null;
    }
  }
}