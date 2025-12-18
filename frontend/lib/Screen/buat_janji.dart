import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helper/api.dart';
import 'tiket.dart';

class BuatJanjiScreen extends StatefulWidget {
  final JadwalDokter jadwal;

  const BuatJanjiScreen({super.key, required this.jadwal});

  @override
  State<BuatJanjiScreen> createState() => _BuatJanjiScreenState();
}

class _BuatJanjiScreenState extends State<BuatJanjiScreen> {
  final TextEditingController keluhanCtrl = TextEditingController();
  DateTime? tanggalJanji;
  bool loading = false;

  static const Color primaryBlue = Color(0xFF1565C0);

  Future<void> pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          primaryColor: primaryBlue,
          colorScheme: ColorScheme.light(primary: primaryBlue),
          buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => tanggalJanji = picked);
    }
  }

  Future<void> submit() async {
    if (tanggalJanji == null || keluhanCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tanggal & keluhan wajib diisi")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final tiket = await API.janji.create(
        jadwalDokterId: widget.jadwal.id,
        tanggal: tanggalJanji!,
        keluhan: keluhanCtrl.text,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TiketScreen(tiket: tiket),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesan Janji Konsultasi"),
        backgroundColor: primaryBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // =========================
            // INFO JADWAL DOKTER
            // =========================
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: Colors.black26,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.medical_services, size: 28, color: primaryBlue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.jadwal.dokter,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("Poli: ${widget.jadwal.poli}", style: const TextStyle(fontSize: 16)),
                    Text("Hari: ${widget.jadwal.hari}", style: const TextStyle(fontSize: 16)),
                    Text(
                      "Jam: ${widget.jadwal.jamMulai} - ${widget.jadwal.jamSelesai}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Kuota tersisa: ${widget.jadwal.kuota}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.jadwal.kuota > 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // PILIH TANGGAL
            // =========================
            GestureDetector(
              onTap: pilihTanggal,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.grey.shade100,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tanggalJanji == null
                          ? "Pilih Tanggal Janji"
                          : DateFormat('dd MMM yyyy').format(tanggalJanji!),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_month, color: primaryBlue),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // INPUT KELUHAN
            // =========================
            TextField(
              controller: keluhanCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Keluhan",
                labelStyle: const TextStyle(color: primaryBlue),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryBlue),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // BUTTON SUBMIT
            // =========================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  loading ? "Memproses..." : "Pesan Janji",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
