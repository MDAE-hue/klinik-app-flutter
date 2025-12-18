<!DOCTYPE html>
<html>
<head>
    <title>Tiket Konsultasi</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            background-color: #f3f4f6;
            margin: 0;
            padding: 0;
            font-size: 14px;
        }

        .container {
            width: 700px;
            margin: 30px auto;
            padding: 20px;
            background-color: #ffffff;
            border-radius: 16px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            border: 1px solid #d1d5db;
        }

        .header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-bottom: 2px solid #1565C0;
            padding-bottom: 12px;
            margin-bottom: 20px;
        }

        .logo {
            height: 50px;
        }

        .title {
            color: #1565C0;
            font-size: 22px;
            font-weight: bold;
            text-align: center;
            flex: 1;
        }

        .info {
            display: grid;
            grid-template-columns: 150px 1fr;
            row-gap: 12px;
            column-gap: 16px;
            font-size: 16px;
        }

        .info strong {
            color: #111827;
        }

        .status {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 12px;
            font-weight: bold;
            color: #fff;
            background-color: #3b82f6; /* default color for status */
        }

        .status.selesai { background-color: #10b981; }   /* green */
        .status.dijadwalkan { background-color: #3b82f6; } /* blue */
        .status.batal { background-color: #ef4444; }    /* red */

        .qr-placeholder {
            margin-top: 20px;
            text-align: center;
        }

        .qr-placeholder img {
            width: 120px;
            height: 120px;
        }

        @media print {
            body {
                background-color: #fff;
            }
            .container {
                box-shadow: none;
                border: none;
            }
        }
    </style>
</head>
<body>

<div class="container">
    <div class="header">
        <img src="https://via.placeholder.com/50x50.png?text=LOGO" alt="Logo Klinik" class="logo">
        <div class="title">TIKET KONSULTASI</div>
        <div></div>
    </div>

    <div class="info">
        <div><strong>Kode Tiket:</strong></div>
        <div>{{ $janji->kode_tiket }}</div>

        <div><strong>Nama Pasien:</strong></div>
        <div>{{ $janji->pasien->nama }}</div>

        <div><strong>Dokter:</strong></div>
        <div>{{ $janji->jadwalDokter->dokter->nama }}</div>

        <div><strong>Tanggal:</strong></div>
        <div>{{ $janji->tanggal_janji }}</div>

        <div><strong>Status:</strong></div>
        <div>
            <span class="status {{ strtolower($janji->status->nama_status) }}">
                {{ $janji->status->nama_status }}
            </span>
        </div>
    </div>

    <div class="qr-placeholder">
        <p>Scan untuk verifikasi</p>
        <img src="https://via.placeholder.com/120" alt="QR Code">
    </div>
</div>

<script>
  window.onload = function () {
    window.print();
  }
</script>
</body>
</html>
