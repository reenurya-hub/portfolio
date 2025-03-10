package com.example.demo_app.services;

import java.util.List;
import java.util.Optional;

import com.example.demo_app.dto.Inventario;

public interface InventarioService {

	List<Inventario> getAllInventarios();
	Optional<Inventario> getInventarioById(String codinventario);
	Optional<Inventario> createInventario(Inventario inventario);
	Inventario updateInventario(String codinventario, Inventario inventario);
	void deleteInventarioById(String codinventario);
	
}
