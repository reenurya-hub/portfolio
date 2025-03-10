package com.example.demo_app.controllers;

import java.util.List;
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

import com.example.demo_app.dto.Producto;
import com.example.demo_app.services.ProductoServiceImpl;

@RestController
@RequestMapping("/productos")
@CrossOrigin(origins = "*")
public class ProductoController {

	@Autowired
    public ProductoServiceImpl productoServiceimpl;


    
    @GetMapping("/all")
    public List<Producto> getAllProductos() {
        return productoServiceimpl.getAllProductos();
    }
    
	
    @GetMapping("/{id}")
    public Optional<Producto> getProductoById(@PathVariable int id) {
    	return productoServiceimpl.getProductoById(id);

    }
    
    @PostMapping("/insert")
    public String createProducto(@RequestBody Producto producto) {
    	int resultado = productoServiceimpl.createProducto(producto);
        return resultado == 1 ? "Producto insertado correctamente" : "Error: Producto no insertado";

    }

    /*
    @PutMapping("/update/{id}")
    public void updateProducto(@PathVariable int id, @RequestBody Producto producto) {
        productoServiceimpl.updateProducto(id, producto);
    }
    */
    @PutMapping("/update2/{id}")
    public String updateProducto2(@PathVariable int id, @RequestBody Producto producto) {
        int resultado = productoServiceimpl.updateProducto2(id, producto);
        return resultado == 1 ? "Producto actualizado correctamente" : "Error: Producto no encontrado";
    }

    @PutMapping("/delete/{id}")  // 🔹 Cambia de GET a DELETE
    public String deleteProducto(@PathVariable int id) {
        int resultado = productoServiceimpl.deleteProductoById3(id);
        return resultado == 1 ? "Producto eliminado correctamente" : "Error: Producto no eliminado";
    }
    
}
