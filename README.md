# 🏥 Klinik App – Flutter Mobile Application

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Dart](https://img.shields.io/badge/Dart-3.x-blue)
![REST API](https://img.shields.io/badge/REST%20API-Backend-green)
![JWT](https://img.shields.io/badge/Auth-JWT-orange)

## 📖 Deskripsi Proyek

**Klinik App** adalah aplikasi mobile berbasis **Flutter** yang dikembangkan sebagai **Proyek Ujian Akhir Semester (UAS)**.  
Aplikasi ini bertujuan untuk membantu proses **manajemen layanan klinik** secara digital, mulai dari pengelolaan pengguna, penjadwalan dokter, pembuatan janji konsultasi, hingga **pencetakan tiket konsultasi**.

Aplikasi ini menerapkan **arsitektur client-server** dengan integrasi **REST API**, serta sistem autentikasi menggunakan **JSON Web Token (JWT)** untuk menjaga keamanan dan kontrol akses berdasarkan peran pengguna.

---

## ✨ Fitur Utama

### 🔐 Autentikasi & Keamanan
- Login menggunakan JWT
- Session management dengan SharedPreferences
- Logout (hapus token & session)
- Role-based access control

### 👥 Manajemen Pengguna
- Admin
- Dokter
- Pasien
- CRUD User (Admin Only)

### 🗓️ Jadwal & Janji Konsultasi
- Manajemen jadwal dokter
- Pembuatan janji konsultasi pasien
- Validasi kuota & jadwal

### 🎟️ Tiket Konsultasi
- Generate tiket konsultasi
- Tampilan tiket profesional
- Cetak tiket langsung dari aplikasi

### 🎨 UI / UX
- Desain modern & clean
- Animasi halus
- Responsive layout
- Konsisten di seluruh halaman

---

## 🧑‍💼 Role Pengguna

| Role   | Fitur |
|------|------|
| **Admin** | Manajemen user, jadwal dokter |
| **Dokter** | Melihat jadwal & data pasien |
| **Pasien** | Membuat janji & mencetak tiket |

---

## 🛠 Teknologi yang Digunakan

### Frontend
- **Flutter**
- **Dart**
- Material Design

### Backend
- **REST API**
- **JWT Authentication**
- Database Relasional

### Lainnya
- Shared Preferences
- WebView (Print Ticket)
- Android Emulator / Device

---


