<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    
    public function register(Request $request)
    {
        if ($request->user()->role->name !== 'administrador') {
            return response()->json(['error' => 'Solo el administrador puede registrar usuarios'], 403);
        }
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:100',
            'email' => 'required|email|max:150|unique:users,email',
            'password' => 'required|string|min:8',
            'role_id' => 'required|exists:roles,id',
        ], [
            'name.required' => 'El campo nombre es obligatorio',
            'email.required' => 'El campo correo es obligatorio',
            'email.email' => 'El correo no tiene un formato válido',
            'email.unique' => 'Ya existe un usuario con ese correo',
            'password.required' => 'El campo contraseña es obligatorio',
            'password.min' => 'La contraseña debe tener al menos 8 caracteres',
            'role_id.required' => 'El rol es obligatorio',
            'role_id.exists' => 'El rol seleccionado no existe',
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()->first()], 400);
        }

        $datos = $validator->validated();

        $user = User::create([
            'name' => $datos['name'],
            'email' => $datos['email'],
            'password' => Hash::make($datos['password']), 
            'role_id' => $datos['role_id'],
        ]);

        return response()->json(['dato' => $user->load('role')], 201);
    }

    
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string',
        ], [
            'email.required' => 'El campo correo es obligatorio',
            'email.email' => 'El correo no tiene un formato válido',
            'password.required' => 'El campo contraseña es obligatorio',
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()->first()], 400);
        }

        $user = User::where('email', $request->email)->first();

        
        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(['error' => 'Correo o contraseña incorrectos'], 401);
        }

        $token = $user->createToken('sesion')->plainTextToken;

        return response()->json([
            'token' => $token,
            'usuario' => $user->load('role'),
        ], 200);
    }

    
    public function me(Request $request)
    {
        return response()->json(['dato' => $request->user()->load('role')], 200);
    }

    
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['mensaje' => 'Sesión cerrada correctamente'], 200);
    }
}