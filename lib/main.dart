import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/app_colors.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';
import 'core/auth_service.dart';
import 'core/book_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Web tarayıcısında "dart:io" veya veritabanı başlatıcıya gerek yoktur.
  // SharedPreferences web'de sorunsuz çalışır.

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => BookService()),
      ],
      child: MyApp(
        startScreen: isLoggedIn ? const HomeScreen() : const LoginScreen(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget startScreen;
  const MyApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Via Litera',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        useMaterial3: true,
        // Web'de fontların düzgün görünmesi için
        fontFamily: 'Roboto',
      ),
      home: startScreen,
    );
  }
}
