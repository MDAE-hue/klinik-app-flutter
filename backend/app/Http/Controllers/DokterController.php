<?php

namespace App\Http\Controllers;

use App\Models\Dokter;
use Illuminate\Http\Request;

class DokterController extends Controller
{
    // ================= GET ALL =================
    public function index()
    {
        return response()->json([
            'data' => Dokter::orderBy('nama')->get()
        ]);
    }

    // ================= STORE =================
    public function store(Request $request)
    {
        $this->validate($request, [
            'user_id'   => 'required|unique:dokter,user_id',
            'nama'      => 'required',
            'spesialis' => 'nullable',
            'no_str'    => 'required|unique:dokter,no_str',
        ]);

        $dokter = Dokter::create($request->all());

        return response()->json([
            'message' => 'Dokter berhasil ditambahkan',
            'data' => $dokter
        ], 201);
    }

    // ================= SHOW =================
    public function show($id)
    {
        return response()->json([
            'data' => Dokter::findOrFail($id)
        ]);
    }

    // ================= UPDATE =================
    public function update(Request $request, $id)
    {
        $dokter = Dokter::findOrFail($id);

        $dokter->update($request->only([
            'nama',
            'spesialis',
            'no_str'
        ]));

        return response()->json([
            'message' => 'Dokter berhasil diperbarui',
            'data' => $dokter
        ]);
    }

    // ================= DELETE =================
    public function destroy($id)
    {
        Dokter::findOrFail($id)->delete();

        return response()->json([
            'message' => 'Dokter berhasil dihapus'
        ]);
    }
}
