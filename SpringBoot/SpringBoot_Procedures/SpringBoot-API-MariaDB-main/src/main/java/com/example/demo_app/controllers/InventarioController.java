package com.example.demo_app.controllers;

import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo_app.dto.Inventario;
import com.example.demo_app.services.InventarioServiceImpl;

@RestController
@RequestMapping("/api/inventario")
@CrossOrigin(origins = "*")
public class InventarioController {

	@Autowired
	public InventarioServiceImpl inventarioServiceImpl;
	
	@GetMapping("/all")
	public List<Inventario> getAllInventarios(){
		return inventarioServiceImpl.getAllInventarios();
	}
	
	@GetMapping("/{codigo}")
	public Inventario getInventarioById(@PathVariable(name="codigo") String codigo) {
		Optional<Inventario> inventario = inventarioServiceImpl.getInventarioById(codigo);
		if(inventario.isPresent()) {
			return inventario.get();
		} else {
			throw new NoSuchElementException();
		}
	}
	
	@PostMapping("/create")
	public Optional<Inventario> createInventario(@RequestBody Inventario inventario){
		Optional<Inventario> newInventario = inventarioServiceImpl.createInventario(inventario);
		if(newInventario.isPresent()) {
			return newInventario;
		} else {
			throw new NoSuchElementException();
		}
	}
	
	@PutMapping("/update/{codigo}")
	public Inventario updateInventario(@PathVariable(name="codigo") String codigo, @RequestBody Inventario inventario){
		Inventario updateInventario = inventarioServiceImpl.updateInventario(codigo, inventario);
		return updateInventario;
	}
	
	@DeleteMapping("/delete/{codigo}")
	public void deleteInventario(@PathVariable(name="codigo") String codigo) {
		inventarioServiceImpl.deleteInventarioById(codigo);
	}
}
