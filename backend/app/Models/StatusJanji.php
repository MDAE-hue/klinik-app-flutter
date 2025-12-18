<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class StatusJanji extends Model
{
    protected $table = 'status_janji';

    protected $fillable = [
        'nama_status'
    ];

    public $timestamps = false;
}
