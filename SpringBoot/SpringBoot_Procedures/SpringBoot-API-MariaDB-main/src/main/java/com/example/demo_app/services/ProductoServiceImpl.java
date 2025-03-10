package com.example.demo_app.services;

import java.util.List;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo_app.dao.ProductoRepository;
import com.example.demo_app.dto.Producto;

@Service
public class ProductoServiceImpl implements ProductoService {

	@Autowired
	public ProductoRepository productoRepository;
	
    Logger logger = LoggerFactory.getLogger(InventarioServiceImpl.class);

    
    @Override
    public List<Producto> getAllProductos() {
        return productoRepository.findAll();
    }
    /*
    @Override
    public Optional<Producto> getProductoById(int id) {
        return Optional.ofNullable(productoRepository.obtenerProductoId(id));
    }
    }*/
    
    @Override
    @Transactional(readOnly = true)  // 🔹 ¡AÑADIDO AQUÍ!
    public Optional<Producto> getProductoById(int id) {
        return Optional.ofNullable(productoRepository.obtenerProductoId(id));
    }
    
    @Override
    public int createProducto(Producto producto) {
        return productoRepository.insertarProducto2(producto.getDescripcion(), producto.getValor());
    }
    
    /*
    @Override
    public Producto updateProducto(int id, Producto producto) {
        return productoRepository.obtenerProductoId(id).map(existingProducto -> {
            existingProducto.setDescripcion(producto.getDescripcion());
            existingProducto.setValor(producto.getValor());
            return productoRepository.save(existingProducto);
        }).orElseThrow(() -> new RuntimeException("Producto no encontrado"));
    }*/
    @Override
    @Transactional  // 🔹 REQUERIDO PARA ACTUALIZAR
    public void updateProducto(int id, Producto producto) {
        productoRepository.modificarProducto(id, producto.getDescripcion(), producto.getValor());
    }
    
    @Override
    @Transactional  // 🔹 REQUERIDO PARA ACTUALIZAR
    public int updateProducto2(int id, Producto producto) {
        return productoRepository.modificarProducto2(id, producto.getDescripcion(), producto.getValor());
    }

    @Override
    @Transactional  // 🔹 REQUERIDO PARA ACTUALIZAR
    public int deleteProductoById3(int id) {
        return productoRepository.borrarProductoId3(id);
    }
    
}
