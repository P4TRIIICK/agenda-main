import 'package:flutter/material.dart';
import 'package:agenda/services/auth_service.dart';
import 'package:agenda/services/wrapper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = AuthService();

  // Controladores de texto
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    setState(() => _isLoading = true);
    try {
      final user = await _auth.createUserWithEmailAndPassword(
        _email.text.trim(),
        _password.text.trim(),
      );

      if (user != null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Wrapper()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao criar conta.")),
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
      appBar: AppBar(title: const Text("Cadastro")),
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.height,
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // Removi mainAxisAlignment.center para não centralizar verticalmente
            children: [
              // Espaço inicial do topo
              SizedBox(height: verticalSpacing * 2),

              Text(
                "Crie sua conta",
                style: TextStyle(
                  fontSize: size.height * 0.035,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: verticalSpacing),

              _buildTextField(
                controller: _name,
                label: "Nome",
                size: size,
              ),
              SizedBox(height: verticalSpacing),

              _buildTextField(
                controller: _email,
                label: "E-mail",
                size: size,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: verticalSpacing),

              _buildTextField(
                controller: _password,
                label: "Senha",
                obscure: true,
                size: size,
              ),
              SizedBox(height: verticalSpacing * 2),

              // Botão de Cadastrar
              Center(
                child: SizedBox(
                  width: size.width * 0.5,
                  height: size.height * 0.07,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signup,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Cadastrar",
                            style: TextStyle(fontSize: size.height * 0.025),
                          ),
                  ),
                ),
              ),
              SizedBox(height: verticalSpacing * 0.5),

              // Botão "Já tem conta?"
              Center(
                child: SizedBox(
                  width: size.width * 0.5,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Já tem uma conta? Faça Login",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: size.height * 0.015,
                      ),
                    ),
                  ),
                ),
              ),

              // Espaço final
              SizedBox(height: verticalSpacing * 2),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para campo de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required Size size,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: size.height * 0.022,
          color: Colors.grey[700],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      style: TextStyle(fontSize: size.height * 0.022),
    );
  }
}
