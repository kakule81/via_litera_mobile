import 'package:cloud_firestore/cloud_firestore.dart';

class BookService {
  final CollectionReference _booksRef = FirebaseFirestore.instance.collection(
    'books',
  );

  // 1. Kitap Oluşturma (Metadata: Kapak, Konu, Etiketler)
  Future<String?> createBook({
    required String title,
    required String description,
    required String imageUrl, // Kitap kapağı linki
    required String category, // Türü (Fantastik, Bilim Kurgu vb.)
    required String tags, // Anahtar kelimeler
    required bool isPublished, // Taslak mı, Yayında mı?
    required String uid,
  }) async {
    try {
      await _booksRef.add({
        'title': title,
        'description': description,
        'imageUrl': imageUrl.isEmpty
            ? 'https://placehold.co/400x600/png'
            : imageUrl, // Boşsa varsayılan resim
        'category': category,
        'tags': tags.split(','), // Virgülle ayrılanları listeye çevir
        'isPublished': isPublished,
        'userId': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'chapterCount': 0, // Henüz bölüm yok
      });
      return "Success";
    } catch (e) {
      return "Kitap oluşturulurken hata: $e";
    }
  }

  // GÜNCELLENMİŞ BÖLÜM EKLEME (FOTO VE MÜZİK DESTEKLİ)
  Future<String?> addChapter({
    required String bookId,
    required String chapterTitle,
    required String content,
    String? imageUrl, // İsteğe bağlı
    String? audioUrl, // İsteğe bağlı
  }) async {
    try {
      await _booksRef.doc(bookId).collection('chapters').add({
        'title': chapterTitle,
        'content': content,
        'imageUrl': imageUrl ?? "", // Boşsa boş metin kaydet
        'audioUrl': audioUrl ?? "", // Boşsa boş metin kaydet
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Kitabın bölüm sayısını 1 arttır
      await _booksRef.doc(bookId).update({
        'chapterCount': FieldValue.increment(1),
      });

      return "Success";
    } catch (e) {
      return "Bölüm eklenirken hata: $e";
    }
  }

  // 3. Bir Kitabın Bölümlerini Getir
  Stream<QuerySnapshot> getChapters(String bookId) {
    return _booksRef
        .doc(bookId)
        .collection('chapters')
        .orderBy('createdAt')
        .snapshots();
  }

  // 4. Kullanıcının Kitaplarını Getir
  Stream<QuerySnapshot> getBooks(String uid) {
    return _booksRef
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
