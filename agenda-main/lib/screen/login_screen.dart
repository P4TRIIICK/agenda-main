import 'package:flutter/material.dart';
import 'package:agenda/services/auth_service.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
// Importe o utils:
import 'package:agenda/utils/login_utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Tenta login com contagem de tentativas
    final result = await LoginUtils.attemptLogin(
      _email.text.trim(),
      _password.text.trim(),
    );

    if (result == null) {
      // Login deu certo. Navegar ou fechar tela
      // Navigator.pushReplacement(...), etc.
      // Se não fizer nada, só fica na tela
    } else {
      // Exibir a mensagem de erro/bloqueio
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsividade
    final size = MediaQuery.of(context).size;
    final verticalSpacing = size.height * 0.02;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.height,
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Espaço inicial ou logo
              SizedBox(height: verticalSpacing * 2),

              // Título
              Text(
                "Bem-Vindo",
                style: TextStyle(
                  fontSize: size.height * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: verticalSpacing),
              Text(
                "Coloque suas credenciais para entrar",
                style: TextStyle(fontSize: size.height * 0.02),
              ),

              SizedBox(height: verticalSpacing * 2),

              _buildTextField(
                controller: _email,
                hint: "Email",
                icon: Icons.person,
                size: size,
              ),
              SizedBox(height: verticalSpacing),
              _buildTextField(
                controller: _password,
                hint: "Senha",
                icon: Icons.lock,
                obscure: true,
                size: size,
              ),
              SizedBox(height: verticalSpacing * 2),

              // Botão de login
              Center(
                child: SizedBox(
                  width: size.width * 0.5,
                  height: size.height * 0.07,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(fontSize: size.height * 0.025),
                    ),
                  ),
                ),
              ),

              SizedBox(height: verticalSpacing * 1.5),

              // Esqueceu a senha centralizado
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ForgotPasswordPage()),
                    );
                  },
                  child: Text(
                    "Esqueceu a senha?",
                    style: TextStyle(fontSize: size.height * 0.018),
                  ),
                ),
              ),

              // Em vez de Spacer(), adicionamos um espaço “fixo”
              SizedBox(height: verticalSpacing),

              // Botão de cadastro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Não tem uma conta?",
                    style: TextStyle(fontSize: size.height * 0.02),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    child: Text(
                      "Cadastre-se",
                      style: TextStyle(
                        fontSize: size.height * 0.02,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: verticalSpacing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    required Size size,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        fillColor: Colors.blueAccent.withOpacity(0.1),
        filled: true,
        prefixIcon: Icon(icon),
      ),
      style: TextStyle(fontSize: size.height * 0.022),
    );
  }
}
