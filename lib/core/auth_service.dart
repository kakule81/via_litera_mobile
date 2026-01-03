import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "Success"; // Başarılı
    } on FirebaseAuthException catch (e) {
      return e.message; // Hata mesajını döndür (Örn: Şifre yanlış)
    } catch (e) {
      return "Bilinmeyen bir hata oluştu.";
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Kayıt hatası oluştu.";
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
