<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Appointment extends Model
{
    use HasFactory;

    protected $fillable = ['client_id', 'stylist_id', 'user_id', 'date', 'time', 'status', 'notes'];

    
    public function client()
    {
        return $this->belongsTo(Client::class);
    }

    
    public function stylist()
    {
        return $this->belongsTo(Stylist::class);
    }

    
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    
    public function services()
    {
        return $this->belongsToMany(Service::class)
            ->withPivot('price')
            ->withTimestamps();
    }

   
    public function payments()
    {
        return $this->hasMany(Payment::class);
    }
}