package com.example.demo_app.services;

import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo_app.dao.InventarioRepository;
import com.example.demo_app.dto.Inventario;

@Service
public class InventarioServiceImpl implements InventarioService{

	@Autowired
	public InventarioRepository inventarioRepository;
	
    Logger logger = LoggerFactory.getLogger(InventarioServiceImpl.class);
	
	@Override
	public List<Inventario> getAllInventarios() {
		List<Inventario> inventario = inventarioRepository.findAll();
		return inventario;
	}

	@Override
	public Optional<Inventario> getInventarioById(String codinventario) {
		Optional<Inventario> searchInventory = inventarioRepository.findById(codinventario);
		if(searchInventory.isPresent()) {
			logger.info("Inventario encontrado.");
			return searchInventory;
		} else {
			logger.error("No se encontró el elemento de inventario" + codinventario + "buscado");
			throw new NoSuchElementException("No se encontró el elemento de inventario" + codinventario + "buscado");
		}
	}

	@Override
	public Optional<Inventario> createInventario(Inventario inventario) {
		Optional<Inventario> optInventario = Optional.of(inventario);
		if(optInventario.isPresent()) {
			Inventario newInventory = new Inventario();
			newInventory.setCodigo(inventario.getCodigo());
			newInventory.setNombre_producto(inventario.getNombre_producto());
			newInventory.setUnidad_medida(inventario.getUnidad_medida());
			newInventory.setCantidad(inventario.getCantidad());
			newInventory.setPrecio(inventario.getPrecio());
			newInventory.setObservaciones(inventario.getObservaciones());
			inventarioRepository.save(newInventory);
			logger.info("Se ha creado el elemento de inventario correctamente.");
			Optional<Inventario> rturndOptInventory = Optional.of(newInventory);
			return rturndOptInventory;
		} else {
			logger.error("No se ha recibido un elemento de inventario para crear.");
			throw new NoSuchElementException("No se ha recibido un elemento de inventario para crear.");
		}
	}

	@Override
	public Inventario updateInventario(String codinventario, Inventario inventario) {
		Optional<Inventario> optInventario = inventarioRepository.findById(codinventario);
		if(optInventario.isPresent()) {
			Inventario inventarioUpdate = optInventario.get();
			inventarioUpdate.setNombre_producto(inventario.getNombre_producto());
			inventarioUpdate.setUnidad_medida(inventario.getUnidad_medida());
			inventarioUpdate.setCantidad(inventario.getCantidad());
			inventarioUpdate.setPrecio(inventario.getPrecio());
			inventarioUpdate.setObservaciones(inventario.getObservaciones());
			inventarioRepository.save(inventarioUpdate);
			logger.info("Inventario con id: " + codinventario + " actualizado correctamente.");
			return inventarioUpdate;
		} else {
			logger.error("El elemento de inventario a modificar no existe");
			throw new NoSuchElementException("No se encontró el elemento de inventario" + codinventario + "buscado");
		}
	}

	@Override
	public void deleteInventarioById(String codinventario) {
	    Optional<Inventario> optInventario = inventarioRepository.findById(codinventario);
	    if(optInventario.isPresent()) {
	    	Inventario inventarioTrust = optInventario.get();
	    	inventarioRepository.deleteById(inventarioTrust.getCodigo());
			logger.info("El elemento de inventario con id: " + codinventario + " fue eliminado de forma efectiva.");
	    } else {
	    	logger.error("El elemento de inventario a eliminar no existe.");
	    }
	}

}
