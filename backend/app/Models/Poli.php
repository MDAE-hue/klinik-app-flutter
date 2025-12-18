<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Poli extends Model
{
    protected $table = 'poli';

    protected $fillable = [
        'nama_poli'
    ];

    public $timestamps = false;

    public function jadwal()
    {
        return $this->hasMany(JadwalDokter::class);
    }
}
