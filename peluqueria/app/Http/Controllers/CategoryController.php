<?php

namespace App\Http\Controllers;

use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CategoryController extends Controller
{
    
    public function index()
    {
        $categories = Category::orderBy('name')->get();
        return response()->json(['datos' => $categories], 200);
    }

    
    public function show($id)
    {
        $category = Category::with('services')->findOrFail($id);
        return response()->json(['dato' => $category], 200);
    }

    
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:50|unique:categories,name',
        ], [
            'name.required' => 'El campo nombre es obligatorio',
            'name.unique' => 'Ya existe una categoría con ese nombre',
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()->first()], 400);
        }

        $category = Category::create($validator->validated());
        return response()->json(['dato' => $category], 201);
    }

    
    public function update(Request $request, $id)
    {
        $category = Category::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:50|unique:categories,name,' . $id,
        ], [
            'name.required' => 'El campo nombre es obligatorio',
            'name.unique' => 'Ya existe una categoría con ese nombre',
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()->first()], 400);
        }

        $category->update($validator->validated());
        return response()->json(['dato' => $category], 200);
    }

    
    public function destroy($id)
    {
        $category = Category::findOrFail($id);

        
        if ($category->services()->exists()) {
            return response()->json(['error' => 'No se puede eliminar la categoría porque tiene servicios asociados'], 400);
        }

        $category->delete();
        return response()->json(['mensaje' => 'Categoría eliminada correctamente'], 200);
    }
}