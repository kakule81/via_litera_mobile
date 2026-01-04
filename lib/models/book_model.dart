import 'dart:convert';

class Chapter {
  final String title;
  final String content;
  final bool isDraft;

  Chapter({required this.title, required this.content, this.isDraft = true});

  // Nesneyi JSON'a çevir (Kaydetmek için)
  Map<String, dynamic> toJson() {
    return {'title': title, 'content': content, 'isDraft': isDraft};
  }

  // JSON'dan Nesne üret (Okumak için)
  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      isDraft: json['isDraft'] ?? true,
    );
  }
}

class Book {
  final String id;
  final String title;
  final String author;
  final String ownerId;
  final String? imageUrl;
  final String description;
  final double rating;
  final bool isPublished;
  final List<Chapter> chapters;
  final String category;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.ownerId,
    this.imageUrl,
    this.description = '',
    this.rating = 0.0,
    this.isPublished = false,
    this.chapters = const [],
    this.category = 'Genel',
  });

  // Nesneyi JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'ownerId': ownerId,
      'imageUrl': imageUrl,
      'description': description,
      'rating': rating,
      'isPublished': isPublished,
      'category': category,
      'chapters': chapters.map((x) => x.toJson()).toList(),
    };
  }

  // JSON'dan Nesne üret
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      ownerId: json['ownerId'] ?? 'anonymous',
      imageUrl: json['imageUrl'],
      description: json['description'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      isPublished: json['isPublished'] ?? false,
      category: json['category'] ?? 'Genel',
      chapters: json['chapters'] != null
          ? List<Chapter>.from(json['chapters'].map((x) => Chapter.fromJson(x)))
          : [],
    );
  }
}
