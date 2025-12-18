import 'package:flutter/material.dart';
import '../helper/api.dart';

class UserFormScreen extends StatefulWidget {
  const UserFormScreen({super.key});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();

  int? roleId; // 2 = dokter, 3 = pasien
  bool loading = false;

  final namaCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  // ================= PASIEN =================
  final nikCtrl = TextEditingController();
  final noHpCtrl = TextEditingController();
  final alamatCtrl = TextEditingController();
  DateTime? tanggalLahir;

  // ================= DOKTER =================
  final noStrCtrl = TextEditingController();
  final spesialisCtrl = TextEditingController();

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (roleId == null) return;

    setState(() => loading = true);

    try {
      if (roleId == 3) {
        // ================= CREATE PASIEN =================
        await API.user.createPasien(
          nama: namaCtrl.text,
          nik: nikCtrl.text,
          tanggalLahir:
              tanggalLahir!.toIso8601String().split('T')[0],
          noHp: noHpCtrl.text,
          alamat: alamatCtrl.text,
          email: emailCtrl.text.isEmpty ? null : emailCtrl.text,
        );
      }

      if (roleId == 2) {
        // ================= CREATE DOKTER =================
        await API.user.createDokter(
          nama: namaCtrl.text,
          noStr: noStrCtrl.text,
          spesialis:
              spesialisCtrl.text.isEmpty ? null : spesialisCtrl.text,
          email: emailCtrl.text.isEmpty ? null : emailCtrl.text,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("❌ Create user error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan user")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah User")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ================= ROLE =================
            DropdownButtonFormField<int>(
              value: roleId,
              decoration: const InputDecoration(
                labelText: "Role",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 2, child: Text("Dokter")),
                DropdownMenuItem(value: 3, child: Text("Pasien")),
              ],
              onChanged: (v) => setState(() => roleId = v),
              validator: (v) =>
                  v == null ? "Role wajib dipilih" : null,
            ),

            const SizedBox(height: 16),

            if (roleId != null) ...[
              _input(
                namaCtrl,
                "Nama",
                required: true,
              ),
              _input(
                emailCtrl,
                "Email (opsional)",
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 12),

              // ================= PASIEN =================
              if (roleId == 3) ...[
                _section("Data Pasien"),
                _input(nikCtrl, "NIK", required: true),
                _datePicker(context),
                _input(noHpCtrl, "No HP", required: true),
                _input(
                  alamatCtrl,
                  "Alamat",
                  required: true,
                  maxLines: 3,
                ),
              ],

              // ================= DOKTER =================
              if (roleId == 2) ...[
                _section("Data Dokter"),
                _input(noStrCtrl, "No STR", required: true),
                _input(spesialisCtrl, "Spesialis"),
              ],

              const SizedBox(height: 24),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: loading ? null : submit,
                  child: loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text("Simpan"),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  // ================= UI COMPONENT =================

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController c,
    String label, {
    bool required = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (v) => v == null || v.isEmpty
                ? "$label wajib diisi"
                : null
            : null,
      ),
    );
  }

  Widget _datePicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime(2000),
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setState(() => tanggalLahir = picked);
          }
        },
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: "Tanggal Lahir",
            border: OutlineInputBorder(),
          ),
          child: Text(
            tanggalLahir == null
                ? "Pilih tanggal"
                : tanggalLahir!
                    .toIso8601String()
                    .split('T')[0],
          ),
        ),
      ),
    );
  }
}
