package com.example.demo_app.dto;


import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name="inventarios")
public class Inventario {
	
	/*@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;*/
	
	@Id
	@Column(name = "codigo")
	private String codigo;
	
	@Column(name="nombre_producto")
	private String nombre_producto;
	
	@Column(name="unidad_medida")
	private String unidad_medida;

	@Column(name="cantidad")
	private int cantidad ;

	@Column(name="precio")
	private double precio;

	@Column(name="observaciones")
	private String observaciones;
	
	
	

	public Inventario() {}

	public Inventario(String codigo, String nombre_producto, String unidad_medida, int cantidad, double precio, String observaciones) {
		this.codigo = codigo;
		this.nombre_producto = nombre_producto;
		this.unidad_medida = unidad_medida;
		this.cantidad = cantidad;
		this.precio = precio;
		this.observaciones = observaciones;
	}

	/*public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}*/

	

	public String getCodigo() {
		return codigo;
	}

	public void setCodigo(String codigo) {
		this.codigo = codigo;
	}
	
	public String getNombre_producto() {
		return nombre_producto;
	}

	public void setNombre_producto(String nombre_producto) {
		this.nombre_producto = nombre_producto;
	}

	public String getUnidad_medida() {
		return unidad_medida;
	}

	public void setUnidad_medida(String unidad_medida) {
		this.unidad_medida = unidad_medida;
	}
	
	public int getCantidad() {
		return cantidad;
	}

	public void setCantidad(int cantidad) {
		this.cantidad = cantidad;
	}

	public double getPrecio() {
		return precio;
	}

	public void setPrecio(double precio) {
		this.precio = precio;
	}

	public String getObservaciones() {
		return observaciones;
	}

	public void setObservaciones(String observaciones) {
		this.observaciones = observaciones;
	}

	

	@Override
	public String toString() {
		return "Usuario [codigo=" + codigo + ", nombre=" + nombre_producto + ", unidad_medida=" + unidad_medida + ", cantidad=" + cantidad + ", precio="
				+ precio +  ", observaciones="+ observaciones + "]";
	}	
}
