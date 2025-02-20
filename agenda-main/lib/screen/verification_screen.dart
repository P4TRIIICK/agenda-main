import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:agenda/services/auth_service.dart';
import 'package:agenda/screen/login_screen.dart'; // Se quiser voltar para login

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({Key? key}) : super(key: key);

  @override
  EmailVerificationPageState createState() => EmailVerificationPageState();
}

class EmailVerificationPageState extends State<EmailVerificationPage> {
  final _auth = AuthService();
  bool isEmailVerified = false;
  bool _isLoading = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Opcional: Envia e-mail de verificação se não estiver verificado
    _sendVerificationEmail();

    // Opcional: iniciar um timer que checa se o email foi verificado a cada X segundos
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        setState(() => isEmailVerified = true);
        timer.cancel(); 
        // Se quiser, navega para a Home ou Wrapper
        Navigator.pushReplacementNamed(context, '/'); 
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _sendVerificationEmail() async {
    setState(() => _isLoading = true);
    try {
      await _auth.sendEmailVerificationLink();
    } catch (e) {
      debugPrint("Erro ao enviar e-mail de verificação: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final verticalSpacing = size.height * 0.02;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verificação de E-mail"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
        child: SizedBox(
          width: size.width,
          height: size.height * 0.9, // 90% da tela (ajuste se quiser)
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Verifique seu e-mail",
                style: TextStyle(
                  fontSize: size.height * 0.03,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: verticalSpacing),
              Text(
                "Enviamos um e-mail de verificação para o endereço fornecido. "
                "Por favor, verifique sua caixa de entrada (e também a pasta de spam).",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: size.height * 0.02),
              ),
              SizedBox(height: verticalSpacing * 2),

              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _sendVerificationEmail,
                      child: Text(
                        "Reenviar E-mail",
                        style: TextStyle(fontSize: size.height * 0.022),
                      ),
                    ),
              SizedBox(height: verticalSpacing * 2),

              // Botão para voltar ao login
              TextButton(
                onPressed: () {
                  // Se quiser voltar para a LoginPage
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                },
                child: Text(
                  "Voltar para Login",
                  style: TextStyle(fontSize: size.height * 0.02, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
