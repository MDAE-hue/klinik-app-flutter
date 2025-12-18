import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'user_management.dart';
import 'jadwal.dart';
import 'janji.dart';
import 'setting.dart';

class TabsScreen extends StatefulWidget {
  final int roleId;

  const TabsScreen({super.key, required this.roleId});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _currentIndex = 1;

  late final List<Widget> _pages;
  late final List<BottomNavigationBarItem> _tabs;

  static const Color primaryBlue = Color(0xFF1565C0);

  @override
  void initState() {
    super.initState();

    // ======================
    // ROLE BASED TAB
    // ======================
    if (widget.roleId == 3) {
      // PASIEN
      _pages = [
        JadwalScreen(roleId: widget.roleId),
        const DashboardScreen(), 
        const JanjiScreen(),
        const SettingsScreen(),
      ];

      _tabs = const [
        BottomNavigationBarItem(icon: Icon(Icons.schedule), label: "Jadwal"),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Janji"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Setting"),
      ];
    } else if (widget.roleId == 2) {
      // DOKTER
      _pages = [
        JadwalScreen(roleId: widget.roleId),
        const DashboardScreen(),
        const SettingsScreen(),
      ];

      _tabs = const [
        BottomNavigationBarItem(icon: Icon(Icons.schedule), label: "Jadwal"),
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Setting"),
      ];
    } else {
      // ADMIN
      _pages = [
        JadwalScreen(roleId: widget.roleId), // 🔥 JADWAL (CRUD)
        const DashboardScreen(),
        const UserManagementScreen(),
        const SettingsScreen(),
      ];

      _tabs = const [
        BottomNavigationBarItem(icon: Icon(Icons.schedule), label: "Jadwal"),
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.manage_accounts), label: "User"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Setting"),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text("Klinik App"),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _currentIndex = i),
        items: _tabs,
      ),
    );
  }
}
