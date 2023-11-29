package com.reuy.tienda;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class ProductoService {

    private final JdbcTemplate jdbcTemplate;

    @Autowired
    public ProductoService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public String getProductos(Integer id) {
        String sql = "SELECT descripcion FROM producto WHERE id = ?";
        try {
            return jdbcTemplate.queryForObject(sql, String.class, id).toString();
        } catch (Exception e) {
            // Manejar la excepción según tu lógica de negocio o devuelve un mensaje de error
            return "Error al obtener la descripción del producto";
        }
    }

}