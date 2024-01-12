package com.reuy.concesionario.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class Auto {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "idauto")
    private int idauto;
    @Column(name = "marca", length = 50)
    private String marca;
    @Column(name = "modelo")
    private int modelo;
    @Column(name = "valor")
    private long valor;

}
