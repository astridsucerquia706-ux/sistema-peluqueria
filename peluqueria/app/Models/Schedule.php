<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Schedule extends Model
{
    use HasFactory;

    protected $fillable = ['stylist_id', 'day_of_week', 'start_time', 'end_time'];

    // Un horario pertenece a un estilista
    public function stylist()
    {
        return $this->belongsTo(Stylist::class);
    }
}