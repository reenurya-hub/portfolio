package com.example.demo_app.services;

import java.util.List;
import java.util.Optional;

import com.example.demo_app.dto.Producto;

public interface ProductoService {
    List<Producto> getAllProductos();
    Optional<Producto> getProductoById(int id);
    int createProducto(Producto producto);
    void updateProducto(int id, Producto producto);
    int updateProducto2(int id, Producto producto);  // 🔹 AHORA RETORNA UN ESTADO
    int deleteProductoById3(int id);
}