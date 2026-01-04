import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../../core/app_colors.dart';
import 'book_detail_screen.dart';

class BookSearchDelegate extends SearchDelegate {
  final List<Book> books; // Arama yapılacak kitap listesi

  BookSearchDelegate(this.books);

  // Arama çubuğunun sağındaki ikonlar (Temizle butonu)
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: AppColors.primary),
          onPressed: () {
            query = ''; // Yazıyı temizle
            showSuggestions(context); // Önerileri tekrar göster
          },
        ),
    ];
  }

  // Arama çubuğunun solundaki ikon (Geri butonu)
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: AppColors.primary),
      onPressed: () {
        close(context, null); // Aramayı kapat
      },
    );
  }

  // Arama sonucunu gösteren kısım (Enter'a basınca)
  @override
  Widget buildResults(BuildContext context) {
    final results = books.where((book) {
      final titleLower = book.title.toLowerCase();
      final authorLower = book.author.toLowerCase();
      final queryLower = query.toLowerCase();
      return titleLower.contains(queryLower) ||
          authorLower.contains(queryLower);
    }).toList();

    return _buildList(results, context);
  }

  // Yazarken anlık öneri gösteren kısım
  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = books.where((book) {
      final titleLower = book.title.toLowerCase();
      final authorLower = book.author.toLowerCase();
      final queryLower = query.toLowerCase();
      return titleLower.contains(queryLower) ||
          authorLower.contains(queryLower);
    }).toList();

    return _buildList(suggestions, context);
  }

  // Listeyi ekrana çizen yardımcı fonksiyon
  Widget _buildList(List<Book> list, BuildContext context) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 60, color: Colors.grey),
            const SizedBox(height: 10),
            Text(
              "Sonuç bulunamadı: \"$query\"",
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final book = list[index];
        return ListTile(
          leading: Container(
            width: 40,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              image: book.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(book.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: Colors.grey[300],
            ),
            child: book.imageUrl == null
                ? const Icon(Icons.book, size: 20)
                : null,
          ),
          title: Text(
            book.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(book.author),
          onTap: () {
            // Sonuca tıklayınca detaya git
            close(context, null); // Önce aramayı kapat
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BookDetailScreen(book: book, isAuthorMode: false),
              ),
            );
          },
        );
      },
    );
  }

  // Arama çubuğundaki "Ara" yazısını değiştir
  @override
  String get searchFieldLabel => 'Kitap veya yazar ara...';

  @override
  TextStyle? get searchFieldStyle => const TextStyle(fontSize: 18);
}
