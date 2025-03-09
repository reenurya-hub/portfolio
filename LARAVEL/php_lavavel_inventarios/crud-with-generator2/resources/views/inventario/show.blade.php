@extends('layouts.app')

@section('template_title')
    {{ $inventario->name ?? __('Show') . " " . __('Inventario') }}
@endsection

@section('content')
    <section class="content container-fluid">
        <div class="row">
            <div class="col-md-12">
                <div class="card">
                    <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                        <div class="float-left">
                            <span class="card-title">{{ __('Show') }} Inventario</span>
                        </div>
                        <div class="float-right">
                            <a class="btn btn-primary btn-sm" href="{{ route('inventarios.index') }}"> {{ __('Back') }}</a>
                        </div>
                    </div>

                    <div class="card-body bg-white">
                        
                                <div class="form-group mb-2 mb20">
                                    <strong>Codigo:</strong>
                                    {{ $inventario->codigo }}
                                </div>
                                <div class="form-group mb-2 mb20">
                                    <strong>Nombre Producto:</strong>
                                    {{ $inventario->nombre_producto }}
                                </div>
                                <div class="form-group mb-2 mb20">
                                    <strong>Unidad Medida:</strong>
                                    {{ $inventario->unidad_medida }}
                                </div>
                                <div class="form-group mb-2 mb20">
                                    <strong>Cantidad:</strong>
                                    {{ $inventario->cantidad }}
                                </div>
                                <div class="form-group mb-2 mb20">
                                    <strong>Precio:</strong>
                                    {{ $inventario->precio }}
                                </div>
                                <div class="form-group mb-2 mb20">
                                    <strong>Observaciones:</strong>
                                    {{ $inventario->observaciones }}
                                </div>
                                <div class="form-group mb-2 mb20">
                                    <strong>Fecha Creacion:</strong>
                                    {{ $inventario->fecha_creacion }}
                                </div>
                                <div class="form-group mb-2 mb20">
                                    <strong>Fecha Modificacion:</strong>
                                    {{ $inventario->fecha_modificacion }}
                                </div>

                    </div>
                </div>
            </div>
        </div>
    </section>
@endsection
