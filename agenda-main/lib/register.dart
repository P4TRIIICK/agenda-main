import 'package:agenda/services/auth_service.dart';
import 'package:agenda/wrapper.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final _auth = AuthService();
  //final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastro")),
      body: SingleChildScrollView( // Adiciona a rolagem
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Text(
                "Crie sua conta",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const TextField(
                decoration:  InputDecoration(
                  hintText: "Nome",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _email,
                decoration: const InputDecoration(
                  hintText: "E-mail",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _password,
                decoration: const InputDecoration(
                  hintText: "Senha",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => _signup(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Cadastrar"),
                ),
              ),
              SizedBox(
                width: 200,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Já tem uma conta? Faça Login",
                    style: TextStyle(color: Colors.blue, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _signup(BuildContext context) async {
    await _auth.createUserWithEmailAndPassword( _email.text, _password.text);
    Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const Wrapper()));
  }
}
