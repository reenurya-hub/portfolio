<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class InventarioRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
			'codigo' => 'required|string',
			'nombre_producto' => 'required|string',
			'unidad_medida' => 'string',
			'cantidad' => 'required',
			'precio' => 'required',
			'observaciones' => 'string',
			'fecha_creacion' => 'required',
			'fecha_modificacion' => 'required',
        ];
    }
}
