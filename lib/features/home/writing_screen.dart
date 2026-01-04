import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/book_model.dart';

class WritingScreen extends StatefulWidget {
  final Book book;
  final Chapter? chapterToEdit; // Düzenlenecek bölüm (varsa)
  final int? chapterIndex; // Hangi sıradaki bölüm olduğu

  const WritingScreen({
    super.key,
    required this.book,
    this.chapterToEdit,
    this.chapterIndex,
  });

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  int _wordCount = 0;
  bool _isDraft = true;

  @override
  void initState() {
    super.initState();
    // Eğer düzenleme modundaysak verileri doldur
    _titleController = TextEditingController(
      text: widget.chapterToEdit?.title ?? "",
    );
    _contentController = TextEditingController(
      text: widget.chapterToEdit?.content ?? "",
    );
    _isDraft = widget.chapterToEdit?.isDraft ?? true;
    _updateWordCount(); // Başlangıçtaki kelime sayısı

    _contentController.addListener(_updateWordCount);
  }

  void _updateWordCount() {
    final text = _contentController.text.trim();
    if (text.isEmpty) {
      setState(() => _wordCount = 0);
    } else {
      setState(() {
        _wordCount = text.split(RegExp(r'\s+')).length;
      });
    }
  }

  void _saveChapter() {
    if (_titleController.text.isEmpty) return;

    final newChapter = Chapter(
      title: _titleController.text,
      content: _contentController.text,
      isDraft: _isDraft,
    );

    setState(() {
      if (widget.chapterToEdit != null && widget.chapterIndex != null) {
        // VAR OLAN BÖLÜMÜ GÜNCELLE
        widget.book.chapters[widget.chapterIndex!] = newChapter;
      } else {
        // YENİ BÖLÜM EKLE
        widget.book.chapters.add(newChapter);
      }
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title, style: const TextStyle(fontSize: 14)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          Row(
            children: [
              Text(
                _isDraft ? "Taslak" : "Yayında",
                style: TextStyle(
                  color: _isDraft ? Colors.grey : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: !_isDraft,
                onChanged: (val) => setState(() => _isDraft = !val),
                activeColor: AppColors.primary,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.primary),
            onPressed: _saveChapter,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: "Bölüm Başlığı...",
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: TextField(
              controller: _contentController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(16),
                hintText: "Hikayeni yazmaya başla...",
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [Text("$_wordCount kelime")],
            ),
          ),
        ],
      ),
    );
  }
}
