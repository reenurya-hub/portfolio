package com.example.demo_app.dao;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.demo_app.dto.Inventario;

@Repository
public interface InventarioRepository extends JpaRepository<Inventario, String>{

}
