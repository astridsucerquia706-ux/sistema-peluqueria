<?php

namespace App\Http\Controllers;

use App\Models\Schedule;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ScheduleController extends Controller
{
    
    public function index(Request $request)
    {
        $query = Schedule::with('stylist');

        if ($request->filled('stylist_id')) {
            $query->where('stylist_id', $request->stylist_id);
        }

        $schedules = $query->orderBy('stylist_id')->get();
        return response()->json(['datos' => $schedules], 200);
    }

    
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), $this->reglas(), $this->mensajes());

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()->first()], 400);
        }

        $datos = $validator->validated();

        if ($this->seCruza($datos)) {
            return response()->json(['error' => 'El horario se cruza con otro horario del estilista ese mismo día'], 400);
        }

        $schedule = Schedule::create($datos);
        return response()->json(['dato' => $schedule], 201);
    }

    
    public function update(Request $request, $id)
    {
        $schedule = Schedule::findOrFail($id);

        $validator = Validator::make($request->all(), $this->reglas(), $this->mensajes());

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()->first()], 400);
        }

        $datos = $validator->validated();

        if ($this->seCruza($datos, $id)) {
            return response()->json(['error' => 'El horario se cruza con otro horario del estilista ese mismo día'], 400);
        }

        $schedule->update($datos);
        return response()->json(['dato' => $schedule], 200);
    }

    
    public function destroy($id)
    {
        $schedule = Schedule::findOrFail($id);
        $schedule->delete();
        return response()->json(['mensaje' => 'Horario eliminado correctamente'], 200);
    }

    
    private function seCruza($datos, $ignorarId = null)
    {
        return Schedule::where('stylist_id', $datos['stylist_id'])
            ->where('day_of_week', $datos['day_of_week'])
            ->where('start_time', '<', $datos['end_time'])
            ->where('end_time', '>', $datos['start_time'])
            ->when($ignorarId, fn ($q) => $q->where('id', '!=', $ignorarId))
            ->exists();
    }

    private function reglas()
    {
        return [
            'stylist_id' => 'required|exists:stylists,id',
            'day_of_week' => 'required|in:lunes,martes,miércoles,jueves,viernes,sábado,domingo',
            'start_time' => 'required|date_format:H:i',
            'end_time' => 'required|date_format:H:i|after:start_time',
        ];
    }

    private function mensajes()
    {
        return [
            'stylist_id.required' => 'El estilista es obligatorio',
            'stylist_id.exists' => 'El estilista seleccionado no existe',
            'day_of_week.required' => 'El día es obligatorio',
            'day_of_week.in' => 'El día debe ser de lunes a domingo, en minúscula',
            'start_time.required' => 'La hora de inicio es obligatoria',
            'start_time.date_format' => 'La hora de inicio debe tener el formato HH:MM, por ejemplo 08:00',
            'end_time.required' => 'La hora de fin es obligatoria',
            'end_time.date_format' => 'La hora de fin debe tener el formato HH:MM, por ejemplo 17:00',
            'end_time.after' => 'La hora de fin debe ser posterior a la hora de inicio',
        ];
    }
}