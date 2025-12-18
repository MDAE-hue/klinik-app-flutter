<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pasien extends Model
{
    protected $table = 'pasien';
    protected $fillable = ['user_id', 'nama', 'nik', 'tanggal_lahir', 'no_hp', 'alamat'];

    public $timestamps = false; // Nonaktifkan timestamp otomatis

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
