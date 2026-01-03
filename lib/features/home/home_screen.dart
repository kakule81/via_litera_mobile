import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_colors.dart';
import '../../core/auth_service.dart';
import '../../core/book_service.dart';
import '../auth/login_screen.dart';
import 'add_book_screen.dart';
import 'book_detail_screen.dart'; // Detay sayfasını ekledik

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    final BookService _bookService = BookService();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Kütüphanem",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.secondary),
            onPressed: () async {
              await _authService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      // CANLI LİSTELEME KISMI
      body: StreamBuilder<QuerySnapshot>(
        stream: _bookService.getBooks(user?.uid ?? ""),
        builder: (context, snapshot) {
          // 1. Hata Kontrolü
          if (snapshot.hasError) {
            return const Center(child: Text("Bir hata oluştu"));
          }

          // 2. Yükleniyor Kontrolü
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;

          // 3. Veri Yoksa (Boşsa)
          if (data == null || data.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    "Henüz kitap oluşturmadın",
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  const Text("Haydi ilk şaheserini yazmaya başla! ✍️"),
                ],
              ),
            );
          }

          // 4. Kitaplar Geldiyse Listele
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.docs.length,
            itemBuilder: (context, index) {
              // Veriyi alıyoruz
              var book = data.docs[index];
              var bookData = book.data() as Map<String, dynamic>;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  // Sol taraf: Kapak Resmi
                  leading: Container(
                    width: 50,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                      image: DecorationImage(
                        image: NetworkImage(
                          (bookData['imageUrl'] == null ||
                                  bookData['imageUrl'] == "")
                              ? "https://placehold.co/100x150/png" // Varsayılan resim
                              : bookData['imageUrl'],
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child:
                        (bookData['imageUrl'] == null ||
                            bookData['imageUrl'] == "")
                        ? const Icon(Icons.book, color: Colors.grey)
                        : null,
                  ),
                  // Orta: Başlık ve Kategori
                  title: Text(
                    bookData['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bookData['category'] ?? "Genel"),
                      const SizedBox(height: 4),
                      // Taslak mı Yayında mı?
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (bookData['isPublished'] == true)
                              ? Colors.green[50]
                              : Colors.orange[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          (bookData['isPublished'] == true)
                              ? "YAYINDA"
                              : "TASLAK",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: (bookData['isPublished'] == true)
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Sağ: Ok/Detay ikonu
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),

                  // TIKLAYINCA DETAY SAYFASINA GİT
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetailScreen(book: book),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      // EKLEME BUTONU
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBookScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
