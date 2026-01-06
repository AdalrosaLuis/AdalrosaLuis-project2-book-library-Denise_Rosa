import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
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
  bool _isSearchingSimilar = false;

  @override
  Widget build(BuildContext context) {
    final dateAdded = DateFormat('dd/MM/yyyy HH:mm').format(widget.book.timestamp);
    final purchaseDate = widget.book.purchaseDate != null
        ? DateFormat('dd/MM/yyyy').format(widget.book.purchaseDate!)
        : 'Não registada';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Livro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final String message =
                  "Estou a ler '${widget.book.title}' de ${widget.book.author}. Minha avaliação: ${widget.book.rating}/5! 📚";
              Share.share(message);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddEditBookScreen(book: widget.book)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.book.title,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            Text(widget.book.author,
                style: TextStyle(fontSize: 18, color: Colors.grey[700])),
            const SizedBox(height: 20),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Progresso de Leitura', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${(widget.book.progressPercentage * 100).toStringAsFixed(0)}%'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: widget.book.progressPercentage,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(10),
                      backgroundColor: Colors.grey[200],
                      color: Colors.green,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Página ${widget.book.currentPage} de ${widget.book.totalPages}'),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.green, size: 30),
                          onPressed: () => _showReadingSessionDialog(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),
            _buildInfoRow(Icons.category, 'Género', widget.book.genre),
            _buildInfoRow(Icons.star, 'Avaliação', '${widget.book.rating} / 5.0'),
            _buildInfoRow(Icons.info_outline, 'Estado', widget.book.statusDisplay),
            _buildInfoRow(Icons.location_on, 'Localização',
                (widget.book.location == null || widget.book.location!.isEmpty)
                    ? 'Não definida'
                    : widget.book.location!),
            _buildInfoRow(Icons.shopping_bag, 'Comprado em', purchaseDate),
            _buildInfoRow(Icons.calendar_today, 'Adicionado em', dateAdded),

            const SizedBox(height: 25),
            const Text('Notas Pessoais', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.book.notes == null || widget.book.notes!.isEmpty
                    ? 'Sem notas adicionadas.'
                    : widget.book.notes!,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),

            const SizedBox(height: 30),

            // NOVO: BOTÃO PARA DESCOBRIR LIVROS SEMELHANTES (INTEGRAÇÃO API)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isSearchingSimilar
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.auto_stories),
                label: const Text("Descobrir livros semelhantes"),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                onPressed: _isSearchingSimilar ? null : _showSimilarBooks,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // DIÁLOGO ATUALIZADO COM CAMPO DE DURAÇÃO (REQUISITO SESSÕES)
  void _showReadingSessionDialog(BuildContext context) {
    final pageController = TextEditingController();
    final durationController = TextEditingController(); // NOVO

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Registar Sessão de Leitura"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Página atual: ${widget.book.currentPage}"),
            const SizedBox(height: 15),
            TextField(
              controller: pageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Leste até que página?", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Duração (minutos)", border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              int newPage = int.tryParse(pageController.text) ?? widget.book.currentPage;
              int duration = int.tryParse(durationController.text) ?? 0;

              await Provider.of<BookProvider>(context, listen: false)
                  .addReadingSession(
                  bookId: widget.book.id,
                  startPage: widget.book.currentPage,
                  endPage: newPage,
                  duration: duration // NOVO CAMPO
              );
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text("Registar"),
          ),
        ],
      ),
    );
  }

  // FUNÇÃO PARA BUSCAR LIVROS SEMELHANTES VIA API
  Future<void> _showSimilarBooks() async {
    setState(() => _isSearchingSimilar = true);
    try {
      final similarBooks = await Provider.of<BookProvider>(context, listen: false)
          .fetchSimilarBooks(widget.book.author);

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Mais livros deste autor", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: similarBooks.length,
                  itemBuilder: (context, i) {
                    final info = similarBooks[i]['volumeInfo'];
                    return ListTile(
                      leading: const Icon(Icons.book),
                      title: Text(info['title'] ?? 'Sem título'),
                      subtitle: Text(info['authors']?.join(', ') ?? 'Autor desconhecido'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao buscar livros semelhantes")));
    } finally {
      setState(() => _isSearchingSimilar = false);
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Livro'),
        content: const Text('Deseja remover este livro da sua biblioteca?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () async {
              await Provider.of<BookProvider>(context, listen: false).deleteBook(widget.book.id);
              if (mounted) {
                Navigator.pop(ctx);
                Navigator.pop(context);
              }
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}