import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/book_service.dart';
import '../../core/auth_service.dart';
import '../../models/book_model.dart';

class AddBookScreen extends StatefulWidget {
  final Book? bookToEdit;
  const AddBookScreen({super.key, this.bookToEdit});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _imageUrlController;

  // Kategori Listesi
  final List<String> _categories = [
    'Genel',
    'Roman',
    'Klasik',
    'Bilim Kurgu',
    'Fantezi',
    'Şiir',
    'Tarih',
    'Kişisel Gelişim',
  ];
  String _selectedCategory = 'Genel';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.bookToEdit?.title ?? "",
    );
    _descController = TextEditingController(
      text: widget.bookToEdit?.description ?? "",
    );
    _imageUrlController = TextEditingController(
      text: widget.bookToEdit?.imageUrl ?? "",
    );

    // Düzenleme modundaysak mevcut kategoriyi seç
    if (widget.bookToEdit != null &&
        _categories.contains(widget.bookToEdit!.category)) {
      _selectedCategory = widget.bookToEdit!.category;
    }
  }

  void _saveStory() {
    if (_formKey.currentState!.validate()) {
      final bookService = Provider.of<BookService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final String currentOwner = authService.currentUserEmail ?? "anonymous";

      if (widget.bookToEdit == null) {
        final newBook = Book(
          id: DateTime.now().toString(),
          title: _titleController.text,
          author: "Yazar: ${currentOwner.split('@')[0]}",
          ownerId: currentOwner,
          description: _descController.text,
          imageUrl: _imageUrlController.text.isNotEmpty
              ? _imageUrlController.text
              : null,
          chapters: [],
          isPublished: false,
          category: _selectedCategory, // Seçilen kategori
        );
        bookService.addBook(newBook);
      } else {
        final updatedBook = Book(
          id: widget.bookToEdit!.id,
          title: _titleController.text,
          author: widget.bookToEdit!.author,
          ownerId: widget.bookToEdit!.ownerId,
          description: _descController.text,
          imageUrl: _imageUrlController.text.isNotEmpty
              ? _imageUrlController.text
              : null,
          chapters: widget.bookToEdit!.chapters,
          isPublished: widget.bookToEdit!.isPublished,
          category: _selectedCategory, // Seçilen kategori
        );
        bookService.updateBook(widget.bookToEdit!, updatedBook);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentImage = _imageUrlController.text;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.bookToEdit == null ? "Yeni Hikaye" : "Hikaye Düzenle",
        ),
        actions: [
          TextButton(
            onPressed: _saveStory,
            child: const Text(
              "KAYDET",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kapak Resmi Alanı (Değişmedi)
              Center(
                child: Container(
                  height: 200,
                  width: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ],
                    image: currentImage.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(currentImage),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: currentImage.isEmpty
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, color: Colors.grey),
                            Text("Kapak", style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: "Kapak Linki",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                onChanged: (val) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // KATEGORİ SEÇİMİ (YENİ)
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Tür / Kategori",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _titleController,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: "Hikaye Başlığı",
                  border: InputBorder.none,
                ),
                validator: (v) => v!.isEmpty ? "Başlık gerekli" : null,
              ),
              const Divider(),
              TextFormField(
                controller: _descController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "Konusu ne?",
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
