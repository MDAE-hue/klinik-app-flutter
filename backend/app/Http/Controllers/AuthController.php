<?php

namespace App\Http\Controllers;

use App\Models\User;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        // Validasi input
        $this->validate($request, [
            'email'    => 'required|email',
            'password' => 'required'
        ]);

        $user = User::where('email', $request->email)->first();

        // Cek user dan password
        if (! $user || $request->password !== $user->password) {
            return response()->json([
                'success' => false,
                'message' => 'Email atau password salah'
            ], 401);
        }

        // Payload JWT
        $payload = [
            "iss"  => "manajemen-klinik-lumen",
            "sub"  => $user->id,
            "role" => $user->role_id,
            "iat"  => time(),
            "exp"  => time() + (60 * 60 * 24) // 24 jam
        ];

        // Generate JWT Token
        $token = JWT::encode($payload, env('JWT_SECRET'), 'HS256');

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'token'   => $token,
            'user'    => [
                'id'    => $user->id,
                'nama'  => $user->nama,
                'email' => $user->email,
                'role'  => $user->role->nama_role ?? null,
            ]
        ]);
    }
}
