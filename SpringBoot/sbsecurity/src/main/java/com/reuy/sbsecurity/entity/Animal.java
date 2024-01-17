package com.reuy.sbsecurity.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class Animal {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "idanimal")
    private int idanimal;
    @Column(name = "tipo", length = 50)
    private String tipo;
    @Column(name = "nombre")
    private String nombre;
    @Column(name = "edad")
    private int edad;

}
