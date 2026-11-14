<?php

namespace App\Http\Controllers;

use App\Models\Stylist;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class StylistController extends Controller
{
    
    public function index(Request $request)
    {
        $query = Stylist::with(['services', 'schedules']);

        if ($request->filled('q')) {
            $query->where('name', 'like', '%' . $request->q . '%');
        }

        $stylists = $query->orderBy('name')->get();
        return response()->json(['datos' => $stylists], 200);
    }

    
    public function show($id)
    {
        $stylist = Stylist::with(['services', 'schedules'])->findOrFail($id);
        return response()->json(['dato' => $stylist], 200);
    }

    
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), $this->reglas(), $this->mensajes());

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()->first()], 400);
        }

        $datos = $validator->validated();
        $stylist = Stylist::create($datos);

        
        if (isset($datos['service_ids'])) {
            $stylist->services()->sync($datos['service_ids']);
        }

        return response()->json(['dato' => $stylist->load('services')], 201);
    }

    
    public function update(Request $request, $id)
    {
        $stylist = Stylist::findOrFail($id);

        $validator = Validator::make($request->all(), $this->reglas(), $this->mensajes());

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()->first()], 400);
        }

        $datos = $validator->validated();
        $stylist->update($datos);

        if (isset($datos['service_ids'])) {
            $stylist->services()->sync($datos['service_ids']);
        }

        return response()->json(['dato' => $stylist->load('services')], 200);
    }


    public function destroy($id)
    {
        $stylist = Stylist::findOrFail($id);

        
        if ($stylist->appointments()->exists()) {
            return response()->json(['error' => 'No se puede eliminar el estilista porque tiene turnos. Puede desactivarlo'], 400);
        }

        $stylist->services()->detach();
        $stylist->schedules()->delete();
        $stylist->delete();
        return response()->json(['mensaje' => 'Estilista eliminado correctamente'], 200);
    }

    private function reglas()
    {
        return [
            'name' => 'required|string|max:100',
            'phone' => 'required|string|max:20',
            'active' => 'boolean',
            'service_ids' => 'array',
            'service_ids.*' => 'exists:services,id',
        ];
    }

    private function mensajes()
    {
        return [
            'name.required' => 'El campo nombre es obligatorio',
            'phone.required' => 'El campo teléfono es obligatorio',
            'active.boolean' => 'El campo activo debe ser verdadero o falso',
            'service_ids.array' => 'Los servicios deben enviarse como una lista',
            'service_ids.*.exists' => 'Uno de los servicios seleccionados no existe',
        ];
    }
}