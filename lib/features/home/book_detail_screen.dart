import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_colors.dart';
import '../../core/book_service.dart';

class BookDetailScreen extends StatelessWidget {
  final QueryDocumentSnapshot book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final BookService _bookService = BookService();
    final data = book.data() as Map<String, dynamic>;
    final bool isPublished = data['isPublished'] ?? false;
    final List tags = data['tags'] ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          data['title'],
          style: const TextStyle(color: AppColors.textDark, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(
                            data['imageUrl'] ??
                                'https://placehold.co/400x600/png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: data['imageUrl'] == ""
                          ? const Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['category'] ?? "Genel",
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isPublished
                                  ? Colors.green[100]
                                  : Colors.orange[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isPublished ? "YAYINDA" : "TASLAK",
                              style: TextStyle(
                                fontSize: 12,
                                color: isPublished
                                    ? Colors.green[800]
                                    : Colors.orange[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4,
                            children: tags
                                .map(
                                  (tag) => Chip(
                                    label: Text(
                                      tag,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "Özet:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  data['description'] ?? "Açıklama yok",
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _bookService.getChapters(book.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final chapters = snapshot.data!.docs;

                if (chapters.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.edit_note,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        const Text("Henüz hiç bölüm yazmadın."),
                        TextButton(
                          onPressed: () =>
                              _showAddChapterDialog(context, book.id),
                          child: const Text("İlk Bölümü Yaz"),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: chapters.length,
                  itemBuilder: (context, index) {
                    var chapter = chapters[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(chapter['title']),
                        subtitle: Text(
                          (chapter['content'] as String).length > 50
                              ? "${(chapter['content'] as String).substring(0, 50)}..."
                              : chapter['content'],
                        ),
                        trailing: const Icon(Icons.arrow_forward),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.secondary,
        onPressed: () => _showAddChapterDialog(context, book.id),
        label: const Text("Yeni Bölüm", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddChapterDialog(BuildContext context, String bookId) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    final imageCtrl = TextEditingController();
    final musicCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Yeni Bölüm Tasarla"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: "Bölüm Başlığı",
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: imageCtrl,
                decoration: const InputDecoration(
                  labelText: "Bölüm Görseli (Link)",
                  hintText: "https://...",
                  prefixIcon: Icon(Icons.image),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: musicCtrl,
                decoration: const InputDecoration(
                  labelText: "Fon Müziği (Mp3 Linki)",
                  hintText: "https://...",
                  prefixIcon: Icon(Icons.music_note),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentCtrl,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: "Hikayeni yaz...",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.isNotEmpty && contentCtrl.text.isNotEmpty) {
                await BookService().addChapter(
                  bookId: bookId,
                  chapterTitle: titleCtrl.text.trim(),
                  content: contentCtrl.text,
                  imageUrl: imageCtrl.text.trim(),
                  audioUrl: musicCtrl.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: const Text("Yayınla"),
          ),
        ],
      ),
    );
  }
}
