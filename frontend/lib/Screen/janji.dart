import 'package:flutter/material.dart';
import '../helper/api.dart';
import 'tiket_webview.dart';

class JanjiScreen extends StatefulWidget {
  const JanjiScreen({super.key});

  @override
  State<JanjiScreen> createState() => _JanjiScreenState();
}

class _JanjiScreenState extends State<JanjiScreen> with SingleTickerProviderStateMixin {
  bool loading = true;
  List<JanjiKonsultasi> list = [];
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    fetchJanji();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchJanji() async {
    setState(() => loading = true);
    try {
      list = await API.janji.listMy();
      _animationController.forward(from: 0);
    } catch (e) {
      debugPrint("❌ $e");
    } finally {
      setState(() => loading = false);
    }
  }

  void openTiket(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TiketWebViewScreen(janjiId: id),
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "selesai":
        return Colors.green;
      case "dijadwalkan":
        return Colors.blue;
      case "batal":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Janji Konsultasi"),
        backgroundColor: const Color(0xFF1565C0),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchJanji,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final j = list[i];
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final animationValue =
                          (_animationController.value - i * 0.1).clamp(0.0, 1.0);
                      return Opacity(
                        opacity: animationValue,
                        child: Transform.translate(
                          offset: Offset(0, 50 * (1 - animationValue)),
                          child: child,
                        ),
                      );
                    },
                    child: Card(
                      elevation: 6,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadowColor: Colors.black.withOpacity(0.2),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
                          backgroundColor: getStatusColor(j.status),
                          radius: 24,
                          child: const Icon(
                            Icons.confirmation_number,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        title: Text(
                          j.kodeTiket,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                          "Tanggal: ${j.tanggal}\nStatus: ${j.status}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right, color: Color(0xFF1565C0)),
                        onTap: () => openTiket(j.id),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
