<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Auth\Authenticatable as AuthenticatableTrait;
use Illuminate\Contracts\Auth\Authenticatable;

class User extends Model implements Authenticatable
{
    use AuthenticatableTrait;

    protected $table = 'users';

    protected $fillable = [
        'nama', 'email', 'password', 'role_id'
    ];

    protected $hidden = [
        'password'
    ];

    public $timestamps = true;

    // RELASI ROLE
    public function role()
    {
        return $this->belongsTo(Role::class);
    }

    // RELASI PASIEN
    public function pasien()
    {
        return $this->hasOne(Pasien::class);
    }

    // RELASI DOKTER
    public function dokter()
    {
        return $this->hasOne(Dokter::class);
    }
}
