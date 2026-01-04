import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../../core/app_colors.dart';
import 'writing_screen.dart';
import 'add_book_screen.dart';
import 'read_chapter_screen.dart'; // Okuma ekranını import etmeyi unutma

class BookDetailScreen extends StatefulWidget {
  final Book book;
  final bool isAuthorMode; // ÖNEMLİ: Bu sayfaya yazar mı bakıyor okur mu?

  const BookDetailScreen({
    super.key,
    required this.book,
    this.isAuthorMode = false,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.book.title,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // SADECE YAZARSA DÜZENLEME BUTONU ÇIKAR
          if (widget.isAuthorMode)
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: "Hikaye Ayarları",
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddBookScreen(bookToEdit: widget.book),
                  ),
                );
                _refresh();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- KAPAK VE BAŞLIK ALANI ---
            const SizedBox(height: 20),
            Container(
              height: 220,
              width: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 15,
                    color: Colors.black.withOpacity(0.2),
                  ),
                ],
                image: widget.book.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(widget.book.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: Colors.grey[300],
              ),
              child: widget.book.imageUrl == null
                  ? const Icon(Icons.book, size: 60, color: Colors.grey)
                  : null,
            ),
            const SizedBox(height: 20),

            // Başlık
            Text(
              widget.book.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Yazar Adı
            Text(
              "Yazar: ${widget.book.author}",
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),

            // Eğer Yazar Moduysa ve Yayında Değilse UYARI
            if (widget.isAuthorMode && !widget.book.isPublished)
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "TASLAK MODU - Okurlar Göremez",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Açıklama Metni
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                widget.book.description,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[800], height: 1.5),
              ),
            ),

            const SizedBox(height: 30),
            const Divider(),

            // --- BÖLÜMLER LİSTESİ (İÇİNDEKİLER) ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "İçindekiler",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  // SADECE YAZARSA "BÖLÜM EKLE" ÇIKAR
                  if (widget.isAuthorMode)
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                WritingScreen(book: widget.book),
                          ),
                        );
                        _refresh();
                      },
                      icon: const Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Bölüm Ekle",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),

            if (widget.book.chapters.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30.0),
                child: Center(
                  child: Text(
                    "Henüz bölüm yok.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.book.chapters.length,
                itemBuilder: (context, index) {
                  final chapter = widget.book.chapters[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      chapter.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: widget.isAuthorMode
                        ? Text(
                            chapter.isDraft ? "Taslak" : "Yayında",
                            style: TextStyle(
                              color: chapter.isDraft
                                  ? Colors.orange
                                  : Colors.green,
                              fontSize: 12,
                            ),
                          )
                        : null,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      if (widget.isAuthorMode) {
                        // YAZARSA -> DÜZENLEME EKRANINA GİT
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => WritingScreen(
                              book: widget.book,
                              chapterToEdit: chapter,
                              chapterIndex: index,
                            ),
                          ),
                        ).then((_) => _refresh());
                      } else {
                        // OKURSA -> OKUMA EKRANINA GİT (GÜNCELLENEN KISIM BURASI)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReadChapterScreen(
                              bookTitle: widget.book.title,
                              book:
                                  widget.book, // Kitabın tamamını gönderiyoruz
                              initialChapterIndex:
                                  index, // Hangi bölümde olduğumuzu gönderiyoruz
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
