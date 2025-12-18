import 'package:flutter/material.dart';
import '../helper/api.dart';
import 'user_form.dart';
import 'user_edit.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  bool loading = true;

  List<User> admins = [];
  List<User> dokters = [];
  List<User> pasiens = [];

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    fetchUsers();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchUsers() async {
    setState(() => loading = true);
    try {
      final users = await API.user.list();
      admins = users.where((u) => u.roleId == 1).toList();
      dokters = users.where((u) => u.roleId == 2).toList();
      pasiens = users.where((u) => u.roleId == 3).toList();
      _animationController.forward(from: 0);
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> deleteUser(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus User"),
        content: Text("Yakin hapus ${user.nama}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await API.user.delete(user.id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User berhasil dihapus")),
      );

      fetchUsers();
    } catch (e) {
      debugPrint("❌ Delete error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menghapus user")),
      );
    }
  }

  Color _roleColor(int roleId) {
    if (roleId == 1) return Colors.red.shade400;
    if (roleId == 2) return Colors.blue.shade400;
    if (roleId == 3) return Colors.green.shade400;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Management"),
        backgroundColor: const Color(0xFF1565C0),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.add),
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserFormScreen()),
          );
          if (res == true) fetchUsers();
        },
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchUsers,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _section("Admin", admins),
                  _section("Dokter", dokters),
                  _section("Pasien", pasiens),
                ],
              ),
            ),
    );
  }

  Widget _section(String title, List<User> users) {
    if (users.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...users.asMap().entries.map((entry) {
          final index = entry.key;
          final user = entry.value;
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final value =
                  (_animationController.value - index * 0.1).clamp(0.0, 1.0);
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 50 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: Colors.black.withOpacity(0.2),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _roleColor(user.roleId),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                title: Text(user.nama,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: _buildSubtitle(user),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == "edit") {
                      final res = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserEditScreen(user: user),
                        ),
                      );
                      if (res == true) fetchUsers();
                    }
                    if (value == "delete") await deleteUser(user);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: "edit", child: Text("Edit")),
                    PopupMenuItem(
                        value: "delete",
                        child: Text("Hapus",
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSubtitle(User user) {
    String subtitle = user.email ?? "-";
    if (user.roleId == 2 && user.dokter != null) {
      subtitle += " • ${user.dokter!['spesialis'] ?? '-'}";
    }
    if (user.roleId == 3 && user.pasien != null) {
      subtitle += " • ${user.pasien!['no_hp'] ?? '-'}";
    }
    return Text(subtitle);
  }
}
