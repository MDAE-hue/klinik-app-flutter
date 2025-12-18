-- ====================================================
-- 1. TABEL ROLES
-- ====================================================
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    nama_role VARCHAR(50) NOT NULL
);

INSERT INTO roles (nama_role) VALUES 
('admin'),
('dokter'),
('pasien');

-- ====================================================
-- 2. TABEL USERS (LOGIN)
-- ====================================================
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    password VARCHAR(255) NOT NULL,
    role_id INT NOT NULL REFERENCES roles(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ====================================================
-- 3. TABEL DOKTER
-- ====================================================
CREATE TABLE dokter (
    id SERIAL PRIMARY KEY,
    user_id INT UNIQUE NOT NULL REFERENCES users(id),
    nama VARCHAR(100) NOT NULL,
    spesialis VARCHAR(100),
    no_str VARCHAR(100) NOT NULL
);

-- ====================================================
-- 4. TABEL PASIEN
-- ====================================================
CREATE TABLE pasien (
    id SERIAL PRIMARY KEY,
    user_id INT UNIQUE REFERENCES users(id),
    nama VARCHAR(100) NOT NULL,
    nik VARCHAR(20) UNIQUE,
    tanggal_lahir DATE,
    no_hp VARCHAR(20),
    alamat TEXT
);

-- ====================================================
-- 5. TABEL POLI
-- ====================================================
CREATE TABLE poli (
    id SERIAL PRIMARY KEY,
    nama_poli VARCHAR(100) NOT NULL
);

INSERT INTO poli (nama_poli) VALUES
('Poli Umum'),
('Poli Anak'),
('Poli Gigi'),
('Poli Kandungan');

-- ====================================================
-- 6. TABEL JADWAL DOKTER
-- ====================================================
CREATE TABLE jadwal_dokter (
    id SERIAL PRIMARY KEY,
    dokter_id INT NOT NULL REFERENCES dokter(id),
    poli_id INT NOT NULL REFERENCES poli(id),
    hari VARCHAR(15) NOT NULL,
    jam_mulai TIME NOT NULL,
    jam_selesai TIME NOT NULL,
    kuota INT DEFAULT 20
);

-- ====================================================
-- 7. TABEL STATUS JANJI
-- ====================================================
CREATE TABLE status_janji (
    id SERIAL PRIMARY KEY,
    nama_status VARCHAR(50) NOT NULL
);

INSERT INTO status_janji (nama_status) VALUES
('Menunggu Konfirmasi'),
('Dikonfirmasi'),
('Dibatalkan'),
('Selesai');

-- ====================================================
-- 8. TABEL JANJI KONSULTASI
-- ====================================================
CREATE TABLE janji_konsultasi (
    id SERIAL PRIMARY KEY,
    pasien_id INT NOT NULL REFERENCES pasien(id),
    jadwal_dokter_id INT NOT NULL REFERENCES jadwal_dokter(id),
    tanggal_janji DATE NOT NULL,
    status_id INT NOT NULL REFERENCES status_janji(id),
    kode_tiket VARCHAR(20) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ====================================================
-- 9. TABEL REKAM MEDIS
-- ====================================================
CREATE TABLE rekam_medis (
    id SERIAL PRIMARY KEY,
    pasien_id INT NOT NULL REFERENCES pasien(id),
    dokter_id INT NOT NULL REFERENCES dokter(id),
    keluhan TEXT,
    diagnosa TEXT,
    tindakan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ====================================================
-- 10. CONTOH DATA ADMIN
-- ====================================================
INSERT INTO users (nama, email, password, role_id) VALUES
('Admin Klinik', 'admin@klinik.com', 'admin123', 1);
