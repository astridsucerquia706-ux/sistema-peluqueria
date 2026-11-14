<?php

namespace App\Http\Controllers;

use App\Models\Appointment;
use App\Models\Payment;
use App\Models\PaymentMethod;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class PaymentController extends Controller
{
    
    public function methods()
    {
        $methods = PaymentMethod::orderBy('name')->get();
        return response()->json(['datos' => $methods], 200);
    }

    
    public function index(Request $request)
    {
        $query = Payment::with(['appointment.client', 'paymentMethod']);

        if ($request->filled('appointment_id')) {
            $query->where('appointment_id', $request->appointment_id);
        }

        $payments = $query->orderBy('paid_at', 'desc')->get();
        return response()->json(['datos' => $payments], 200);
    }

    
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'appointment_id' => 'required|exists:appointments,id',
            'payment_method_id' => 'required|exists:payment_methods,id',
            'amount' => 'required|numeric|min:1',
        ], [
            'appointment_id.required' => 'El turno es obligatorio',
            'appointment_id.exists' => 'El turno seleccionado no existe',
            'payment_method_id.required' => 'El método de pago es obligatorio',
            'payment_method_id.exists' => 'El método de pago seleccionado no existe',
            'amount.required' => 'El valor es obligatorio',
            'amount.numeric' => 'El valor debe ser un número',
            'amount.min' => 'El valor debe ser mayor que cero',
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()->first()], 400);
        }

        $datos = $validator->validated();
        $appointment = Appointment::with(['services', 'payments'])->find($datos['appointment_id']);

        
        if ($appointment->status !== 'atendido') {
            return response()->json(['error' => 'Solo se pueden registrar pagos de turnos atendidos'], 400);
        }

        
        $total = $appointment->services->sum('pivot.price');
        $pagado = $appointment->payments->sum('amount');
        $pendiente = $total - $pagado;

        if ($datos['amount'] > $pendiente) {
            return response()->json([
                'error' => 'El valor supera el saldo pendiente del turno ($' . number_format($pendiente, 0, ',', '.') . ')'
            ], 400);
        }

        $payment = Payment::create([
            'appointment_id' => $datos['appointment_id'],
            'payment_method_id' => $datos['payment_method_id'],
            'amount' => $datos['amount'],
            'paid_at' => now(),
        ]);

        return response()->json([
            'dato' => $payment->load('paymentMethod'),
            'saldo_pendiente' => $pendiente - $datos['amount'],
        ], 201);
    }

    
    public function destroy($id)
    {
        $payment = Payment::findOrFail($id);
        $payment->delete();
        return response()->json(['mensaje' => 'Pago eliminado correctamente'], 200);
    }
}