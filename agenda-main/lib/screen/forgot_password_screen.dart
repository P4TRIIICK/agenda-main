import 'package:flutter/material.dart';
import 'package:agenda/services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

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

  Future<void> _sendPasswordResetLink() async {
    setState(() => _isLoading = true);
    try {
      await _auth.sendPasswordResetLink(_emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recuperação de senha iniciada!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao enviar e-mail de recuperação')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsividade
    final size = MediaQuery.of(context).size;
    final verticalSpacing = size.height * 0.02;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recuperação de Senha"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.08,
          vertical: verticalSpacing,
        ),
        // Em vez de usar SizedBox(height: size.height * 0.9), deixamos somente
        // o Column crescer livremente no ScrollView, para que o conteúdo fique
        // mais perto do topo.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Espaço inicial opcional
            SizedBox(height: verticalSpacing * 2),

            Text(
              "Insira seu e-mail para recuperar a senha",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: size.height * 0.025,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: verticalSpacing * 2),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: "E-mail",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              style: TextStyle(fontSize: size.height * 0.02),
            ),
            SizedBox(height: verticalSpacing * 2),

            Center(
              child: SizedBox(
                width: size.width * 0.5, 
                height: size.height * 0.07,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendPasswordResetLink,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          "Recuperar Senha",
                          style: TextStyle(fontSize: size.height * 0.022),
                        ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
