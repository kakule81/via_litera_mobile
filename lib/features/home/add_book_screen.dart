import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/app_colors.dart';
import '../../core/book_service.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _tagsController = TextEditingController();

  // Varsayılan değerler
  String _selectedCategory = 'Genel';
  bool _isPublished = false; // Başlangıçta Taslak olsun
  final _bookService = BookService();

  final List<String> _categories = [
    'Genel',
    'Bilim Kurgu',
    'Fantastik',
    'Romantik',
    'Macera',
    'Korku',
    'Polisiye',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Yeni Kitap Tasarla",
          style: TextStyle(color: AppColors.textDark),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Kitap Adı
            _buildLabel("Kitap Adı"),
            TextField(
              controller: _titleController,
              decoration: _inputDeco("Örn: Zamanın Ötesinde"),
            ),
            const SizedBox(height: 20),

            // 2. Kategori Seçimi
            _buildLabel("Tür / Kategori"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items: _categories.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Açıklama / Arka Kapak Yazısı
            _buildLabel("Kitap Açıklaması (Özet)"),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: _inputDeco("Okuyucuyu çekecek kısa bir özet..."),
            ),
            const SizedBox(height: 20),

            // 4. Anahtar Kelimeler
            _buildLabel("Etiketler (Virgülle ayırın)"),
            TextField(
              controller: _tagsController,
              decoration: _inputDeco("büyü, uzay, aşk, gizem"),
            ),
            const SizedBox(height: 20),

            // 5. Yayın Durumu (Switch)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isPublished
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isPublished ? AppColors.primary : Colors.grey,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isPublished ? "Durum: YAYINDA 🚀" : "Durum: TASLAK 📝",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _isPublished
                          ? AppColors.primary
                          : Colors.grey[700],
                    ),
                  ),
                  Switch(
                    value: _isPublished,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _isPublished = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 6. OLUŞTUR BUTONU
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Kitabı Oluştur ve Yazmaya Başla",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Yardımcı Tasarım Fonksiyonları
  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
    ),
  );

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade400),
    ),
  );

  void _saveBook() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Başlık ve Açıklama zorunludur")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final result = await _bookService.createBook(
      title: title,
      description: desc,
      imageUrl: "", // Şimdilik boş, sonra ekleriz
      category: _selectedCategory,
      tags: _tagsController.text.trim(),
      isPublished: _isPublished,
      uid: user.uid,
    );

    if (result == "Success") {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Kitap oluşturuldu!")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result ?? "Hata")));
    }
  }
}
