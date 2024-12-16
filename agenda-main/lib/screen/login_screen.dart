import 'package:agenda/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'forgot_password_screen.dart'; // Importando a tela de recuperação de senha
import 'register_screen.dart'; // Importando a tela de cadastro

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores de texto para email e senha
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();

  // Dispose para limpar os controladores quando o widget for destruído
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView( // Permite rolar o conteúdo
          child: Container(
            margin: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(height: 50),
                _header(context),
                const SizedBox(height: 50),
                _inputField(context),
                _forgotPassword(context),
                const SizedBox(height: 50),
                _signup(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _header(context) {
    return const Column(
      children: [
        Text(
          "Bem-Vindo",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text("Coloque suas credenciais para entrar"),
      ],
    );
  }

  _inputField(context) {
    return Column(
      children: [
        TextField(
          controller: _email,
          decoration: InputDecoration(
            hintText: "Email",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _password,
          decoration: InputDecoration(
            hintText: "Senha",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.lock),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: 250,
          child: ElevatedButton(
            onPressed: () => _login(), 
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 10),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              "Login",
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }

  _forgotPassword(context) {
    return TextButton(
      onPressed: () {
        // Redireciona para a tela de recuperação de senha
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
        );
      },
      child: const Text("Esqueceu a senha?", style: TextStyle(color: Colors.blue)),
    );
  }

  _signup(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Não tem uma conta?"),
        TextButton(
          onPressed: () {
            // Redireciona para a tela de cadastro
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterPage()),
            );
          },
          child: const Text("Cadastre-se", style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }

  _login() async{
    await _auth.loginUserWithEmailAndPassword(_email.text, _password.text);
  }
}
