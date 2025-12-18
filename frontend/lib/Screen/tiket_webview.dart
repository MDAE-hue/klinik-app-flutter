import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class TiketWebViewScreen extends StatefulWidget {
  final int janjiId;

  const TiketWebViewScreen({super.key, required this.janjiId});

  @override
  State<TiketWebViewScreen> createState() => _TiketWebViewScreenState();
}

class _TiketWebViewScreenState extends State<TiketWebViewScreen> {
  late final WebViewController _controller;
  bool loading = true;
  static const Color primaryBlue = Color(0xFF1565C0);

  final String baseUrl = "http://10.0.2.2:8000";

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      debugPrint("❌ TOKEN TIDAK ADA");
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => loading = true),
          onPageFinished: (_) => setState(() => loading = false),
        ),
      )
      ..loadRequest(
        Uri.parse("$baseUrl/api/janji/${widget.janjiId}/tiket"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "text/html",
        },
      );

    setState(() {});
  }

  Future<void> printTiket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return;

    final url = Uri.parse("$baseUrl/api/janji/${widget.janjiId}/tiket?token=$token");
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> downloadPdf() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return;

    final url = Uri.parse("$baseUrl/api/janji/${widget.janjiId}/pdf?token=$token");
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tiket Konsultasi"),
        backgroundColor: primaryBlue,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (loading)
            const Center(
              child: CircularProgressIndicator(color: primaryBlue),
            ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "printBtn",
            onPressed: printTiket,
            icon: const Icon(Icons.print),
            label: const Text("Print"),
            backgroundColor: primaryBlue,
          ),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            heroTag: "pdfBtn",
            onPressed: downloadPdf,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text("PDF"),
            backgroundColor: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}
