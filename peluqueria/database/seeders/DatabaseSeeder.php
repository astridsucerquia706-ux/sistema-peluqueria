<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Client;
use App\Models\PaymentMethod;
use App\Models\Role;
use App\Models\Service;
use App\Models\Stylist;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run()
    {
        // Roles
        $admin = Role::create(['name' => 'administrador']);
        Role::create(['name' => 'recepcionista']);
        Role::create(['name' => 'estilista']);

        // Usuario administrador de prueba
        User::create([
            'name' => 'Administrador',
            'email' => 'admin@peluqueria.test',
            'password' => Hash::make('Peluqueria2026'),
            'role_id' => $admin->id,
        ]);

        // Métodos de pago
        foreach (['Efectivo', 'Tarjeta', 'Nequi'] as $metodo) {
            PaymentMethod::create(['name' => $metodo]);
        }

        // Categorías y servicios
        $cabello = Category::create(['name' => 'Cabello']);
        $barba = Category::create(['name' => 'Barba']);
        $unas = Category::create(['name' => 'Uñas']);

        $corte = Service::create(['category_id' => $cabello->id, 'name' => 'Corte de cabello', 'price' => 25000, 'duration_minutes' => 30]);
        $tinte = Service::create(['category_id' => $cabello->id, 'name' => 'Tinte', 'price' => 80000, 'duration_minutes' => 90]);
        $cepillado = Service::create(['category_id' => $cabello->id, 'name' => 'Cepillado', 'price' => 30000, 'duration_minutes' => 40]);
        $keratina = Service::create(['category_id' => $cabello->id, 'name' => 'Keratina', 'price' => 150000, 'duration_minutes' => 120]);
        $arreglo = Service::create(['category_id' => $barba->id, 'name' => 'Arreglo de barba', 'price' => 15000, 'duration_minutes' => 20]);
        $afeitado = Service::create(['category_id' => $barba->id, 'name' => 'Afeitado clásico', 'price' => 20000, 'duration_minutes' => 30]);
        $manicure = Service::create(['category_id' => $unas->id, 'name' => 'Manicure', 'price' => 20000, 'duration_minutes' => 45]);
        $pedicure = Service::create(['category_id' => $unas->id, 'name' => 'Pedicure', 'price' => 25000, 'duration_minutes' => 50]);
        $acrilicas = Service::create(['category_id' => $unas->id, 'name' => 'Uñas acrílicas', 'price' => 70000, 'duration_minutes' => 90]);

        // Estilistas
        $carlos = Stylist::create(['name' => 'Carlos Gómez', 'phone' => '3001234567']);
        $laura = Stylist::create(['name' => 'Laura Restrepo', 'phone' => '3109876543']);
        $mateo = Stylist::create(['name' => 'Mateo Zapata', 'phone' => '3125558899']);
        $valentina = Stylist::create(['name' => 'Valentina Ríos', 'phone' => '3017773344']);

        // Servicios que sabe hacer cada estilista (tabla service_stylist)
        $carlos->services()->attach([$corte->id, $arreglo->id, $afeitado->id]);
        $laura->services()->attach([$corte->id, $tinte->id, $cepillado->id, $keratina->id]);
        $mateo->services()->attach([$corte->id, $arreglo->id, $afeitado->id]);
        $valentina->services()->attach([$manicure->id, $pedicure->id, $acrilicas->id, $cepillado->id]);

        // Horarios
        foreach (['lunes', 'martes', 'miércoles', 'jueves', 'viernes'] as $dia) {
            $carlos->schedules()->create(['day_of_week' => $dia, 'start_time' => '08:00', 'end_time' => '17:00']);
            $laura->schedules()->create(['day_of_week' => $dia, 'start_time' => '10:00', 'end_time' => '19:00']);
        }

        foreach (['martes', 'jueves', 'sábado'] as $dia) {
            $mateo->schedules()->create(['day_of_week' => $dia, 'start_time' => '09:00', 'end_time' => '18:00']);
        }

        foreach (['lunes', 'miércoles', 'viernes', 'sábado'] as $dia) {
            $valentina->schedules()->create(['day_of_week' => $dia, 'start_time' => '08:00', 'end_time' => '14:00']);
        }

        // Clientes
        Client::create(['name' => 'Ana Martínez', 'phone' => '3151112233', 'email' => 'ana@correo.com']);
        Client::create(['name' => 'Juan Pérez', 'phone' => '3204445566']);
        Client::create(['name' => 'Sofía Herrera', 'phone' => '3186667788', 'email' => 'sofia@correo.com']);
        Client::create(['name' => 'Andrés Londoño', 'phone' => '3002223344']);
        Client::create(['name' => 'Camila Ospina', 'phone' => '3119990011', 'email' => 'camila@correo.com']);
        Client::create(['name' => 'Ana Gutiérrez', 'phone' => '3145556677']);
    }
}