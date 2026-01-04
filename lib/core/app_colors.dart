import 'package:flutter/material.dart';

class AppColors {
  // --- SENİN PALETİN (Özel İsimlendirmeler) ---
  static const Color darkCoffee = Color(0xFF260502); // En koyu (Ana renk)
  static const Color bronze = Color(0xFF8C5F45); // Orta kahve
  static const Color terraCotta = Color(0xFFD9946C); // Turuncumsu (Canlı)
  static const Color steelBlue = Color(0xFF9FB0BF); // Mavi gri (Soğuk geçiş)
  static const Color softPink = Color(0xFFD99B96); // Açık ton

  // --- UYGULAMA GENELİNE ATAMALAR ---

  // Ana Başlıklar, AppBar ve Temel Butonlar
  static const Color primary = darkCoffee;

  // İkincil Butonlar, Seçili Olmayan Öğeler
  static const Color secondary = bronze;

  // "Kitap Ekle" butonu, Switch'ler, Önemli Uyarılar (Dikkat çekici olmalı)
  static const Color accent = terraCotta;

  // Genel Arka Plan (Okuma kolaylığı için çok hafif kırık beyaz)
  static const Color background = Color(0xFFFAFAFA);

  // Yazılar (Okunabilirlik için ana koyu rengi kullanıyoruz)
  static const Color text = darkCoffee;

  // Pasif metinler (Yazar adı vb.)
  static const Color textLight = Colors.grey;
}
