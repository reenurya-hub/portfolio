package com.reuy.mssql.prueba.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;



@NamedStoredProcedureQuery(name = "employee.sp_select_employee", procedureName = "sp_select_employee", parameters = {
        @StoredProcedureParameter(mode = ParameterMode.IN, name = "empid", type = Integer.class) })

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "employee")
public class Employee {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "empid")
    private Integer id;
    @Column(name = "ename")
    private String name;
    @Column(name = "address")
    private String address;

}