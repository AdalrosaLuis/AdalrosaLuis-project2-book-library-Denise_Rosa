import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String genre;
  final int totalPages;
  final int currentPage;
  final String status;
  final double rating;
  final String? notes;
  final int statusColor;
  final DateTime timestamp;
  final String? imageUrl;

  // REQUISITO: Localização física e data de compra
  final String? location;
  final DateTime? purchaseDate;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.totalPages,
    this.currentPage = 0,
    required this.status,
    required this.rating,
    this.notes,
    this.statusColor = 0xFF4CAF50,
    required this.timestamp,
    this.imageUrl,
    this.location,
    this.purchaseDate,
  });

  // Auxiliares de Visualização
  String get statusDisplay {
    switch (status) {
      case 'want-to-read': return 'Quero ler';
      case 'currently-reading': return 'A ler';
      case 'completed': return 'Lido';
      default: return status;
    }
  }

  double get progressPercentage {
    if (totalPages <= 0) return 0.0;
    return (currentPage / totalPages).clamp(0.0, 1.0);
  }

  double get progressText => progressPercentage * 100;

  // Converte para salvar no Firebase (Inclui novos campos)
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'genre': genre,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'status': status,
      'rating': rating,
      'notes': notes,
      'statusColor': statusColor,
      'timestamp': timestamp,
      'imageUrl': imageUrl,
      'location': location,
      'purchaseDate': purchaseDate != null ? Timestamp.fromDate(purchaseDate!) : null,
    };
  }

  // Cria o objeto a partir do Firebase
  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      genre: data['genre'] ?? '',
      totalPages: data['totalPages'] ?? 0,
      currentPage: data['currentPage'] ?? 0,
      status: data['status'] ?? 'want-to-read',
      rating: (data['rating'] ?? 0.0).toDouble(),
      notes: data['notes'],
      statusColor: data['statusColor'] ?? 0xFF4CAF50,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: data['imageUrl'],
      location: data['location'] ?? '',
      purchaseDate: (data['purchaseDate'] as Timestamp?)?.toDate(),
    );
  }

  // Método essencial para o Provider e atualização de imagem
  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? genre,
    int? totalPages,
    int? currentPage,
    String? status,
    double? rating,
    String? notes,
    int? statusColor,
    DateTime? timestamp,
    String? imageUrl,
    String? location,
    DateTime? purchaseDate,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      statusColor: statusColor ?? this.statusColor,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      purchaseDate: purchaseDate ?? this.purchaseDate,
    );
  }
}