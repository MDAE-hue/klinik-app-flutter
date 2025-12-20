<?php

/** @var \Laravel\Lumen\Routing\Router $router */



$router->get('/', function () use ($router) {
    return $router->app->version();
});

$router->group(['prefix' => 'api'], function () use ($router) {

    $router->get('/janji/{id}/tiket', 'JanjiKonsultasiController@tiket');
    $router->post('/login', 'AuthController@login'); // login dengan NIK / STR / email

    $router->group(['middleware' => 'jwt'], function () use ($router) {
        $router->get('/profile', 'AuthController@me'); // cek token / data user
        $router->get('users', 'UserController@index');

        $router->post('users/pasien', 'UserController@createPasien');
        $router->post('users/dokter', 'UserController@createDokter');
        $router->put('users/{id}', 'UserController@update');
        $router->delete('users/{id}', 'UserController@delete');

        $router->get('jadwal', 'JadwalDokterController@index');

        $router->get('dokter', 'DokterController@index');
        $router->post('dokter', 'DokterController@store');
        $router->get('dokter/{id}', 'DokterController@show');
        $router->put('dokter/{id}', 'DokterController@update');
        $router->delete('dokter/{id}', 'DokterController@destroy');

        $router->get('poli', 'PoliController@index');
        $router->post('poli', 'PoliController@store');
        $router->put('poli/{id}', 'PoliController@update');
        $router->delete('poli/{id}', 'PoliController@destroy');

        $router->group(['middleware' => 'admin'], function () use ($router) {
            $router->post('jadwal-dokter', 'JadwalDokterController@store');
            $router->put('jadwal-dokter/{id}', 'JadwalDokterController@update');
            $router->delete('jadwal-dokter/{id}', 'JadwalDokterController@delete');
        });


        $router->get('/janji/{id}/print', 'JanjiKonsultasiController@printJson');
        $router->get('/tiket/{id}/pdf', 'JanjiKonsultasiController@pdf');
        $router->post('/janji', 'JanjiKonsultasiController@store');
        $router->get('/janji', 'JanjiKonsultasiController@index');
        $router->delete('/janji/{id}', 'JanjiKonsultasiController@delete');
    });
});