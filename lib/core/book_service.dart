import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book_model.dart';

class BookService with ChangeNotifier {
  List<Book> _books = [];

  List<Book> get books => _books;
  List<Book> get publicBooks => _books.where((b) => b.isPublished).toList();

  List<Book> getUserBooks(String userEmail) {
    return _books.where((b) => b.ownerId == userEmail).toList();
  }

  // --- HAFIZA YÖNETİMİ (KAYDET & YÜKLE) ---

  // Verileri cihaz hafızasına kaydet
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    // Listeyi JSON string'e çevirip sakla
    final String encodedData = json.encode(
      _books.map((book) => book.toJson()).toList(),
    );
    await prefs.setString('saved_books', encodedData);
  }

  // Verileri cihaz hafızasından geri yükle
  Future<void> loadBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? booksString = prefs.getString('saved_books');

    if (booksString != null && booksString.isNotEmpty) {
      // Hafızada veri varsa onu yükle
      final List<dynamic> decodedData = json.decode(booksString);
      _books = decodedData.map((item) => Book.fromJson(item)).toList();
    } else {
      // Hafıza boşsa (ilk açılış), varsayılan örnek kitapları yükle
      _books = [
        Book(
          id: '1',
          title: 'Suç ve Ceza',
          author: 'Dostoyevski',
          ownerId: 'system',
          isPublished: true,
          description: 'Bir vicdan muhasebesi.',
          rating: 9.8,
          category: 'Klasik',
          imageUrl:
              'https://upload.wikimedia.org/wikipedia/tr/2/2b/Su%C3%A7_ve_Ceza_-_Fyodor_Mihaylovi%C3%A7_Dostoyevski.png',
        ),
        Book(
          id: '2',
          title: 'Harry Potter',
          author: 'J.K. Rowling',
          ownerId: 'system',
          isPublished: true,
          description: 'Büyücülük dünyasına adım atın.',
          rating: 9.5,
          category: 'Fantezi',
          imageUrl:
              'https://upload.wikimedia.org/wikipedia/tr/6/69/Harry_Potter_ve_Felsefe_Ta%C5%9F%C4%B1.jpg',
        ),
      ];
      // Bu örnek verileri de hemen hafızaya alalım ki sonra silinmesin
      _saveToPrefs();
    }
    notifyListeners();
  }

  // --- İŞLEMLER (Her işlemden sonra _saveToPrefs çağırıyoruz) ---

  void addBook(Book book) {
    _books.add(book);
    _saveToPrefs(); // Kaydet
    notifyListeners();
  }

  void updateBook(Book oldBook, Book newBook) {
    final index = _books.indexWhere((b) => b.id == oldBook.id);
    if (index != -1) {
      _books[index] = newBook;
      _saveToPrefs(); // Kaydet
      notifyListeners();
    }
  }

  void togglePublishStatus(Book book) {
    final index = _books.indexOf(book);
    if (index != -1) {
      final oldBook = _books[index];
      _books[index] = Book(
        id: oldBook.id,
        title: oldBook.title,
        author: oldBook.author,
        ownerId: oldBook.ownerId,
        imageUrl: oldBook.imageUrl,
        description: oldBook.description,
        rating: oldBook.rating,
        chapters: oldBook.chapters,
        isPublished: !oldBook.isPublished,
        category: oldBook.category,
      );
      _saveToPrefs(); // Kaydet
      notifyListeners();
    }
  }
}
