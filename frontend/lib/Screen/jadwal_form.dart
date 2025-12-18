import 'package:flutter/material.dart';
import '../helper/api.dart';

class JadwalFormScreen extends StatefulWidget {
  final JadwalDokter? jadwal;

  const JadwalFormScreen({super.key, this.jadwal});

  @override
  State<JadwalFormScreen> createState() => _JadwalFormScreenState();
}

class _JadwalFormScreenState extends State<JadwalFormScreen> {
  final formKey = GlobalKey<FormState>();

  final hariCtrl = TextEditingController();
  final jamMulaiCtrl = TextEditingController();
  final jamSelesaiCtrl = TextEditingController();
  final kuotaCtrl = TextEditingController(text: "20");

  int? dokterId;
  int? poliId;

  List dokterList = [];
  List poliList = [];

  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadDropdown();

    if (widget.jadwal != null) {
      hariCtrl.text = widget.jadwal!.hari;
      jamMulaiCtrl.text = widget.jadwal!.jamMulai;
      jamSelesaiCtrl.text = widget.jadwal!.jamSelesai;
      kuotaCtrl.text = widget.jadwal!.kuota.toString();
      dokterId = widget.jadwal!.dokterId;
      poliId = widget.jadwal!.poliId;
    }
  }

  Future<void> loadDropdown() async {
    final dokter = await API.dokter.getAll();
    final poli = await API.poli.getAll();

    setState(() {
      dokterList = dokter;
      poliList = poli;
    });
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      if (widget.jadwal == null) {
        await API.jadwalDokter.create(
          dokterId: dokterId!,
          poliId: poliId!,
          hari: hariCtrl.text,
          jamMulai: jamMulaiCtrl.text,
          jamSelesai: jamSelesaiCtrl.text,
          kuota: int.parse(kuotaCtrl.text),
        );
      } else {
        await API.jadwalDokter.update(
          widget.jadwal!.id,
          hari: hariCtrl.text,
          jamMulai: jamMulaiCtrl.text,
          jamSelesai: jamSelesaiCtrl.text,
          kuota: int.parse(kuotaCtrl.text),
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.jadwal != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Edit Jadwal" : "Tambah Jadwal")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: ListView(
            children: [

              // ================= DOKTER =================
              DropdownButtonFormField<int>(
                value: dokterId,
                items: dokterList.map<DropdownMenuItem<int>>((d) {
                  return DropdownMenuItem(
                    value: d['id'],
                    child: Text(d['nama']),
                  );
                }).toList(),
                onChanged: (v) => setState(() => dokterId = v),
                decoration: const InputDecoration(labelText: "Dokter"),
                validator: (v) => v == null ? "Pilih dokter" : null,
              ),

              // ================= POLI =================
              DropdownButtonFormField<int>(
                value: poliId,
                items: poliList.map<DropdownMenuItem<int>>((p) {
                  return DropdownMenuItem(
                    value: p['id'],
                    child: Text(p['nama_poli']),
                  );
                }).toList(),
                onChanged: (v) => setState(() => poliId = v),
                decoration: const InputDecoration(labelText: "Poli"),
                validator: (v) => v == null ? "Pilih poli" : null,
              ),

              TextFormField(
                controller: hariCtrl,
                decoration: const InputDecoration(labelText: "Hari"),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),

              TextFormField(
                controller: jamMulaiCtrl,
                decoration: const InputDecoration(labelText: "Jam Mulai (08:00)"),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),

              TextFormField(
                controller: jamSelesaiCtrl,
                decoration: const InputDecoration(labelText: "Jam Selesai (12:00)"),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),

              TextFormField(
                controller: kuotaCtrl,
                decoration: const InputDecoration(labelText: "Kuota"),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: loading ? null : submit,
                child: Text(loading ? "Menyimpan..." : "Simpan"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
