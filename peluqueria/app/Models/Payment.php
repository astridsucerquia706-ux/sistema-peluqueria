<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    use HasFactory;

    protected $fillable = ['appointment_id', 'payment_method_id', 'amount', 'paid_at'];

    
    public function appointment()
    {
        return $this->belongsTo(Appointment::class);
    }

    
    public function paymentMethod()
    {
        return $this->belongsTo(PaymentMethod::class);
    }
}