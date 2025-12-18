import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../Screen/Login.dart';
import '../main.dart'; // navigatorKey

// const String BASE_URL = "http://localhost:8000/api";
const String BASE_URL = "http://10.0.2.2:8000/api";

Future<String> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("token") ?? "";
}

Future<void> forceLogout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  final context = navigatorKey.currentContext;
  if (context == null) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Text("Sesi Berakhir"),
      content: const Text(
        "Sesi login kamu sudah habis.\nSilakan login kembali.",
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            );
          },
          child: const Text("OK"),
        )
      ],
    ),
  );
}


Future<Map<String, dynamic>> _apiFetchMap(
  String endpoint, {
  String method = "GET",
  Map<String, dynamic>? body,
}) async {
  final token = await _getToken();

  final headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  final url = Uri.parse("$BASE_URL$endpoint");
  late http.Response res;

  switch (method.toUpperCase()) {
    case "POST":
      res = await http.post(url, headers: headers, body: jsonEncode(body));
      break;
    case "PUT":
      res = await http.put(url, headers: headers, body: jsonEncode(body));
      break;
    case "DELETE":
      res = await http.delete(url, headers: headers);
      break;
    default:
      res = await http.get(url, headers: headers);
  }

  if (res.statusCode == 401) {
    await forceLogout();
    throw Exception("Token expired");
  }

  if (res.statusCode < 200 || res.statusCode >= 300) {
    throw Exception("API Error ${res.statusCode}: ${res.body}");
  }

  final decoded = jsonDecode(res.body);
  return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
}

//Model//

//USER MODEL//
class User {
  int id;
  String nama;
  String? email;
  int roleId;
  String role;
  Map<String, dynamic>? pasien;
  Map<String, dynamic>? dokter;

  User({
    required this.id,
    required this.nama,
    this.email,
    required this.roleId,
    required this.role,
    this.pasien,
    this.dokter,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        nama: json['nama'],
        email: json['email'],
        roleId: json['role_id'],
        role: json['role']['nama_role'],
        pasien: json['pasien'],
        dokter: json['dokter'],
      );
}


//Pasien Model//
class Pasien {
  int id;
  String nama;
  String? nik;
  String? noHp;
  String? alamat;

  Pasien({
    required this.id,
    required this.nama,
    this.nik,
    this.noHp,
    this.alamat,
  });

  factory Pasien.fromJson(Map<String, dynamic> json) => Pasien(
    id: json['id'],
    nama: json['nama'],
    nik: json['nik'],
    noHp: json['no_hp'],
    alamat: json['alamat'],
  );
}

//Jadwal + Dokter Model//
class JadwalDokter {
  int id;
  int dokterId;
  int poliId;
  String dokter;
  String poli;
  String hari;
  String jamMulai;
  String jamSelesai;
  int kuota;

  JadwalDokter({
    required this.id,
    required this.dokterId,
    required this.poliId,
    required this.dokter,
    required this.poli,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.kuota,
  });

  factory JadwalDokter.fromJson(Map<String, dynamic> json) => JadwalDokter(
        id: json['id'],
        dokterId: json['dokter']['id'],
        poliId: json['poli']['id'],
        dokter: json['dokter']['nama'],
        poli: json['poli']['nama_poli'],
        hari: json['hari'],
        jamMulai: json['jam_mulai'],
        jamSelesai: json['jam_selesai'],
        kuota: json['kuota'],
      );
}

class Dokter {
  int id;
  String nama;

  Dokter({required this.id, required this.nama});

  factory Dokter.fromJson(Map<String, dynamic> json) =>
      Dokter(id: json['id'], nama: json['nama']);
}

class Poli {
  int id;
  String nama;

  Poli({required this.id, required this.nama});

  factory Poli.fromJson(Map<String, dynamic> json) =>
      Poli(id: json['id'], nama: json['nama_poli']);
}


//Janji Konsultasi Model//
class JanjiKonsultasi {
  final int id;
  final String kodeTiket;
  final String tanggal;
  final String status;
  final String dokter;

  JanjiKonsultasi({
    required this.id,
    required this.kodeTiket,
    required this.tanggal,
    required this.status,
    required this.dokter,
  });

  factory JanjiKonsultasi.fromJson(Map<String, dynamic> json) {
    return JanjiKonsultasi(
      id: json['id'],
      kodeTiket: json['kode_tiket'] ?? '-',
      tanggal: json['tanggal_janji'] ?? '-',
      status: json['status'] != null
          ? json['status']['nama_status']
          : 'Menunggu',
      dokter: json['jadwal_dokter'] != null &&
              json['jadwal_dokter']['dokter'] != null
          ? json['jadwal_dokter']['dokter']['nama']
          : '-',
    );
  }
}



//API FUNCTIONS//
class DokterApi {
  Future<List<Map<String, dynamic>>> getAll() async {
    final res = await _apiFetchMap("/dokter");
    return List<Map<String, dynamic>>.from(res['data']);
  }
}

class PoliApi {
  Future<List<Map<String, dynamic>>> getAll() async {
    final res = await _apiFetchMap("/poli");
    return List<Map<String, dynamic>>.from(res['data']);
  }
}


///JADWAL DOKTER API//
class JadwalDokterApi {

  /// LIST (SEMUA USER)
  Future<List<JadwalDokter>> list() async {
    final res = await _apiFetchMap("/jadwal");
    final list = res['data'] ?? [];
    return (list as List)
        .map((e) => JadwalDokter.fromJson(e))
        .toList();
  }

