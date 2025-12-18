<?php

namespace App\Http\Controllers;

use App\Models\JadwalDokter;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class JadwalDokterController extends Controller
{
    // ============================
    // LIST JADWAL
    // ============================
    public function index()
    {
        $jadwal = JadwalDokter::with(['dokter','poli'])->get();
        return response()->json(['data' => $jadwal]);
    }

    // ============================
    // TAMBAH JADWAL
    // ============================
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'dokter_id'  => 'required|exists:dokter,id',
            'poli_id'    => 'required|exists:poli,id',
            'hari'       => 'required|string',
            'jam_mulai'  => 'required',
            'jam_selesai'=> 'required',
            'kuota'      => 'nullable|integer'
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $jadwal = JadwalDokter::create([
            'dokter_id'   => $request->dokter_id,
            'poli_id'     => $request->poli_id,
            'hari'        => $request->hari,
            'jam_mulai'   => $request->jam_mulai,
            'jam_selesai' => $request->jam_selesai,
            'kuota'       => $request->kuota ?? 20
        ]);

        return response()->json([
            'message' => 'Jadwal berhasil ditambahkan',
            'data' => $jadwal
        ], 201);
    }

    // ============================
    // UPDATE JADWAL
    // ============================
    public function update(Request $request, $id)
    {
        $jadwal = JadwalDokter::findOrFail($id);

        $jadwal->update($request->only([
            'dokter_id',
            'poli_id',
            'hari',
            'jam_mulai',
            'jam_selesai',
            'kuota'
        ]));

        return response()->json([
            'message' => 'Jadwal berhasil diupdate',
            'data' => $jadwal
        ]);
    }

    // ============================
    // DELETE JADWAL
    // ============================
    public function delete($id)
    {
        $jadwal = JadwalDokter::findOrFail($id);
        $jadwal->delete();

        return response()->json([
            'message' => 'Jadwal berhasil dihapus'
        ]);
    }
}
