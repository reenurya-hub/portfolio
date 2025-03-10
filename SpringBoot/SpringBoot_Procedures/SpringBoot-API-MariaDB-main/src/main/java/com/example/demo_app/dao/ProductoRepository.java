package com.example.demo_app.dao;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.query.Procedure;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.example.demo_app.dto.Producto;

import jakarta.persistence.EntityManager;
import jakarta.persistence.ParameterMode;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.StoredProcedureQuery;

@Repository
public interface ProductoRepository extends JpaRepository<Producto, Integer> {

    @Procedure(name = "obtenerProductoPorId")
    Producto obtenerProductoId(@Param("p_id") int id);
    
    @Procedure(procedureName = "modificarProducto")
    void modificarProducto(@Param("p_id") int id, 
                           @Param("p_descripcion") String descripcion, 
                           @Param("p_valor") Double valor);
    
    @Procedure(procedureName = "modificarProducto2")
    int modificarProducto2(@Param("p_id") int id, 
                           @Param("p_descripcion") String descripcion, 
                           @Param("p_valor") Double valor);
    
    @Procedure(procedureName = "insertarProducto3")
    int insertarProducto2(@Param("p_descripcion") String descripcion,
    		              @Param("p_valor") Double valor);

    @Procedure(name = "borrarProductoId3")
    int borrarProductoId3(@Param("p_id") int id);
    
    
    
}