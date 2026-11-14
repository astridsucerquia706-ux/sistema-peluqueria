<?php

namespace App\Http\Controllers;

use App\Models\Appointment;
use App\Models\Service;
use App\Models\Stylist;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class AppointmentController extends Controller
{
    
    public function index(Request $request)
    {
        $query = Appointment::with(['client', 'stylist', 'services', 'payments']);

        if ($request->filled('q')) {
            $query->whereHas('client', function ($q) use ($request) {
                $q->where('name', 'like', '%' . $request->q . '%');
            });
        }

        if ($request->filled('date')) {
            $query->where('date', $request->date);
        }

        $appointments = $query->orderBy('date')->orderBy('time')->get();
        return response()->json(['datos' => $appointments], 200);
    }

    
    public function show($id)
    {
        $appointment = Appointment::with(['client', 'stylist', 'services', 'payments'])->findOrFail($id);
        return response()->json(['dato' => $appointment], 200);
    }

    
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), $this->reglas(), $this->mensajes());

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()->first()], 400);
        }

        $datos = $validator->validated();

        $error = $this->validarReglasNegocio($datos);
        if ($error) {
            return response()->json(['error' => $error], 400);
        }

        
            $userId = $request->user()->id; 
            $appointment = DB::transaction(function () use ($datos, $userId) {
            $appointment = Appointment::create([
                'client_id' => $datos['client_id'],
                'stylist_id' => $datos['stylist_id'],
                'user_id' => $userId,
                'date' => $datos['date'],
                'time' => $datos['time'],
                'status' => 'pendiente',
                'notes' => $datos['notes'] ?? null,
            ]);

            $appointment->services()->sync($this->serviciosConPrecio($datos['service_ids']));

            return $appointment;
        });

        return response()->json(['dato' => $appointment->load(['client', 'stylist', 'services'])], 201);
    }

    
    public function update(Request $request, $id)
    {
        $appointment = Appointment::findOrFail($id);

        if ($appointment->status !== 'pendiente') {
            return response()->json(['error' => 'Solo se pueden modificar turnos pendientes'], 400);
        }

        $validator = Validator::make($request->all(), $this->reglas(), $this->mensajes());

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()->first()], 400);
        }

        $datos = $validator->validated();

        
        $error = $this->validarReglasNegocio($datos, $id);
        if ($error) {
            return response()->json(['error' => $error], 400);
        }

        DB::transaction(function () use ($appointment, $datos) {
            $appointment->update([
                'client_id' => $datos['client_id'],
                'stylist_id' => $datos['stylist_id'],
                'date' => $datos['date'],
                'time' => $datos['time'],
                'notes' => $datos['notes'] ?? null,
            ]);

            $appointment->services()->sync($this->serviciosConPrecio($datos['service_ids']));
        });

        return response()->json(['dato' => $appointment->load(['client', 'stylist', 'services'])], 200);
    }

    
    public function destroy($id)
    {
        $appointment = Appointment::findOrFail($id);

        if ($appointment->status !== 'pendiente') {
            return response()->json(['error' => 'Solo se pueden cancelar turnos pendientes'], 400);
        }

        $appointment->update(['status' => 'cancelado']);
        return response()->json(['mensaje' => 'Turno cancelado correctamente'], 200);
    }

    
    public function attend($id)
    {
        $appointment = Appointment::findOrFail($id);

        if ($appointment->status !== 'pendiente') {
            return response()->json(['error' => 'Solo se pueden atender turnos pendientes'], 400);
        }

        $appointment->update(['status' => 'atendido']);
        return response()->json(['mensaje' => 'Turno marcado como atendido'], 200);
    }

        
    public function export()
    {
        $appointments = Appointment::with(['client', 'stylist', 'services'])
            ->orderBy('date')
            ->orderBy('time')
            ->get();

        return response()->streamDownload(function () use ($appointments) {
            $archivo = fopen('php://output', 'w');

            
            fwrite($archivo, "\xEF\xBB\xBF");

            fputcsv($archivo, ['ID', 'Fecha', 'Hora', 'Cliente', 'Estilista', 'Servicios', 'Total', 'Estado'], ';');

            foreach ($appointments as $a) {
                fputcsv($archivo, [
                    $a->id,
                    $a->date,
                    substr($a->time, 0, 5),
                    $a->client->name,
                    $a->stylist->name,
                    $a->services->pluck('name')->implode(', '),
                    $a->services->sum('pivot.price'),
                    $a->status,
                ], ';');
            }

            fclose($archivo);
        }, 'turnos.csv', ['Content-Type' => 'text/csv; charset=UTF-8']);
    }

    
    private function validarReglasNegocio($datos, $ignorarId = null)
    {
        $stylist = Stylist::find($datos['stylist_id']);

        
        if (!$stylist->active) {
            return 'El estilista seleccionado no está activo';
        }

        
        $ids = array_unique($datos['service_ids']);
        $puedeHacerlos = $stylist->services()->whereIn('services.id', $ids)->count();

        if ($puedeHacerlos !== count($ids)) {
            return 'El estilista no realiza uno de los servicios seleccionados';
        }

        
        $inicio = Carbon::parse($datos['date'] . ' ' . $datos['time']);
        $duracion = Service::whereIn('id', $ids)->sum('duration_minutes');
        $fin = $inicio->copy()->addMinutes($duracion);

        
        $dias = ['domingo', 'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado'];
        $dia = $dias[$inicio->dayOfWeek];

        $trabaja = $stylist->schedules()
            ->where('day_of_week', $dia)
            ->where('start_time', '<=', $inicio->format('H:i:s'))
            ->where('end_time', '>=', $fin->format('H:i:s'))
            ->exists();

        if (!$trabaja) {
            return 'El estilista no trabaja en ese horario (' . $dia . ' de ' . $inicio->format('H:i') . ' a ' . $fin->format('H:i') . ')';
        }

        
        $otrosTurnos = Appointment::with('services')
            ->where('stylist_id', $stylist->id)
            ->where('date', $datos['date'])
            ->where('status', '!=', 'cancelado')
            ->when($ignorarId, fn ($q) => $q->where('id', '!=', $ignorarId))
            ->get();

        foreach ($otrosTurnos as $otro) {
            $otroInicio = Carbon::parse($otro->date . ' ' . $otro->time);
            $otroFin = $otroInicio->copy()->addMinutes($otro->services->sum('duration_minutes'));

            if ($inicio < $otroFin && $fin > $otroInicio) {
                return 'El estilista ya tiene un turno de ' . $otroInicio->format('H:i') . ' a ' . $otroFin->format('H:i');
            }
        }

        return null;
    }

    
    private function serviciosConPrecio($ids)
    {
        $lista = [];

        foreach (Service::whereIn('id', $ids)->get() as $service) {
            $lista[$service->id] = ['price' => $service->price];
        }

        return $lista;
    }

    private function reglas()
    {
        return [
            'client_id' => 'required|exists:clients,id',
            'stylist_id' => 'required|exists:stylists,id',
            'date' => 'required|date_format:Y-m-d|after_or_equal:today',
            'time' => 'required|date_format:H:i',
            'service_ids' => 'required|array|min:1',
            'service_ids.*' => 'exists:services,id',
            'notes' => 'nullable|string|max:255',
        ];
    }

    private function mensajes()
    {
        return [
            'client_id.required' => 'El campo cliente es obligatorio',
            'client_id.exists' => 'El cliente seleccionado no existe',
            'stylist_id.required' => 'El campo estilista es obligatorio',
            'stylist_id.exists' => 'El estilista seleccionado no existe',
            'date.required' => 'La fecha es obligatoria',
            'date.date_format' => 'La fecha debe tener el formato AAAA-MM-DD, por ejemplo 2026-11-09',
            'date.after_or_equal' => 'La fecha del turno no puede ser anterior a hoy',
            'time.required' => 'La hora es obligatoria',
            'time.date_format' => 'La hora debe tener el formato HH:MM, por ejemplo 10:00',
            'service_ids.required' => 'Debe seleccionar al menos un servicio',
            'service_ids.min' => 'Debe seleccionar al menos un servicio',
            'service_ids.*.exists' => 'Uno de los servicios seleccionados no existe',
        ];
    }
}


