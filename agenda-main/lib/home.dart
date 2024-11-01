import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  Future<void> _checkOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final showOnboarding = prefs.getBool("onboarding") ?? true;

    if (showOnboarding) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(""
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text("Login"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text("Cadastrar"),
            ),
          ],
        ),
      ),
    );
  }
}
