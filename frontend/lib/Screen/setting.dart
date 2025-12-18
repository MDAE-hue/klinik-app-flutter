import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const Color primaryBlue = Color(0xFF1565C0);

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengaturan"),
        backgroundColor: primaryBlue,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            shadowColor: Colors.black.withOpacity(0.2),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: primaryBlue,
                child: const Icon(Icons.logout, color: Colors.white),
              ),
              title: const Text(
                "Logout",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: const Text("Keluar dari akun saat ini"),
              trailing: const Icon(Icons.arrow_forward_ios, color: primaryBlue),
              onTap: () => _logout(context),
            ),
          ),
        ],
      ),
    );
  }
}
