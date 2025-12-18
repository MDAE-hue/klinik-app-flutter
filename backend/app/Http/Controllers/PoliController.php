<?php

namespace App\Http\Controllers;

use App\Models\Poli;
use Illuminate\Http\Request;

class PoliController extends Controller
{
    // ================= GET ALL =================
    public function index()
    {
        return response()->json([
            'data' => Poli::orderBy('nama_poli')->get()
        ]);
    }

    // ================= STORE =================
    public function store(Request $request)
    {
        $this->validate($request, [
            'nama_poli' => 'required|unique:poli,nama_poli',
        ]);

        $poli = Poli::create($request->all());

        return response()->json([
            'message' => 'Poli berhasil ditambahkan',
            'data' => $poli
        ], 201);
    }

    // ================= UPDATE =================
    public function update(Request $request, $id)
    {
        $poli = Poli::findOrFail($id);

        $this->validate($request, [
            'nama_poli' => 'required|unique:poli,nama_poli,' . $id,
        ]);

        $poli->update($request->only('nama_poli'));

        return response()->json([
            'message' => 'Poli berhasil diperbarui',
            'data' => $poli
        ]);
    }

    // ================= DELETE =================
    public function destroy($id)
    {
        Poli::findOrFail($id)->delete();

        return response()->json([
            'message' => 'Poli berhasil dihapus'
        ]);
    }
}
