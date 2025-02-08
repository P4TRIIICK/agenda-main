import 'package:flutter/material.dart';
import 'package:agenda/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  return Scaffold(
    appBar: AppBar(
      title: const Text("Configurações"),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
            ],
          ),

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
