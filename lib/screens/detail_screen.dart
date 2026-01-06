import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; // IMPORTANTE: Adicionado para o GPS
import 'dart:convert';
import '../models/book.dart';
import '../providers/book_provider.dart';
import 'add_edit_book_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  String _externalDescription = "A carregar descrição da API...";
  String? _imageUrl;
  final Color rosaBebe = const Color(0xFFFFB7C5);

  @override
  void initState() {
    super.initState();
    _fetchExternalData();
  }

  // --- FUNÇÃO GPS: Encontrar Livrarias ---
  Future<void> _procurarLivrarias() async {
    // Pesquisa por livrarias perto da localização atual no Google Maps
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=livrarias+proximas');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Não foi possível abrir o mapa';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao abrir o GPS')),
        );
      }
    }
  }

  Future<void> _fetchExternalData() async {
    try {
      final url = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=intitle:${widget.book.title}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          final info = data['items'][0]['volumeInfo'];
          if (mounted) {
            setState(() {
              _externalDescription = info['description'] ?? "Sem descrição disponível.";
              _imageUrl = info['imageLinks']?['thumbnail'];
            });
          }
          return;
        }
      }
      if (mounted) setState(() => _externalDescription = "Informação extra não encontrada.");
    } catch (e) {
      if (mounted) setState(() => _externalDescription = "Erro ao ligar à API externa.");
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  Color _parseColor(dynamic colorData) {
    if (colorData is Color) return colorData;
    if (colorData is int) return Color(colorData);
    return Colors.grey;
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Livro'),
        content: Text('Remover "${widget.book.title}" da estante?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await Provider.of<BookProvider>(context, listen: false).deleteBook(widget.book.id);
              if (context.mounted) {
                Navigator.pop(ctx);
                Navigator.pop(context);
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String displayNotes = (widget.book.notes == null || widget.book.notes!.isEmpty)
        ? 'Sem notas para este livro.'
        : widget.book.notes!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('Detalhes do Livro', style: TextStyle(color: Colors.black87)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddEditBookScreen(book: widget.book)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 250,
                width: 170,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(color: rosaBebe.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))
                  ],
                  image: _imageUrl != null
                      ? DecorationImage(image: NetworkImage(_imageUrl!), fit: BoxFit.cover)
                      : null,
                ),
                child: _imageUrl == null
                    ? Icon(Icons.book, size: 80, color: rosaBebe.withOpacity(0.5))
                    : null,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              widget.book.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 5),
            Text(
              'por ${widget.book.author}',
              style: TextStyle(fontSize: 18, color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    widget.book.statusDisplay,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: _parseColor(widget.book.statusColor),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                Text(
                  '${(widget.book.progressPercentage * 100).toStringAsFixed(0)}% Lido',
                  style: TextStyle(fontWeight: FontWeight.bold, color: rosaBebe),
                ),
              ],
            ),
            const Divider(height: 40),
            _buildDetailRow(Icons.auto_stories, 'Páginas:', '${widget.book.currentPage} / ${widget.book.totalPages}'),
            _buildDetailRow(Icons.calendar_today, 'Adicionado:', _formatDate(widget.book.timestamp)),
            const SizedBox(height: 25),
            const Text('Minhas Notas:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                displayNotes,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),
            const SizedBox(height: 30),
            const Text('Sinopse (Google Books):', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              _externalDescription,
              style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.6),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 30),

            // --- NOVO: Botão de GPS personalizado ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _procurarLivrarias,
                icon: const Icon(Icons.location_on, color: Colors.white),
                label: const Text('ENCONTRAR LIVRARIAS PRÓXIMAS',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent.withOpacity(0.8),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: rosaBebe),
          const SizedBox(width: 15),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 10),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}