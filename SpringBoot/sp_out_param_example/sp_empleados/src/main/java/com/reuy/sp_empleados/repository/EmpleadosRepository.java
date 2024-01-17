package com.reuy.sp_empleados.repository;

import jakarta.persistence.EntityManager;
import jakarta.persistence.ParameterMode;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.StoredProcedureQuery;
import org.springframework.stereotype.Repository;

@Repository
public class EmpleadosRepository{
    @PersistenceContext
    private EntityManager entityManager;

    public String getEmployeeNamebyId(Integer Id) {
        StoredProcedureQuery storedProcedureQuery = entityManager.createStoredProcedureQuery("sp_select_nom_empleado");

        // Configurar parámetros de entrada
        storedProcedureQuery.registerStoredProcedureParameter("Id", Integer.class, ParameterMode.IN);
        storedProcedureQuery.setParameter("Id", Id);

        // Configurar parámetros de salida
        storedProcedureQuery.registerStoredProcedureParameter("Nombre", String.class, ParameterMode.OUT);

        // Ejecutar el procedimiento almacenado
        storedProcedureQuery.execute();

        // Obtener y retornar el valor del parámetro de salida
        return (String) storedProcedureQuery.getOutputParameterValue("Nombre");
    }

}
