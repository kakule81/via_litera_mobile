class Chapter {
  final String id;
  final String title;
  final String content;
  final String? imageUrl; // Bölüm resmi
  final String? audioUrl; // Bölüm müziği

  Chapter({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.audioUrl,
  });

  // Veritabanından gelen veriyi uygulamaya çevir
  factory Chapter.fromMap(Map<String, dynamic> map, String id) {
    return Chapter(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      audioUrl: map['audioUrl'],
    );
  }
}
