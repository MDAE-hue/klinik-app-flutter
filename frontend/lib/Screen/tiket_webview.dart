import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blue_thermal_printer_plus/blue_thermal_printer_plus.dart';
import 'package:http/http.dart' as http;

class TiketWebViewScreen extends StatefulWidget {
  final int janjiId;
  const TiketWebViewScreen({super.key, required this.janjiId});

  @override
  State<TiketWebViewScreen> createState() => _TiketWebViewScreenState();
}

class _TiketWebViewScreenState extends State<TiketWebViewScreen> {
  late WebViewController _controller;
  bool loading = true;

  final BlueThermalPrinterPlus printer = BlueThermalPrinterPlus();
  final String baseUrl = "http://10.27.70.239:8000";

  static const Color primaryBlue = Color(0xFF1565C0);

  @override
  void initState() {
    super.initState();
    _setupWebView();
  }

  void showSnack(String message, {bool error = true}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: error ? Colors.redAccent : Colors.green,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ),
  );
}


  void _setupWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            setState(() => loading = false);
          },
          onWebResourceError: (error) {
            debugPrint("WEBVIEW ERROR: ${error.description}");
          },
        ),
      )
      // ❗ PAKAI ROUTE NON-API
      ..loadRequest(
        Uri.parse("$baseUrl/api/janji/${widget.janjiId}/tiket"),
      );
  }

  // ================= PRINT BLUETOOTH =================
Future<void> printTiketBluetooth() async {
  try {
    // 1️⃣ Bluetooth aktif?
    bool? isOn = await printer.isOn;
    if (isOn != true) {
      showSnack("Aktifkan Bluetooth terlebih dahulu");
      return;
    }

    // 2️⃣ Ada printer tersambung?
    final devices = await printer.getBondedDevices();
    if (devices.isEmpty) {
      showSnack("Printer belum tersambung, silakan hubungkan printer");
      return;
    }

    // 3️⃣ Ambil printer
    final device = devices.first;

    // 4️⃣ Clean connect (hindari socket error)
    bool? connected = await printer.isConnected;
    if (connected == true) {
      await printer.disconnect();
      await Future.delayed(const Duration(milliseconds: 400));
    }

    await printer.connect(device);
    await Future.delayed(const Duration(milliseconds: 300));

    // 5️⃣ Ambil data print
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      showSnack("Sesi login habis, silakan login ulang");
      return;
    }

    final res = await http.get(
      Uri.parse("$baseUrl/api/janji/${widget.janjiId}/print"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode != 200) {
      showSnack("Gagal mengambil data tiket");
      return;
    }

    final data = jsonDecode(res.body);

    // 6️⃣ PRINT
    printer.printNewLine();
    printer.printCustom(data['title'], 3, 1);
    printer.printCustom("------------------------------", 1, 1);

    for (String line in data['lines']) {
      printer.printCustom(line, 1, 0);
    }

    printer.printNewLine();
    printer.printCustom(data['footer'], 1, 1);
    printer.printNewLine();
    printer.printNewLine();

    showSnack("Tiket berhasil dicetak", error: false);

  } catch (_) {
    // ❌ SEMUA ERROR TEKNIS DITUTUP
    showSnack("Gagal mencetak tiket, pastikan printer tersambung");
  }
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
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: printTiketBluetooth,
        icon: const Icon(Icons.print),
        label: const Text("Print"),
      ),
    );
  }
}
