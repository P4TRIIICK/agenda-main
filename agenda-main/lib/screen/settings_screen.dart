import 'package:flutter/material.dart';
import 'package:agenda/services/auth_service.dart';
// Se for salvar o horário em SharedPreferences, importar:
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _auth = AuthService();  // Se você tiver um AuthService para logout

  TimeOfDay? _selectedTime;     // Hora escolhida
  bool _isLoadingTime = true;   // Para indicar se estamos carregando a hora

  @override
  void initState() {
    super.initState();
    _loadPreferredTime(); // Carrega horário salvo
  }

  Future<void> _loadPreferredTime() async {
    // Exemplo: salvamos no SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('preferred_hour');
    final minute = prefs.getInt('preferred_minute');

    if (hour != null && minute != null) {
      setState(() {
        _selectedTime = TimeOfDay(hour: hour, minute: minute);
      });
    }
    setState(() {
      _isLoadingTime = false;
    });
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? now,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);

      // Salva no SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('preferred_hour', picked.hour);
      await prefs.setInt('preferred_minute', picked.minute);
    }
  }

  Future<void> _logout() async {
    // Chama logout do AuthService
    await _auth.signout(); // ou signOut(), conforme seu método
    // Agora decide para onde vai redirecionar após logout:
    // Se você tem Wrapper, pode usar pushReplacement
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/'); 
    // ou se quiser mandar direto pra LoginPage: 
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Configurações"),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        // Distribui os elementos entre o topo e a base
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Parte superior: configurações de horário
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: const Text("Horário preferencial"),
                subtitle: _isLoadingTime
                    ? const Text("Carregando...")
                    : Text(
                        _selectedTime == null
                            ? "Nenhum horário escolhido"
                            : "${_selectedTime!.hour.toString().padLeft(2, '0')}"
                              ":${_selectedTime!.minute.toString().padLeft(2, '0')}",
                      ),
                trailing: const Icon(Icons.access_time),
                onTap: _pickTime,
              ),
              // Você pode incluir outras configurações aqui
            ],
          ),

          // Botão de logout na base
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50), 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

}
