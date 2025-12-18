<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class JanjiKonsultasi extends Model
{
    protected $table = 'janji_konsultasi';

    protected $fillable = [
        'pasien_id',
        'jadwal_dokter_id',
        'tanggal_janji',
        'status_id',
        'kode_tiket'
    ];

    public function pasien()
    {
        return $this->belongsTo(Pasien::class);
    }

    public function jadwalDokter()
    {
        return $this->belongsTo(JadwalDokter::class);
    }

    public function status()
    {
        return $this->belongsTo(StatusJanji::class, 'status_id');
    }
}
