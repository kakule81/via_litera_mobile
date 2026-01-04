import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/book_model.dart';

class ReadChapterScreen extends StatefulWidget {
  final String bookTitle;
  final Book book;
  final int initialChapterIndex;

  const ReadChapterScreen({
    super.key,
    required this.bookTitle,
    required this.book,
    required this.initialChapterIndex,
  });

  @override
  State<ReadChapterScreen> createState() => _ReadChapterScreenState();
}

class _ReadChapterScreenState extends State<ReadChapterScreen> {
  late int _currentIndex;
  late Chapter _currentChapter;

  double _fontSize = 18.0;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialChapterIndex;
    _currentChapter = widget.book.chapters[_currentIndex];
  }

  void _nextChapter() {
    if (_currentIndex < widget.book.chapters.length - 1) {
      setState(() {
        _currentIndex++;
        _currentChapter = widget.book.chapters[_currentIndex];
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _previousChapter() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _currentChapter = widget.book.chapters[_currentIndex];
      });
    }
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _isDarkMode ? const Color(0xFF333333) : Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Görünüm Ayarları",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tema",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _isDarkMode = false),
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: const Icon(
                            Icons.wb_sunny,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      GestureDetector(
                        onTap: () => setState(() => _isDarkMode = true),
                        child: const CircleAvatar(
                          backgroundColor: Colors.black,
                          child: Icon(
                            Icons.nightlight_round,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Yazı Boyutu",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() {
                          if (_fontSize > 12) _fontSize -= 2;
                        }),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        "${_fontSize.toInt()}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => setState(() {
                          if (_fontSize < 30) _fontSize += 2;
                        }),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode
        ? const Color(0xFF121212)
        : const Color(0xFFFFF8E1);
    final textColor = _isDarkMode
        ? const Color(0xFFE0E0E0)
        : const Color(0xFF333333);

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: bgColor,
            elevation: 0,
            iconTheme: IconThemeData(color: textColor),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentChapter.title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Bölüm ${_currentIndex + 1} / ${widget.book.chapters.length}",
                  style: TextStyle(
                    color: textColor.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: _showSettingsModal,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.bookTitle.toUpperCase(),
                    style: TextStyle(
                      color: textColor.withOpacity(0.5),
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _currentChapter.content,
                    style: TextStyle(
                      fontSize: _fontSize,
                      color: textColor,
                      height: 1.6,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _currentIndex > 0
                          ? TextButton.icon(
                              onPressed: _previousChapter,
                              icon: Icon(
                                Icons.arrow_back_ios,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              label: const Text(
                                "Önceki",
                                style: TextStyle(color: AppColors.primary),
                              ),
                            )
                          : const SizedBox(),
                      ElevatedButton.icon(
                        onPressed: _nextChapter,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        icon: _currentIndex < widget.book.chapters.length - 1
                            ? const Icon(Icons.arrow_forward_ios, size: 16)
                            : const Icon(Icons.check),
                        label: Text(
                          _currentIndex < widget.book.chapters.length - 1
                              ? "Sonraki Bölüm"
                              : "Bitir",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
