<?php

namespace App\Http\Controllers;

use App\Models\JanjiKonsultasi;
use App\Models\RekamMedis;
use App\Models\Pasien;
use App\Models\JadwalDokter;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Barryvdh\DomPDF\Facade\Pdf;

class JanjiKonsultasiController extends Controller
{

    
    // ================================
    // GET SEMUA JANJI (ADMIN / DOKTER)
    // ================================
    public function index()
    {
        $data = JanjiKonsultasi::with([
            'pasien',
            'jadwalDokter.dokter',
            'status'
        ])->get();

        return response()->json($data);
    }

    // ================================
    // GET JANJI PASIEN LOGIN
    // ================================
    public function myTickets(Request $request)
    {
        $userId = $request->auth->sub;

        $pasien = Pasien::where('user_id', $userId)->firstOrFail();

        $data = JanjiKonsultasi::where('pasien_id', $pasien->id)
            ->with(['jadwalDokter.dokter','status'])
            ->get();

        return response()->json($data);
    }

    // ================================
    // CREATE JANJI + REKAM MEDIS
    // ================================
    public function store(Request $request)
{
    // ✅ VALIDASI KHUSUS LUMEN (JANGAN request->validate)
    $validator = Validator::make($request->all(), [
        'jadwal_dokter_id' => 'required|exists:jadwal_dokter,id',
        'tanggal_janji'   => 'required|date',
        'keluhan'         => 'required|string',
    ]);

    if ($validator->fails()) {
        return response()->json([
            'errors' => $validator->errors()
        ], 422);
    }

    // ✅ AMBIL USER DARI AUTH
    $userId = Auth::id();

    if (!$userId) {
        return response()->json(['message' => 'Unauthorized'], 401);
    }

    $pasien = Pasien::where('user_id', $userId)->first();
    if (!$pasien) {
        return response()->json(['message' => 'Pasien tidak ditemukan'], 404);
    }

    DB::beginTransaction();
    try {
        $jadwal = JadwalDokter::lockForUpdate()
            ->findOrFail($request->jadwal_dokter_id);

        if ($jadwal->kuota <= 0) {
            DB::rollBack();
            return response()->json(['message' => 'Kuota habis'], 400);
        }

        $jadwal->decrement('kuota');

        $today = date('Ymd');
        $last = JanjiKonsultasi::whereDate('created_at', date('Y-m-d'))
            ->orderBy('id', 'desc')
            ->first();

        $urutan = $last ? ((int) substr($last->kode_tiket, -3)) + 1 : 1;
        $kodeTiket = $today . '-' . str_pad($urutan, 3, '0', STR_PAD_LEFT);

        $janji = JanjiKonsultasi::create([
            'pasien_id'        => $pasien->id,
            'jadwal_dokter_id' => $jadwal->id,
            'tanggal_janji'    => $request->tanggal_janji,
            'status_id'        => 1,
            'kode_tiket'       => $kodeTiket
        ]);

        RekamMedis::create([
            'pasien_id' => $pasien->id,
            'dokter_id' => $jadwal->dokter_id,
            'keluhan'   => $request->keluhan
        ]);

        DB::commit();

        return response()->json([
            'message' => 'Janji berhasil dibuat',
            'data' => $janji
        ], 201);

    } catch (\Exception $e) {
        DB::rollBack();
        return response()->json(['error' => $e->getMessage()], 500);
    }
}



    // ================================
    // DELETE JANJI
    // ================================
    public function delete($id)
    {
        $janji = JanjiKonsultasi::findOrFail($id);
        $janji->delete();

        return response()->json(['message'=>'Janji berhasil dihapus']);
    }

public function tiket($id)
{
    $janji = JanjiKonsultasi::with([
        'pasien',
        'jadwalDokter.dokter',
        'status'
    ])->findOrFail($id);

    return view('tiket', compact('janji'));
}


    // ================= JSON UNTUK PRINTER =================
    public function printJson($id)
    {
        $janji = JanjiKonsultasi::with([
            'pasien',
            'jadwalDokter.dokter',
            'status'
        ])->findOrFail($id);

        return response()->json([
            "title" => "KLINIK XYZ",
            "lines" => [
                "Kode   : {$janji->kode_tiket}",
                "Pasien : {$janji->pasien->nama}",
                "Dokter : {$janji->jadwalDokter->dokter->nama}",
                "Tanggal: {$janji->tanggal_janji}",
                "Status : {$janji->status->nama_status}",
            ],
            "footer" => "Terima kasih 🙏"
        ]);
    }


public function pdf($id)
{
    $user = auth()->user();

    $janji = JanjiKonsultasi::with([
        'pasien',
        'jadwalDokter.dokter',
        'status'
    ])
    ->where('id', $id)
    ->where('pasien_id', $user->id)
    ->firstOrFail();

    $pdf = Pdf::loadView('tiket', [
        'janji' => $janji
    ]);

    return $pdf->download(
        'tiket-'.$janji->kode_tiket.'.pdf'
    );
}

}
