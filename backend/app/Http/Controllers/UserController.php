<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\DB;
use App\Models\User;
use App\Models\Pasien;
use App\Models\Dokter;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class UserController extends Controller
{
    // ================================
    // LIST SEMUA USER
    // ================================
    public function index()
    {
        $users = User::with(['role','pasien','dokter'])->get();
        return response()->json(['data'=>$users]);
    }

    // ================================
    // CREATE PASIEN
    // ================================
    public function createPasien(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nama'=>'required|string',
            'nik'=>'required|string|unique:pasien,nik',
            'tanggal_lahir'=>'required|date',
            'no_hp'=>'required|string',
            'alamat'=>'required|string',
            'email'=>'nullable|email|unique:users,email'
        ]);

        if ($validator->fails()) return response()->json($validator->errors(),422);

        // Buat user otomatis tanpa hash
        $user = User::create([
            'nama' => $request->nama,
            'email' => $request->email,
            'password' => $request->nik, // plain password
            'role_id' => 3
        ]);

        // Buat pasien
        $pasien = Pasien::create([
            'user_id' => $user->id,
            'nama' => $request->nama,
            'nik' => $request->nik,
            'tanggal_lahir' => $request->tanggal_lahir,
            'no_hp' => $request->no_hp,
            'alamat' => $request->alamat
        ]);

        return response()->json(['user'=>$user,'pasien'=>$pasien],201);
    }

    // ================================
    // CREATE DOKTER
    // ================================
    public function createDokter(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nama'=>'required|string',
            'spesialis'=>'nullable|string',
            'no_str'=>'required|string|unique:dokter,no_str',
            'email'=>'nullable|email|unique:users,email'
        ]);

        if ($validator->fails()) return response()->json($validator->errors(),422);

        // Buat user otomatis tanpa hash
        $user = User::create([
            'nama' => $request->nama,
            'email' => $request->email,
            'password' => $request->no_str, // plain password
            'role_id' => 2
        ]);

        // Buat dokter
        $dokter = Dokter::create([
            'user_id' => $user->id,
            'nama' => $request->nama,
            'spesialis' => $request->spesialis,
            'no_str' => $request->no_str
        ]);

        return response()->json(['user'=>$user,'dokter'=>$dokter],201);
    }

   public function update(Request $request, $id)
{
    $user = User::with(['pasien','dokter'])->findOrFail($id);

    // ========================
    // SYNC NAMA
    // ========================
    if ($request->filled('nama')) {
        $user->nama = $request->nama;

        if ($user->role_id == 3 && $user->pasien) {
            $user->pasien->nama = $request->nama;
        }

        if ($user->role_id == 2 && $user->dokter) {
            $user->dokter->nama = $request->nama;
        }
    }

    // ========================
    // UPDATE EMAIL
    // ========================
    if ($request->filled('email')) {
        $user->email = $request->email;
    }

    // ========================
    // PASIEN
    // ========================
    if ($user->role_id == 3 && $user->pasien) {

        if ($request->filled('nik')) {
            $user->pasien->nik = $request->nik;

            // password = nik (TIDAK hash)
            $user->password = $request->nik;
        }

        $user->pasien->fill($request->only([
            'tanggal_lahir',
            'no_hp',
            'alamat'
        ]));
    }

    // ========================
    // DOKTER
    // ========================
    if ($user->role_id == 2 && $user->dokter) {

        if ($request->filled('no_str')) {
            $user->dokter->no_str = $request->no_str;

            // password = no_str (TIDAK hash)
            $user->password = $request->no_str;
        }

        $user->dokter->fill($request->only([
            'spesialis'
        ]));
    }

    // ========================
    // SAVE SEMUA
    // ========================
    $user->save();
    if ($user->pasien) $user->pasien->save();
    if ($user->dokter) $user->dokter->save();

    return response()->json([
        'message' => 'Data berhasil diupdate & tersinkron',
        'user' => $user->load(['pasien','dokter'])
    ]);
}



    // ================================
    // DELETE USER
    // ================================
public function delete($id)
{
    DB::beginTransaction();

    try {
        // hapus data dokter jika ada
        Dokter::where('user_id', $id)->delete();

        // hapus data pasien jika ada
        Pasien::where('user_id', $id)->delete();

        // hapus user
        User::where('id', $id)->delete();

        DB::commit();

        return response()->json([
            'message' => 'User berhasil dihapus'
        ]);
    } catch (\Exception $e) {
        DB::rollBack();

        return response()->json([
            'message' => 'Gagal menghapus user',
            'error' => $e->getMessage()
        ], 500);
    }
}
}
