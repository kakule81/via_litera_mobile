import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/auth_service.dart';
import '../../core/book_service.dart';
import '../../models/book_model.dart';
import '../auth/login_screen.dart';
import 'book_detail_screen.dart';
import 'my_stories_screen.dart';
import 'book_search_delegate.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Kategori Filtresi için değişkenler
  final List<String> _categories = [
    'Tümü',
    'Roman',
    'Klasik',
    'Bilim Kurgu',
    'Fantezi',
    'Şiir',
    'Tarih',
  ];
  String _selectedCategory = 'Tümü';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<BookService>(context, listen: false).loadBooks();
      Provider.of<AuthService>(context, listen: false).loadUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookService = Provider.of<BookService>(context);
    final authService = Provider.of<AuthService>(context);
    final allBooks = bookService.publicBooks;

    // Filtreleme Mantığı
    final displayedBooks = _selectedCategory == 'Tümü'
        ? allBooks
        : allBooks.where((book) => book.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.background,

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),
              accountName: Text(
                authService.currentUsername ?? "Misafir Okur",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              accountEmail: Text(authService.currentUserEmail ?? ""),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  (authService.currentUsername ?? "M").isNotEmpty
                      ? (authService.currentUsername ?? "M")[0].toUpperCase()
                      : "M",
                  style: const TextStyle(
                    fontSize: 24,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: AppColors.primary),
              title: const Text(
                'Profilim',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.edit_document,
                color: AppColors.primary,
              ),
              title: const Text(
                'Hikayelerim (Yazar Paneli)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const MyStoriesScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Çıkış Yap',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                await authService.logout();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (c) => const LoginScreen()),
                  );
                }
              },
            ),
          ],
        ),
      ),

      appBar: AppBar(
        title: const Text(
          'Via Litera',
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: BookSearchDelegate(allBooks),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KATEGORİ SEÇİCİ (Yatay Liste)
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),

          // İÇERİK ALANI
          Expanded(
            child: _selectedCategory == 'Tümü'
                // TÜMÜ SEÇİLİYSE: Storytel Modu (Kayan Raflar)
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (allBooks.isNotEmpty)
                          _buildFeaturedBook(context, allBooks.first),
                        const SizedBox(height: 20),
                        _buildSectionTitle("Sizin İçin Seçtiklerimiz"),
                        _buildHorizontalBookList(context, allBooks),
                        _buildSectionTitle("En Çok Okunanlar"),
                        _buildHorizontalBookList(
                          context,
                          allBooks.reversed.toList(),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  )
                // KATEGORİ SEÇİLİYSE: Izgara Modu (Sadece o türdeki kitaplar)
                : displayedBooks.isEmpty
                ? Center(
                    child: Text("$_selectedCategory türünde kitap bulunamadı."),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Yan yana 2 kitap
                          childAspectRatio: 0.65, // Dikdörtgen oranı
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: displayedBooks.length,
                    itemBuilder: (context, index) {
                      return _buildGridBookCard(context, displayedBooks[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- YARDIMCI WIDGET'LAR ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const Icon(Icons.arrow_forward, size: 20, color: AppColors.secondary),
        ],
      ),
    );
  }

  Widget _buildFeaturedBook(BuildContext context, Book book) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (c) => BookDetailScreen(book: book, isAuthorMode: false),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.primary,
        ),
        child: Row(
          children: [
            Container(
              width: 130,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
                image: book.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(book.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: Colors.grey[800],
              ),
              child: book.imageUrl == null
                  ? const Icon(Icons.book, color: Colors.white, size: 50)
                  : null,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "HAFTANIN KİTABI",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalBookList(BuildContext context, List<Book> books) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (c) =>
                    BookDetailScreen(book: book, isAuthorMode: false),
              ),
            ),
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        image: book.imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(book.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: Colors.grey[300],
                      ),
                      child: book.imageUrl == null
                          ? const Center(
                              child: Icon(Icons.book, color: Colors.grey),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Izgara Görünümü İçin Kart Tasarımı (Kategori Seçildiğinde Kullanılır)
  Widget _buildGridBookCard(BuildContext context, Book book) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (c) => BookDetailScreen(book: book, isAuthorMode: false),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: book.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(book.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: Colors.grey[300],
              ),
              child: book.imageUrl == null
                  ? const Center(child: Icon(Icons.book))
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
