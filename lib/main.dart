import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/app_colors.dart';
import 'features/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase'i uyandır
  runApp(const ViaLiteraApp());
}

class ViaLiteraApp extends StatelessWidget {
  const ViaLiteraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Via Litera',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const LoginScreen(), // Açılış kapısı
    );
  }
}
