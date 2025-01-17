import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class LoginUtils {
  static const String _attemptsKey = 'login_attempts';
  static const String _lockoutUntilKey = 'lockout_until';

  static const int maxAttempts = 7;

  static const int lockoutDurationMinutes = 20;

  static Future<String?> attemptLogin(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final now = DateTime.now().millisecondsSinceEpoch;
    final lockoutUntil = prefs.getInt(_lockoutUntilKey) ?? 0;

    if (now < lockoutUntil) {
      final diffMillis = lockoutUntil - now;
      final diffMinutes = (diffMillis / 1000 / 60).ceil();
      return 'Conta bloqueada. Tente novamente em $diffMinutes min.';
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _resetLoginAttempts(prefs);

      return null;
    } on FirebaseAuthException catch (e) {

      String msgErro = 'Erro ao fazer login. Verifique as credenciais.';

      if (e.code == 'user-not-found') {
        msgErro = 'Usuário não encontrado.';
      } else if (e.code == 'wrong-password') {
        msgErro = 'Senha incorreta.';
      } else if (e.code == 'invalid-email') {
        msgErro = 'E-mail inválido.';
      }

      final attempts = await _incrementLoginAttempts(prefs);

      if (attempts >= maxAttempts) {
        final lockoutUntil = DateTime.now().add(
          Duration(minutes: lockoutDurationMinutes),
        );
        await prefs.setInt(_lockoutUntilKey, lockoutUntil.millisecondsSinceEpoch);
        return 'Máximo de tentativas excedido. Tente novamente em $lockoutDurationMinutes min.';
      }

      return msgErro;
    } catch (e) {
      return 'Ocorreu um erro desconhecido ao fazer login.';
    }
  }

  static Future<int> _incrementLoginAttempts(SharedPreferences prefs) async {
    int currentAttempts = prefs.getInt(_attemptsKey) ?? 0;
    currentAttempts++;
    await prefs.setInt(_attemptsKey, currentAttempts);
    return currentAttempts;
  }

  static Future<void> _resetLoginAttempts(SharedPreferences prefs) async {
    await prefs.setInt(_attemptsKey, 0);
    await prefs.remove(_lockoutUntilKey);
  }
}
