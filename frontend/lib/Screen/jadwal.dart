import 'package:flutter/material.dart';
import '../helper/api.dart';
import 'jadwal_form.dart';
import 'buat_janji.dart';

class JadwalScreen extends StatefulWidget {
  final int roleId;

  const JadwalScreen({super.key, required this.roleId});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  bool loading = true;
  List<JadwalDokter> jadwal = [];

  @override
  void initState() {
    super.initState();
    fetchJadwal();
  }

  Future<void> fetchJadwal() async {
    setState(() => loading = true);
    try {
      jadwal = await API.jadwalDokter.list();
    } catch (e) {
      debugPrint("❌ Fetch jadwal error: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> deleteJadwal(int id) async {
    await API.jadwalDokter.delete(id);
    fetchJadwal();
  }

  Color getCardColor(int index) {
    final colors = [Colors.blue[50], Colors.blue[100]];
    return colors[index % colors.length]!;
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.roleId == 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Jadwal Dokter"),
        backgroundColor: const Color(0xFF1565C0),
        centerTitle: true,
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF1565C0),
              child: const Icon(Icons.add),
              onPressed: () async {
                final res = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const JadwalFormScreen(),
                  ),
                );
                if (res == true) fetchJadwal();
              },
            )
          : null,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchJadwal,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: jadwal.length,
                itemBuilder: (_, i) {
                  final j = jadwal[i];

                  // ================================
                  // TweenAnimationBuilder aman
                  // ================================
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 300 + i * 100),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 50 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Card(
                      color: getCardColor(i),
                      elevation: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadowColor: Colors.black.withOpacity(0.2),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        title: Text(
                          "${j.dokter} • ${j.poli}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                          "${j.hari}, ${j.jamMulai} - ${j.jamSelesai}\nKuota: ${j.kuota}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        isThreeLine: true,
                        trailing: isAdmin
                            ? PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    final res = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            JadwalFormScreen(jadwal: j),
                                      ),
                                    );
                                    if (res == true) fetchJadwal();
                                  }
                                  if (value == 'delete') {
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text("Hapus Jadwal"),
                                        content: const Text(
                                            "Yakin ingin menghapus jadwal ini?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text("Batal"),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF1565C0),
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text("Hapus"),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (ok == true) deleteJadwal(j.id);
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                      value: 'edit', child: Text("Edit")),
                                  PopupMenuItem(
                                      value: 'delete', child: Text("Hapus")),
                                ],
                              )
                            : const Icon(Icons.arrow_forward_ios,
                                size: 16, color: Color(0xFF1565C0)),
                        onTap: isAdmin
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BuatJanjiScreen(jadwal: j),
                                  ),
                                );
                              },
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
