<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Service extends Model
{
    use HasFactory;

    protected $fillable = ['category_id', 'name', 'price', 'duration_minutes'];

    // Un servicio pertenece a una categoría
    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    // Un servicio lo hacen muchos estilistas (tabla service_stylist)
    public function stylists()
    {
        return $this->belongsToMany(Stylist::class)->withTimestamps();
    }

    // Un servicio aparece en muchos turnos (tabla appointment_service)
    public function appointments()
    {
        return $this->belongsToMany(Appointment::class)
            ->withPivot('price')
            ->withTimestamps();
    }
}