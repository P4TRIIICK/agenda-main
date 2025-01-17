import 'package:flutter/material.dart';
import 'package:agenda/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // importar para capturar FirebaseAuthException

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _auth = AuthService();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendPasswordResetLink() async {
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    try {
      // Verifica se email existe
      final exists = await _auth.emailExists(email);
      if (!exists) {
        // Se não existe, exibe erro e não chama sendPasswordResetLink
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não encontrado!'), backgroundColor: Colors.red, ),
        );
      } else {
        // Se existe, manda o reset
        await _auth.sendPasswordResetLink(email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recuperação de senha iniciada!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao enviar e-mail de recuperação'), backgroundColor: Colors.red, ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recuperação de Senha"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Insira seu e-mail para recuperar a senha",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: "E-mail",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendPasswordResetLink,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Recuperar Senha"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