  /// ADMIN: CREATE
  Future<void> create({
    required int dokterId,
    required int poliId,
    required String hari,
    required String jamMulai,
    required String jamSelesai,
    int kuota = 20,
  }) async {
    await _apiFetchMap(
      "/jadwal-dokter",
      method: "POST",
      body: {
        "dokter_id": dokterId,
        "poli_id": poliId,
        "hari": hari,
        "jam_mulai": jamMulai,
        "jam_selesai": jamSelesai,
        "kuota": kuota,
      },
    );
  }

  /// ADMIN: UPDATE
  Future<void> update(
    int id, {
    int? dokterId,
    int? poliId,
    String? hari,
    String? jamMulai,
    String? jamSelesai,
    int? kuota,
  }) async {
    final body = <String, dynamic>{};

    if (dokterId != null) body['dokter_id'] = dokterId;
    if (poliId != null) body['poli_id'] = poliId;
    if (hari != null) body['hari'] = hari;
    if (jamMulai != null) body['jam_mulai'] = jamMulai;
    if (jamSelesai != null) body['jam_selesai'] = jamSelesai;
    if (kuota != null) body['kuota'] = kuota;

    await _apiFetchMap(
      "/jadwal-dokter/$id",
      method: "PUT",
      body: body,
    );
  }

  /// ADMIN: DELETE
  Future<void> delete(int id) async {
    await _apiFetchMap(
      "/jadwal-dokter/$id",
      method: "DELETE",
    );
  }
}


///JANJI KONSULTASI API//

class JanjiKonsultasiApi {

  /// PASIEN BUAT JANJI
  Future<JanjiKonsultasi> create({
    required int jadwalDokterId,
    required DateTime tanggal,
    required String keluhan,
  }) async {
    final body = {
      "jadwal_dokter_id": jadwalDokterId,
      "tanggal_janji": DateFormat('yyyy-MM-dd').format(tanggal),
      "keluhan": keluhan,
    };

    final res = await _apiFetchMap(
      "/janji",
      method: "POST",
      body: body,
    );

    return JanjiKonsultasi.fromJson(res['data']);
  }

  /// LIST JANJI PASIEN LOGIN
  Future<List<JanjiKonsultasi>> listMy() async {
    final res = await _apiFetchMap("/janji");
    final list = res['data'] ?? [];
    return (list as List)
        .map((e) => JanjiKonsultasi.fromJson(e))
        .toList();
  }

  /// HAPUS JANJI
  Future<void> delete(int id) async {
    await _apiFetchMap(
      "/janji/$id",
      method: "DELETE",
    );
  }
}

///AUTHENTICATION API//
class AuthApi {
  Future<Map<String, dynamic>> login(String email, String password) async {
    return await _apiFetchMap(
      "/login",
      method: "POST",
      body: {"email": email, "password": password},
    );
  }

  Future<Map<String, dynamic>> me() async {
    return await _apiFetchMap("/me");
  }

  Future<void> logout() async {
    await _apiFetchMap("/logout", method: "POST");
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }
}

///USER API//

class UserApi {
  Future<List<User>> list() async {
    final res = await _apiFetchMap("/users");
    final list = res['data'] ?? [];
    return (list as List).map((e) => User.fromJson(e)).toList();
  }

  /// CREATE PASIEN
  Future<void> createPasien({
    required String nama,
    required String nik,
    required String tanggalLahir,
    required String noHp,
    required String alamat,
    String? email,
  }) async {
    await _apiFetchMap(
      "/users/pasien",
      method: "POST",
      body: {
        "nama": nama,
        "nik": nik,
        "tanggal_lahir": tanggalLahir,
        "no_hp": noHp,
        "alamat": alamat,
        "email": email,
      },
    );
  }

  /// CREATE DOKTER
  Future<void> createDokter({
    required String nama,
    required String noStr,
    String? spesialis,
    String? email,
  }) async {
    await _apiFetchMap(
      "/users/dokter",
      method: "POST",
      body: {
        "nama": nama,
        "no_str": noStr,
        "spesialis": spesialis,
        "email": email,
      },
    );
  }

  /// UPDATE USER (PASIEN / DOKTER)
  Future<void> update(
    int id, {
    String? nama,
    String? email,

    // pasien
    String? nik,
    String? tanggalLahir,
    String? noHp,
    String? alamat,

    // dokter
    String? noStr,
    String? spesialis,
  }) async {
    final body = <String, dynamic>{};

    if (nama != null) body['nama'] = nama;
    if (email != null) body['email'] = email;

    if (nik != null) body['nik'] = nik;
    if (tanggalLahir != null) body['tanggal_lahir'] = tanggalLahir;
    if (noHp != null) body['no_hp'] = noHp;
    if (alamat != null) body['alamat'] = alamat;

    if (noStr != null) body['no_str'] = noStr;
    if (spesialis != null) body['spesialis'] = spesialis;

    await _apiFetchMap(
      "/users/$id",
      method: "PUT",
      body: body,
    );
  }

  Future<void> delete(int id) async {
    await _apiFetchMap("/users/$id", method: "DELETE");
  }

  
}



//MAIN API CLASS//
class API {
  static final jadwalDokter = JadwalDokterApi();
  static final janji = JanjiKonsultasiApi();
  static final auth = AuthApi();
  static final user = UserApi();
  static final dokter = DokterApi();
  static final poli = PoliApi();
}
