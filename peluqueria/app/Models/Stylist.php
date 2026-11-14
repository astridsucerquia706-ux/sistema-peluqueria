<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Stylist extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'phone', 'active'];

        
    public function schedules()
    {
        return $this->hasMany(Schedule::class);
    }

    
    public function appointments()
    {
        return $this->hasMany(Appointment::class);
    }

   
    public function services()
    {
        return $this->belongsToMany(Service::class)->withTimestamps();
    }
}