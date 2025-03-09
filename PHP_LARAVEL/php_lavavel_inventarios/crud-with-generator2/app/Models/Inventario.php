<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Class Inventario
 *
 * @property $id
 * @property $codigo
 * @property $nombre_producto
 * @property $unidad_medida
 * @property $cantidad
 * @property $precio
 * @property $observaciones
 * @property $fecha_creacion
 * @property $fecha_modificacion
 *
 * @package App
 * @mixin \Illuminate\Database\Eloquent\Builder
 */
class Inventario extends Model
{
    
    protected $perPage = 20;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = ['codigo', 'nombre_producto', 'unidad_medida', 'cantidad', 'precio', 'observaciones', 'fecha_creacion', 'fecha_modificacion'];


}
