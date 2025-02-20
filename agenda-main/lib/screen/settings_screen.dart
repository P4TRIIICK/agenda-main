import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agenda/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _auth = AuthService();

  TimeOfDay? _selectedTime;
  bool _isLoadingTime = true;

  @override
  void initState() {
    super.initState();
    _loadPreferredTime();
  }

  Future<void> _loadPreferredTime() async {
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('preferred_hour', picked.hour);
      await prefs.setInt('preferred_minute', picked.minute);
    }
  }

  Future<void> _logout() async {
    await _auth.signout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final verticalSpacing = size.height * 0.02;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações"),
      ),
      // Aqui, sem SingleChildScrollView (pode usar se quiser rolagem)
      body: Container(
        // Se quiser ocupar a tela toda
        width: size.width,
        height: size.height,
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.08,
          vertical: verticalSpacing,
        ),
        child: Column(
          // Espaço entre topo e base
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Topo: cabeçalho e configurações
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ajuste suas preferências",
                  style: TextStyle(
                    fontSize: size.height * 0.028,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: verticalSpacing * 1.5),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    "Horário Preferencial",
                    style: TextStyle(fontSize: size.height * 0.022),
                  ),
                  subtitle: _isLoadingTime
                      ? const Text("Carregando...")
                      : Text(
                          _selectedTime == null
                              ? "Nenhum horário escolhido"
                              : "${_selectedTime!.hour.toString().padLeft(2, '0')}"
                                ":${_selectedTime!.minute.toString().padLeft(2, '0')}",
                          style: TextStyle(fontSize: size.height * 0.02),
                        ),
                  trailing:
                      Icon(Icons.access_time, size: size.height * 0.03),
                  onTap: _pickTime,
                ),
                // Se houver mais configurações, coloque aqui
              ],
            ),

            // Base: botão de logout
            SizedBox(
              width: double.infinity,
              height: size.height * 0.07,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: Icon(Icons.logout, size: size.height * 0.03),
                label: Text(
                  "Logout",
                  style: TextStyle(fontSize: size.height * 0.022),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
