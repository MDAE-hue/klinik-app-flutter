import 'package:flutter/material.dart';
import '../helper/api.dart';

class UserEditScreen extends StatefulWidget {
  final User user;
  const UserEditScreen({super.key, required this.user});

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  bool loading = false;

  final namaCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  // pasien
  final nikCtrl = TextEditingController();
  final noHpCtrl = TextEditingController();
  final alamatCtrl = TextEditingController();
  DateTime? tanggalLahir;

  // dokter
  final noStrCtrl = TextEditingController();
  final spesialisCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final u = widget.user;

    namaCtrl.text = u.nama;
    emailCtrl.text = u.email ?? "";

    if (u.roleId == 3 && u.pasien != null) {
      nikCtrl.text = u.pasien!['nik'] ?? "";
      noHpCtrl.text = u.pasien!['no_hp'] ?? "";
      alamatCtrl.text = u.pasien!['alamat'] ?? "";
      if (u.pasien!['tanggal_lahir'] != null) {
        tanggalLahir = DateTime.parse(u.pasien!['tanggal_lahir']);
      }
    }

    if (u.roleId == 2 && u.dokter != null) {
      noStrCtrl.text = u.dokter!['no_str'] ?? "";
      spesialisCtrl.text = u.dokter!['spesialis'] ?? "";
    }
  }

  Future<void> submit() async {
    setState(() => loading = true);

    await API.user.update(
      widget.user.id,
      nama: namaCtrl.text,
      email: emailCtrl.text.isEmpty ? null : emailCtrl.text,
      nik: nikCtrl.text.isEmpty ? null : nikCtrl.text,
      noHp: noHpCtrl.text.isEmpty ? null : noHpCtrl.text,
      alamat: alamatCtrl.text.isEmpty ? null : alamatCtrl.text,
      tanggalLahir: tanggalLahir?.toIso8601String().split('T')[0],
      noStr: noStrCtrl.text.isEmpty ? null : noStrCtrl.text,
      spesialis: spesialisCtrl.text.isEmpty ? null : spesialisCtrl.text,
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final roleId = widget.user.roleId;

    return Scaffold(
      appBar: AppBar(title: const Text("Edit User")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _input(namaCtrl, "Nama"),
          _input(emailCtrl, "Email"),

          if (roleId == 3) ...[
            _input(nikCtrl, "NIK"),
            _datePicker(context),
            _input(noHpCtrl, "No HP"),
            _input(alamatCtrl, "Alamat"),
          ],

          if (roleId == 2) ...[
            _input(noStrCtrl, "No STR"),
            _input(spesialisCtrl, "Spesialis"),
          ],

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: loading ? null : submit,
            child: loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Simpan Perubahan"),
          )
        ],
      ),
    );
  }

  Widget _input(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _datePicker(BuildContext context) {
    return ListTile(
      title: const Text("Tanggal Lahir"),
      subtitle: Text(
        tanggalLahir == null
            ? "-"
            : tanggalLahir!.toIso8601String().split('T')[0],
      ),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: tanggalLahir ?? DateTime(2000),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() => tanggalLahir = picked);
        }
      },
    );
  }
}
