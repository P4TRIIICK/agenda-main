// lib/utils/register_utils.dart
import 'package:firebase_auth/firebase_auth.dart';

class RegisterUtils {
  static Future<String?> attemptRegister(String name, String email, String pass) async {
    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      return "Preencha todos os campos!";
    }

    final signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    if (signInMethods.isNotEmpty) {
      return "Este e-mail já está em uso!";
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return "Sua senha é muito fraca.";
        case 'email-already-in-use':
          return "Este e-mail já está em uso.";
        case 'invalid-email':
          return "E-mail inválido.";
        default:
          return e.message ?? "Erro ao criar conta.";
      }
    } catch (e) {
      return "Ocorreu um erro. Tente novamente.";
    }
  }
}
