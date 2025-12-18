import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const Color primaryBlue = Color(0xFF1565C0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      // =========================
      // NAVBAR / APPBAR
      // =========================
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 2,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Selamat Datang 👋",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2),
            Text(
              "Informasi terbaru dari klinik",
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =========================
            // BERITA SLIDER
            // =========================
            _sectionTitle("Berita Terbaru"),

            SizedBox(
              height: 190,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _NewsSliderItem(
                    title: "Layanan Baru Dibuka",
                    image: "https://picsum.photos/400/200?1",
                  ),
                  _NewsSliderItem(
                    title: "Tips Menjaga Imunitas",
                    image: "https://picsum.photos/400/200?2",
                  ),
                  _NewsSliderItem(
                    title: "Dokter Spesialis Bergabung",
                    image: "https://picsum.photos/400/200?3",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // =========================
            // INFORMASI KESEHATAN
            // =========================
            _sectionTitle("Informasi Kesehatan"),

            const _NewsListItem(
              title: "Pentingnya Cek Kesehatan",
              subtitle: "Pemeriksaan rutin membantu deteksi dini penyakit.",
              image: "https://picsum.photos/200/200?4",
            ),
            const _NewsListItem(
              title: "Bahaya Kurang Tidur",
              subtitle: "Kurang tidur menurunkan daya tahan tubuh.",
              image: "https://picsum.photos/200/200?5",
            ),
            const _NewsListItem(
              title: "Pola Makan Sehat",
              subtitle: "Konsumsi makanan bergizi seimbang.",
              image: "https://picsum.photos/200/200?6",
            ),

            const SizedBox(height: 28),

            // =========================
            // TIPS HARI INI
            // =========================
            _sectionTitle("Tips Hari Ini"),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1976D2),
                    Color(0xFF42A5F5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.health_and_safety,
                      color: Colors.white,
                      size: 42,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Minum air putih minimal 8 gelas per hari "
                        "untuk menjaga kesehatan tubuh.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // SECTION TITLE
  // =========================
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: primaryBlue,
        ),
      ),
    );
  }
}

// =========================
// SLIDER ITEM
// =========================
class _NewsSliderItem extends StatelessWidget {
  final String title;
  final String image;

  const _NewsSliderItem({
    required this.title,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(image),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.bottomLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// =========================
// LIST ITEM
// =========================
class _NewsListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;

  const _NewsListItem({
    required this.title,
    required this.subtitle,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            image,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.blue,
        ),
      ),
    );
  }
}
