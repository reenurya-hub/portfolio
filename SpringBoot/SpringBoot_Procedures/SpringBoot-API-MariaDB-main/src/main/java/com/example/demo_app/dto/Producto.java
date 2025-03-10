package com.example.demo_app.dto;

import java.util.Optional;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name="test")
public class Producto {

	@Id
	@Column(name = "id")
    private int id;
	
	@Column(name="descripcion")
    private String descripcion;
	
	@Column(name="valor")
    private double valor;
    
	public Producto() {}
	
    public Producto(int id, String descripcion, double valor) {
        this.id = id;
        this.descripcion = descripcion;
        this.valor = valor;
    }

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getDescripcion() {
		return descripcion;
	}

	public void setDescripcion(String descripcion) {
		this.descripcion = descripcion;
	}

	public double getValor() {
		return valor;
	}

	public void setValor(double valor) {
		this.valor = valor;
	}    
	
	@Override
	public String toString() {
		return "Producto [id=" + id + ", descripcion=" + descripcion + ", valor=" + valor + "]";
	}

	public Optional<Producto> map(Object object) {
		// TODO Auto-generated method stub
		return null;
	}
	
}
