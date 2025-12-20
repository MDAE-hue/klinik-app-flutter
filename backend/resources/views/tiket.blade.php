<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Tiket Konsultasi</title>

    <style>
        body {
            font-family: monospace;
            font-size: 12px;
            margin: 0;
            padding: 0;
        }
        .ticket {
            width: 58mm;
            padding: 6px;
        }
        .center { text-align: center; }
        .bold { font-weight: bold; }
        .divider {
            border-top: 1px dashed #000;
            margin: 6px 0;
        }
        table { width: 100%; }
        td { padding: 2px 0; }
    </style>
</head>
<body>

<div class="ticket">
    <div class="center bold">
        KLINIK XYZ<br>
        TIKET KONSULTASI
    </div>

    <div class="divider"></div>

    <table>
        <tr><td>Kode</td><td>: {{ $janji->kode_tiket }}</td></tr>
        <tr><td>Pasien</td><td>: {{ $janji->pasien->nama }}</td></tr>
        <tr><td>Dokter</td><td>: {{ $janji->jadwalDokter->dokter->nama }}</td></tr>
        <tr><td>Tanggal</td><td>: {{ $janji->tanggal_janji }}</td></tr>
        <tr><td>Status</td><td>: {{ $janji->status->nama_status }}</td></tr>
    </table>

    <div class="divider"></div>

    <div class="center">
        Simpan tiket ini<br>
        sebagai bukti konsultasi
    </div>

    <div class="divider"></div>

    <div class="center">Terima kasih 🙏</div>
</div>

</body>
</html>
