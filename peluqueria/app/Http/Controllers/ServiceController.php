<?php

namespace App\Http\Controllers;

use App\Models\Service;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ServiceController extends Controller
{
    
    public function index(Request $request)
    {
        $query = Service::with('category');

        if ($request->filled('q')) {
            $query->where('name', 'like', '%' . $request->q . '%');
        }

        $services = $query->orderBy('name')->get();
        return response()->json(['datos' => $services], 200);
    }

    
    public function show($id)
    {
        $service = Service::with(['category', 'stylists'])->findOrFail($id);
        return response()->json(['dato' => $service], 200);
    }

    
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), $this->reglas(), $this->mensajes());

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()->first()], 400);
        }

        $service = Service::create($validator->validated());
        return response()->json(['dato' => $service->load('category')], 201);
    }

    
    public function update(Request $request, $id)
    {
        $service = Service::findOrFail($id);

        $validator = Validator::make($request->all(), $this->reglas(), $this->mensajes());

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()->first()], 400);
        }

        $service->update($validator->validated());
        return response()->json(['dato' => $service->load('category')], 200);
    }

    
    public function destroy($id)
    {
        $service = Service::findOrFail($id);

        
        if ($service->appointments()->exists()) {
            return response()->json(['error' => 'No se puede eliminar el servicio porque ya se usó en turnos'], 400);
        }

        
        $service->stylists()->detach();
        $service->delete();
        return response()->json(['mensaje' => 'Servicio eliminado correctamente'], 200);
    }

    
    private function reglas()
    {
        return [
            'category_id' => 'required|exists:categories,id',
            'name' => 'required|string|max:100',
            'price' => 'required|numeric|min:0',
            'duration_minutes' => 'required|integer|min:1',
        ];
    }

    private function mensajes()
    {
        return [
            'category_id.required' => 'La categoría es obligatoria',
            'category_id.exists' => 'La categoría seleccionada no existe',
            'name.required' => 'El campo nombre es obligatorio',
            'price.required' => 'El precio es obligatorio',
            'price.numeric' => 'El precio debe ser un número',
            'duration_minutes.required' => 'La duración es obligatoria',
            'duration_minutes.integer' => 'La duración debe ser un número entero de minutos',
        ];
    }
}