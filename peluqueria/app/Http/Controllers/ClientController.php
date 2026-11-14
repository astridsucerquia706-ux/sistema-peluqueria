<?php

namespace App\Http\Controllers;

use App\Models\Client;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ClientController extends Controller
{
    
    public function index(Request $request)
    {
        $query = Client::query();

        if ($request->filled('q')) {
            $query->where('name', 'like', '%' . $request->q . '%');
        }

        $clients = $query->orderBy('name')->get();
        return response()->json(['datos' => $clients], 200);
    }

    
    public function show($id)
    {
        $client = Client::findOrFail($id);
        return response()->json(['dato' => $client], 200);
    }

    
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:100',
            'phone' => 'required|string|max:20',
            'email' => 'nullable|email|max:150',
        ], [
            'name.required' => 'El campo nombre es obligatorio',
            'phone.required' => 'El campo teléfono es obligatorio',
            'email.email' => 'El correo no tiene un formato válido',
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()->first()], 400);
        }

        $client = Client::create($validator->validated());
        return response()->json(['dato' => $client], 201);
    }

    
    public function update(Request $request, $id)
    {
        $client = Client::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:100',
            'phone' => 'required|string|max:20',
            'email' => 'nullable|email|max:150',
        ], [
            'name.required' => 'El campo nombre es obligatorio',
            'phone.required' => 'El campo teléfono es obligatorio',
            'email.email' => 'El correo no tiene un formato válido',
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()->first()], 400);
        }

        $client->update($validator->validated());
        return response()->json(['dato' => $client], 200);
    }

    
    
    public function destroy($id)
    {
        $client = Client::findOrFail($id);

        // Regla del negocio: no se borra un cliente que ya tiene turnos
        if ($client->appointments()->exists()) {
            return response()->json(['error' => 'No se puede eliminar el cliente porque tiene turnos registrados'], 400);
        }

        $client->delete();
        return response()->json(['mensaje' => 'Cliente eliminado correctamente'], 200);
    }
}