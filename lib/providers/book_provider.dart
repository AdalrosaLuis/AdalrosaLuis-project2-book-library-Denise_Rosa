import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../services/storage_service.dart';

class BookProvider with ChangeNotifier {
  List<Book> _books = [];
  String _searchQuery = '';
  String? _userId;
  bool _isLoading = false;

  final StorageService _storageService = StorageService();

  // Getters
  bool get isLoading => _isLoading;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // Lista de livros filtrada pela pesquisa
  List<Book> get books {
    if (_searchQuery.isEmpty) return _books;
    return _books.where((book) =>
    book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        book.author.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  // Atualiza o ID do utilizador e sincroniza os dados
  void updateUserId(String? uid) {
    if (_userId == uid) return;
    _userId = uid;

    if (_userId == null) {
      _books = [];
      _isLoading = false;
      notifyListeners();
    } else {
      fetchBooks();
    }
  }

  // Referência para a coleção de livros no Firestore
  CollectionReference get _db => _firestore
      .collection('users')
      .doc(_userId)
      .collection('books');

  // --- REQUISITO 3: STORAGE E PERSISTÊNCIA ---
  Future<void> saveBook(Book book, File? imageFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? imageUrl = book.imageUrl;

      // MELHORIA PONTO 1: Lógica de preenchimento automático
      int finalCurrentPage = book.currentPage;
      if (book.status.toLowerCase() == 'completed' || book.status == 'Lido') {
        finalCurrentPage = book.totalPages;
      }

      if (imageFile != null && _userId != null) {
        String bookId = book.id.isEmpty
            ? DateTime.now().millisecondsSinceEpoch.toString()
            : book.id;
        // Upload para o Firebase Storage
        imageUrl = await _storageService.uploadBookCover(_userId!, bookId, imageFile);
      }

      // Criamos a cópia com a página e imagem atualizadas
      final bookToSave = book.copyWith(
        imageUrl: imageUrl,
        currentPage: finalCurrentPage,
      );

      if (book.id.isEmpty) {
        await _db.add(bookToSave.toFirestore());
      } else {
        await _db.doc(book.id).update(bookToSave.toFirestore());
      }
    } catch (e) {
      debugPrint("Erro ao guardar livro: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- REQUISITO 3: SESSÕES DE LEITURA (COM DURAÇÃO) ---
  Future<void> addReadingSession({
    required String bookId,
    required int startPage,
    required int endPage,
    required int duration,
  }) async {
    if (_userId == null) return;
    try {
      final sessionData = {
        'bookId': bookId,
        'startPage': startPage,
        'endPage': endPage,
        'duration': duration,
        'date': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('readingSessions')
          .add(sessionData);

      // Atualiza o progresso no documento do livro
      await _db.doc(bookId).update({'currentPage': endPage});
    } catch (e) {
      debugPrint("Erro na sessão: $e");
    }
  }

  // --- REQUISITO 5: INTEGRAÇÃO API (GOOGLE BOOKS) ---
  Future<List<dynamic>> fetchSimilarBooks(String author) async {
    try {
      final url = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=inauthor:$author&maxResults=5');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['items'] ?? [];
      }
    } catch (e) {
      debugPrint("Erro API: $e");
    }
    return [];
  }

  // --- LISTAGEM EM TEMPO REAL ---
  Future<void> fetchBooks() async {
    if (_userId == null) return;
    _isLoading = true;

    try {
      _db.snapshots().listen((snapshot) {
        _books = snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- GESTÃO DE ESTADO: CÁLCULO DAS ESTATÍSTICAS ---
  Map<String, int> getStatistics() {
    return {
      'total': _books.length,
      'completed': _books.where((b) => b.status == 'completed' || b.status == 'Lido').length,
      'currentlyReading': _books.where((b) => b.status == 'currently-reading' || b.status == 'A Ler').length,
      'wantToRead': _books.where((b) => b.status == 'want-to-read' || b.status == 'Quero Ler').length,
    };
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> deleteBook(String id) async {
    await _db.doc(id).delete();
  }
}