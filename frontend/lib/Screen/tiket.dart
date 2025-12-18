import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helper/api.dart';

class TiketScreen extends StatelessWidget {
  final JanjiKonsultasi tiket;

  const TiketScreen({super.key, required this.tiket});

  @override
  Widget build(BuildContext context) {
    final tanggal =
        DateFormat('dd MMM yyyy').format(DateTime.parse(tiket.tanggal));

    return Scaffold(
      appBar: AppBar(title: const Text("Tiket Konsultasi")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Kode Tiket"),
                const SizedBox(height: 4),
                Text(
                  tiket.kodeTiket,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Divider(height: 32),

                Text("Tanggal Janji: $tanggal"),
                const SizedBox(height: 8),
                Text("Status: ${tiket.status}"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
