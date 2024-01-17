package com.reuy.sp_empleados.entity;


import jakarta.persistence.*;

@NamedStoredProcedureQuery(name = "employee.sp_select_employee", procedureName = "sp_select_employee", parameters = {
        @StoredProcedureParameter(mode = ParameterMode.IN, name = "Id", type = Integer.class),
        @StoredProcedureParameter(mode = ParameterMode.OUT, name = "Nombre", type = String.class)})

@Entity
@Table(name = "Empleados")
public class Empleado {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;
}
