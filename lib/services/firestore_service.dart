import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:book_library/models/book.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream em tempo real - Corrigido para passar apenas 'doc'
  Stream<List<Book>> getBooksStream() {
    return _firestore
        .collection('books')
        .orderBy('timestamp', descending: true) // Usei 'timestamp' que está no teu Book model
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Book.fromFirestore(doc))
        .toList());
  }

  // Filtro por status
  Stream<List<Book>> getBooksByStatus(String status) {
    return _firestore
        .collection('books')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Book.fromFirestore(doc))
        .toList());
  }

  Future<String> addBook(Book book) async {
    try {
      final docRef = await _firestore.collection('books').add(book.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Falha ao adicionar: $e');
    }
  }

  Future<void> updateBook(String bookId, Book book) async {
    try {
      await _firestore.collection('books').doc(bookId).update(book.toFirestore());
    } catch (e) {
      throw Exception('Falha ao atualizar: $e');
    }
  }

  Future<void> deleteBook(String bookId) async {
    try {
      await _firestore.collection('books').doc(bookId).delete();
    } catch (e) {
      throw Exception('Falha ao eliminar: $e');
    }
  }

  // Estatísticas para o teu Histograma (Corrigido para evitar erro de 'num' vs 'int')
  Future<Map<String, dynamic>> getReadingStats() async {
    final snapshot = await _firestore.collection('books').get();
    final books = snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();

    final completed = books.where((b) => b.status == 'completed').length;
    final reading = books.where((b) => b.status == 'currently-reading').length;
    final wantToRead = books.where((b) => b.status == 'want-to-read').length;

    // O .toInt() garante que o Flutter não reclame de tipos numéricos
    final totalPages = books.fold(0, (sum, book) => (sum + book.totalPages).toInt());
    final pagesRead = books.fold(0, (sum, book) => (sum + book.currentPage).toInt());

    return {
      'totalBooks': books.length,
      'completed': completed,
      'reading': reading,
      'wantToRead': wantToRead,
      'totalPages': totalPages,
      'pagesRead': pagesRead,
    };
  }
}
