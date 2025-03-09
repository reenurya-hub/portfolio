@extends('layouts.app')

@section('template_title')
    Inventarios
@endsection

@section('content')
    <div class="container-fluid">
        <div class="row">
            <div class="col-sm-12">
                <div class="card">
                    <div class="card-header">
                        <div style="display: flex; justify-content: space-between; align-items: center;">

                            <span id="card_title">
                                {{ __('Inventarios') }}
                            </span>

                             <div class="float-right">
                                <a href="{{ route('inventarios.create') }}" class="btn btn-primary btn-sm float-right"  data-placement="left">
                                  {{ __('Create New') }}
                                </a>
                              </div>
                        </div>
                    </div>
                    @if ($message = Session::get('success'))
                        <div class="alert alert-success m-4">
                            <p>{{ $message }}</p>
                        </div>
                    @endif

                    <div class="card-body bg-white">
                        <div class="table-responsive">
                            <table class="table table-striped table-hover">
                                <thead class="thead">
                                    <tr>
                                        <th>No</th>
                                        
									<th >Codigo</th>
									<th >Nombre Producto</th>
									<th >Unidad Medida</th>
									<th >Cantidad</th>
									<th >Precio</th>
									<th >Observaciones</th>
									<th >Fecha Creacion</th>
									<th >Fecha Modificacion</th>

                                        <th></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @foreach ($inventarios as $inventario)
                                        <tr>
                                            <td>{{ ++$i }}</td>
                                            
										<td >{{ $inventario->codigo }}</td>
										<td >{{ $inventario->nombre_producto }}</td>
										<td >{{ $inventario->unidad_medida }}</td>
										<td >{{ $inventario->cantidad }}</td>
										<td >{{ $inventario->precio }}</td>
										<td >{{ $inventario->observaciones }}</td>
										<td >{{ $inventario->fecha_creacion }}</td>
										<td >{{ $inventario->fecha_modificacion }}</td>

                                            <td>
                                                <form action="{{ route('inventarios.destroy', $inventario->id) }}" method="POST">
                                                    <a class="btn btn-sm btn-primary " href="{{ route('inventarios.show', $inventario->id) }}"><i class="fa fa-fw fa-eye"></i> {{ __('Show') }}</a>
                                                    <a class="btn btn-sm btn-success" href="{{ route('inventarios.edit', $inventario->id) }}"><i class="fa fa-fw fa-edit"></i> {{ __('Edit') }}</a>
                                                    @csrf
                                                    @method('DELETE')
                                                    <button type="submit" class="btn btn-danger btn-sm" onclick="event.preventDefault(); confirm('Are you sure to delete?') ? this.closest('form').submit() : false;"><i class="fa fa-fw fa-trash"></i> {{ __('Delete') }}</button>
                                                </form>
                                            </td>
                                        </tr>
                                    @endforeach
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                {!! $inventarios->withQueryString()->links() !!}
            </div>
        </div>
    </div>
@endsection
